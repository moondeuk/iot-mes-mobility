var StationInfoServiceFactory = require('/home/root/.node_app_slot/station-info-service.js')
var jsonfile = require('/home/root/.node_app_slot/lib/node-jsonfile.js')

const STATUS_NOT_ASSIGNED = "STATUS_NOT_ASSIGNED"
const STATUS_STATION_ENTER = "STATUS_STATION_ENTER"
const STATUS_STATION_COMPLETE = "STATUS_STATION_COMPLETE"
const STATUS_STATION_ERROR = "STATUS_STATION_ERROR"

const TRACE_RESULT_INFO_FILE = '/home/root/.node_app_slot/information_files/trace_result_info.json';
const TOPIC_PUBLISH_PREFIX = "puck/station-information/"
const TOPIC_GET_VEHICLE_INFORMATION = "puck/traceability/get-vehicle-information"
const TOPIC_BARCODE_MANUAL_INPUT = "puck/traceability/barcode-manual-input"

vehicleInfoService = function (options){

    var nfcSensor = options.nfcSensor;
    var beaconSensor = options.beaconSensor;
    var lightBuzzer = options.lightBuzzer;
    var client = options.client
    var logger = options.logger
    var stationInfo = {}
    var status = STATUS_NOT_ASSIGNED
    var publishTopic
    
    var traceResultInformation = jsonfile.readFileSync(TRACE_RESULT_INFO_FILE, {"throws":false});
    
    var stationInfoService = new StationInfoServiceFactory.StationInfoService({"logger":logger});    
    
    client.subscribe(TOPIC_GET_VEHICLE_INFORMATION, {qos: 2});
    client.subscribe(TOPIC_BARCODE_MANUAL_INPUT, {qos: 2});
    
    function getCurrentTimeStamp(){
        var currentdate = new Date(); 
        var datetime = '' + currentdate.getFullYear() + ''
        + (currentdate.getMonth()+1) + ''
        + currentdate.getDate() + ''
        + currentdate.getHours() + ''
        + currentdate.getMinutes() + ''
        + currentdate.getSeconds();
        
        return datetime;
        
    }
    
    function didEnterIntoNewStation(uuid){
        stationInfo = stationInfoService.getStationInfo(uuid);
    
        nfcSensor.writeSensor(JSON.stringify({"command":"reset_old_data"}))
        // Publish Station Info to MQTT

        
        if(stationInfo){
            publishTopic = TOPIC_PUBLISH_PREFIX + stationInfo.clientId;
            logger.log("info", "[VEHICLE-INFO-SERVICE] station type: "+ stationInfo.stationType);
            
            if(stationInfo.stationType == "defect-station" || stationInfo.stationType == "inspector-station"){
               
                if(!traceResultInformation) {
                    traceResultInformation = {};
                    traceResultInformation.status = "OK";
                    traceResultInformation.pvi = stationInfo.pono;
                }

                var command = "new-defect-station-entered";
                var publishingData = {"command":command, "stationInfo":stationInfo, "traceResults":traceResultInformation};
                client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
                logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");

                lightBuzzer.writeSensor(JSON.stringify({"result":"OK"})); 
                
            }
            else if(stationInfo.stationType == "trace-station"){
                
                var command = "new-station-entered";
                var publishingData = {"command":command, "stationInfo":stationInfo};
                client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
                logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");

                status = STATUS_STATION_ENTER
                
                logger.log("info", "check:" + status);

                
                lightBuzzer.writeSensor(JSON.stringify({"result":"PROCESSING"}))
            }
             
        }
        else{
            logger.log("error", "[VEHICLE-INFO-SERVICE] Can't find station using the uuid :(" + uuid + ")");
            lightBuzzer.writeSensor(JSON.stringify({"result":"NOK"}))
        }
    }
    
    function didEnterTraceData(barcodeData){
        
        logger.log("info", "check:" + status);
        
        if(status != STATUS_NOT_ASSIGNED){
            
            var command = "trace-data-entered";
            var publishingData = {"command":command, "barcodeData":barcodeData};
            client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
            logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");
            processTraceData(barcodeData);
                
        }
        else{
            logger.log("error", "[VEHICLE-INFO-SERVICE] New TraceData was not accepted as Station is not assigned.");
            
            lightBuzzer.writeSensor(JSON.stringify({"result":"NOK"}))
        }
        
    }
    
    function processTraceData(barcodeData){
        
        var barcodeLength = stationInfo.barcodeSpec.length;
        var partCodeStartIndex = 0
        var partCodeEndIndex = 0
        var traceDataStartIndex = 0
        var traceDataEndIndex = 0
        var traceData
        var scanTime
        var scanResult = "OK"
        var errorDescription = ""
        
        logger.log("info", "[VEHICLE-INFO-SERVICE] processing trace data start");
        
        
        for(var i=0;i<stationInfo.barcodeSpec.contents.length;i++){
            if(stationInfo.barcodeSpec.contents[i].name == "part_code"){
                partCodeStartIndex = stationInfo.barcodeSpec.contents[i].start_position
                partCodeEndIndex = stationInfo.barcodeSpec.contents[i].end_position
            }
            if(stationInfo.barcodeSpec.contents[i].name == "trace_data"){
                traceDataStartIndex = stationInfo.barcodeSpec.contents[i].start_position
                traceDataEndIndex = stationInfo.barcodeSpec.contents[i].end_position
            }
        }
        
        
        // #1. Validate the length
        if(barcodeData.length != stationInfo.barcodeSpec.length){
            
            var command = "error";
            errorDescription = "Barcode Scan Data is invalid: (Expected Length:" + stationInfo.barcodeSpec.length + ", Scanned Length:" + barcodeData.length +")"
            var publishingData = {"command":command, "errorDescription":errorDescription};
            client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
            logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");
            logger.log("error", "[VEHICLE-INFO-SERVICE] error :" + errorDescription);
            
            status = STATUS_STATION_ERROR;
            
            scanResult = "NOK";
            
            lightBuzzer.writeSensor(JSON.stringify({"result":"NOK"}))
        }
        
        traceData = ""
        
        if(scanResult != "NOK"){
            // #2. Validate the part
            var partCode = barcodeData.substring(partCodeStartIndex, partCodeEndIndex)
            if(partCode != stationInfo.expectedBroadcastcode){
                                
                var command = "error";
                errorDescription = "Broadcast Code is different: (Expected BC:" + stationInfo.expectedBroadcastcode + ", Scanned BC:" + partCode +")"
                defectDescription = "Invalid part data - Trace Error";
                var publishingData = {"command":command, "errorDescription":errorDescription, "defect":defectDescription};
                client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
                logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");
                logger.log("error", errorDescription);

                status = STATUS_STATION_ERROR;

                scanResult = "NOK";

                lightBuzzer.writeSensor(JSON.stringify({"result":"NOK"}))
            }
        }
        
        if(scanResult != "NOK"){
            traceData = barcodeData.substring(traceDataStartIndex, traceDataEndIndex)
         
            var command = "tracecomplete";
            var publishingData = {"command":command, "traceData":traceData};
            client.publish(publishTopic, JSON.stringify(publishingData), {qos: 2});
            logger.log("info", "[VEHICLE-INFO-SERVICE] Message publised. (Topic:" + publishTopic + ", Command:" + command + ")");
            
            lightBuzzer.writeSensor(JSON.stringify({"result":"OK"}))
            
            status = STATUS_NOT_ASSIGNED;
        }
        
        var id = stationInfo.traceId;
        
        if (!traceResultInformation) {
            traceResultInformation = {};
        }
             
        /*
        if(!traceResultInformation.traceResults){
            traceResultInformation.traceResults = {}; 
        }*/
        
        traceResultInformation[id] = {"traceId":stationInfo.traceId, "partName":stationInfo.partName, "traceData":traceData, "scanTime":scanTime = getCurrentTimeStamp(), "scanResult":scanResult,"error":errorDescription};    
        
        traceResultInformation.status = "OK";
        
        Object.keys(traceResultInformation).forEach(function(element, key, _array) {
            
            logger.log("info", "Trace Result check : result : " + traceResultInformation[element].scanResult)
            
            if (traceResultInformation[element].scanResult == "NOK"){
                traceResultInformation.status = "NOK";
            }
        });
        
        jsonfile.writeFile(TRACE_RESULT_INFO_FILE, traceResultInformation), function(err){
            logger.log("error", "[VEHICLE-INFO-SERVICE] error :" + errorDescription);
        }
    }
    
    client.on('message', function(topic, data, packet){
        
        if(topic === TOPIC_GET_VEHICLE_INFORMATION){
            
        }
        
        if(topic === TOPIC_BARCODE_MANUAL_INPUT){
            var parsedData = JSON.parse(data);
            
            logger.log("info", "[VEHICLE-INFO-SERVICE] Manual Input Recevied : (Client ID:" + stationInfo.clientId + ", Barcode Data:" + parsedData.barcodeData + ")" )
            if(typeof(parsedData.barcodeData) != "undefined"){
                logger.log("parsedData.clientId: "+ parsedData.clientId + "| stationInfo.clientId: "+ stationInfo.clientId);
                if(parsedData.clientId == stationInfo.clientId){
                    didEnterTraceData(parsedData.barcodeData);
                }
            }
        }
    });
    
    nfcSensor.on('data', function(data){
        var nfcData = JSON.parse(data);
        
        logger.log("info", "[VEHICLE-INFO-SERVICE] nfcData:" + nfcData.data)
        if(typeof(nfcData.data) != "undefined"){
            didEnterTraceData(nfcData.data);    
        }
    });
    
    beaconSensor.on('data', function(data){
        
        var beaconData = JSON.parse(data);
        
        if(typeof(beaconData.uuid) != "undefined"){
            didEnterIntoNewStation(beaconData.uuid)    
        }
    });
    
    

}


module.exports = vehicleInfoService;