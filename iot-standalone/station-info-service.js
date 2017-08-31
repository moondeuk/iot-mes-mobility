var jsonfile = require('./lib/node-jsonfile.js')

const STATION_INFO_FILE = '/home/root/.node_app_slot/information_files/station_info.json';
const VEHICLE_INFO_FILE = '/home/root/.node_app_slot/information_files/vehicle_info.json';

var stations = [];


StationInfoServiceFactory = function (options){
    var factory = this;
    
    function StationInfoService(options){
        var self = this;
        logger = options.logger;
        
        init();
    }
    
    var getStationInfo = function(uuid){
        for(i=0;i<stations.length;i++){
            if(stations[i].uuid == uuid){
                return stations[i];
            }
        }
        return;
    }

    function init(){
        var expectedBroadcastcode = "";
        var stationName = "", familyaddress = "", pono = "", vin = "";

        var stationInfo = jsonfile.readFileSync(STATION_INFO_FILE);
        var vehicleInfo = jsonfile.readFileSync(VEHICLE_INFO_FILE);


        if(typeof stationInfo.station_data != "undefined"){
            for (var i = 0; i < stationInfo.station_data.length; i++){

                 var uuid = "";
                if(typeof stationInfo.station_data[i].uuid != "undefined"){
                    uuid = stationInfo.station_data[i].uuid;
                }

                var station_name = "";
                if(typeof stationInfo.station_data[i].station_name != "undefined"){
                    stationName = stationInfo.station_data[i].station_name;
                }
                
                var traceId = "";
                if(typeof stationInfo.station_data[i].trace_id != "undefined"){
                    traceId = stationInfo.station_data[i].trace_id;
                }
                
                 var clientId = "";
                if(typeof stationInfo.station_data[i].client_id != "undefined"){
                    clientId = stationInfo.station_data[i].client_id;
                }

                var partName = "";
                if(typeof(stationInfo.station_data[i].part_name) != "undefined"){
                    partName =stationInfo.station_data[i].part_name;
                }

                var barcodeSpec = "";
                if(typeof(stationInfo.station_data[i].barcode_spec) != "undefined"){
                    barcodeSpec =stationInfo.station_data[i].barcode_spec;
                }

                var familyAddress = "";
                if(typeof(stationInfo.station_data[i].familyaddress) != "undefined"){
                    familyAddress =stationInfo.station_data[i].familyaddress;
                }


                var vin = "";
                if(typeof(vehicleInfo.vin) != "undefined"){
                    vin = vehicleInfo.vin;
                }

                var pono = "";
                if(typeof(vehicleInfo.pono) != "undefined"){
                    pono = vehicleInfo.pono;
                }
                
                var stationType = "";
                if(typeof(stationInfo.station_data[i].station_type) != "undefined"){
                    stationType = stationInfo.station_data[i].station_type;
                }

                var expectedBroadcastcode = "";
                if(typeof(vehicleInfo.broadcastcode[familyAddress]) != "undefined"){
                    expectedBroadcastcode = vehicleInfo.broadcastcode[familyAddress];
                }


                var station = {};
                station.uuid = uuid
                station.pvi = pono
                station.vin = vin
                station.stationName = stationName
                station.traceId = traceId
                station.partName = partName
                station.familyAddress = familyAddress
                station.expectedBroadcastcode = expectedBroadcastcode
                station.barcodeSpec = barcodeSpec
                station.clientId = clientId
                station.stationType = stationType;
            


                logger.log('info','[STATION-INFO-SERVICE] ####### STATION INFORMATION INIATILIZATION ######');
                logger.log('info','[STATION-INFO-SERVICE] UUID: '+ uuid);
                logger.log('info','[STATION-INFO-SERVICE] PONO: '+ pono);
                logger.log('info','[STATION-INFO-SERVICE] Station Name: '+ stationName);
                logger.log('info','[STATION-INFO-SERVICE] Client ID: '+ clientId);
                logger.log('info','[STATION-INFO-SERVICE] PART_NAME: '+ partName);
                logger.log('info','[STATION-INFO-SERVICE] Family Address: '+ familyAddress)
                logger.log('info','[STATION-INFO-SERVICE] Expected BC: ' + expectedBroadcastcode); 
                logger.log('info','[STATION-INFO-SERVICE] Barcode Spec: ' + barcodeSpec); 

                stations.push(station)
            }
        }
    }
    
    StationInfoService.prototype.getStationInfo = getStationInfo;
    
    factory.StationInfoService = StationInfoService;
}



module.exports = new StationInfoServiceFactory();