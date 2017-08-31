var pn532 = require('jsupm_pn532');
var EventEmitter = require('events').EventEmitter;
var util = require('util');
var jsonfile = require('/home/root/.node_app_slot/library/node-jsonfile.js')

var SENSOR_ID = 'SN3';
var SLEEP_TIME = 1000; // 3 seconds
var NO_MATCHING_DATA = 'NO_MATCHING_DATA';
var nfcInfoFile = './information_files/nfc_info.json';

function NfcSensorFactory(options){
        
    // Now scan and identify any cards that come in range (1 for now)
    var factory = this;
    var logger;
    

    // Instantiate an PN532 on I2C bus 0 (default) using gpio 3 for the
    // IRQ, and gpio 2 for the reset pin.
    var myNFCObj = new pn532.PN532(3, 2);
    var uidSize = new pn532.uint8Array(0);
    var uid = new pn532.uint8Array(7);
    var msg = {};
    var nfc_mapping_datas = [];
    var old_uid = '';
    
    function NfcSensor(options){
        var self = this;
        logger = options.logger;
    }
    
    function toHex(d, pad)
    {
        // pad should be between 1 and 8
        return  ("00000000"+(Number(d).toString(16))).slice(-pad);
    }

    function readNfcInfo(){
        var nfcInfo = jsonfile.readFileSync(nfcInfoFile);
                
        if(typeof nfcInfo.nfc_mapping_datas != "undefined"){
            for (i=0;i<nfcInfo.nfc_mapping_datas.length;i++){
                nfc_mapping_datas.push(nfcInfo.nfc_mapping_datas[i])
                
                logger.log("info", "[NFC-SENSOR] NFC Association Complete (uid :" + nfcInfo.nfc_mapping_datas[i].uid, ", data :" + nfcInfo.nfc_mapping_datas[i].data + ")");
            }
        }
    }
    
    function associateMappingData(uid, data){
         var matching_index = -1;
        for(var i=0;i<nfc_mapping_datas.length;i++){
            if(getAssociatedData(uid) != NO_MATCHING_DATA)
                matching_index = i;
        }

        if(matching_index > -1){
            nfc_mapping_datas[matching_index].data = data;
        }
        else{
            nfc_mapping_datas.push({"uid":uid, "data":data});
        }

        jsonfile.writeFileSync(nfcInfoFile, {"nfc_mapping_datas" :nfc_mapping_datas})
        logger.log("info", "[NFC-SENSOR] NFC Association Complete (uid :" + uid, ", data :" + data + ")");
    }
    
    
    function getAssociatedData(uid){
        for(var i=0;i<nfc_mapping_datas.length;i++){
            if(nfc_mapping_datas[i].uid == uid){
                return nfc_mapping_datas[i].data;
            }
        }
        
        return NO_MATCHING_DATA;
    }
    
    var getSensorInfo = function(){
        var info = {};
        info.sensor_id = SENSOR_ID;
        
        var ids = [];
        for(i=0;i<nfc_mapping_datas.length;i++){
            ids.push(nfc_mapping_datas[i]);
        }
        
        info.ids = ids;
        
        return info;
    }
    
    var initSensor = function (){
        var self = this;
        try{
            
            readNfcInfo()
            
            // "main"
            if (!myNFCObj.init())
                logger.log("info", "[NFC-SENSOR] init() failed");

            var vers = myNFCObj.getFirmwareVersion();

            if (vers)
                logger.log("info", "[NFC-SENSOR] Got firmware version: " + toHex(vers, 8));
            else
            {
                logger.log("info", "[NFC-SENSOR] Could not identify PN532");
                exit();
            }

            // Now scan and identify any cards that come in range (1 for now)

            // Retry forever
            myNFCObj.setPassiveActivationRetries(0xff);

            myNFCObj.SAMConfig();

        }catch(ex){
            logger.log("info", "[NFC-SENSOR] Failed to get firmware version. Retrying..." + ex.toString());
            NfcSensor.prototype.initSensor();
        }
    };
    
    
    var readSensor = function () {
        var self = this;
        //logger.log("info", '***********************');
        //logger.log("info", "Waiting Tag....");


        for (var x = 0; x < 7; x++)
            uid.setitem(x, 0);

        try {
            
            myNFCObj.SAMConfig();
            if (myNFCObj.readPassiveTargetID(pn532.PN532.BAUD_MIFARE_ISO14443A,
                                         uid, uidSize, 1000))
            {
                // found a card
                logger.log("info", "[NFC-SENSOR] Found a card: UID len " + uidSize.getitem(0));
                process.stdout.write("UID: ");
                var uidHex = '';
                for (var i = 0; i < uidSize.getitem(0); i++)
                {
                    var byteVal = uid.getitem(i);
                    process.stdout.write(toHex(byteVal, 2) + " ");
                    //uidHex = uidHex + toHex(byteVal, 2) + " ";
                    uidHex = uidHex + toHex(byteVal, 2);
                }
                process.stdout.write("\n");
                logger.log("info", "[NFC-SENSOR] SAK: " + toHex(myNFCObj.getSAK(), 2));
                logger.log("info", "[NFC-SENSOR] ATQA: " + toHex(myNFCObj.getATQA(), 4));
                logger.log("info", "[NFC-SENSOR] DATA: "  + getAssociatedData(uidHex));

                // build the object message
                // that will be sent as a JSON message
                msg.sensor_id = SENSOR_ID;
                msg.uid = uidHex;
                msg.data = getAssociatedData(uidHex);
                msg.sak = toHex(myNFCObj.getSAK(), 2);
                msg.atqa = toHex(myNFCObj.getATQA(), 4);

                logger.log("info", "[NFC-SENSOR] old_uid :" + old_uid + ", uid :" + uidHex);
                if(old_uid != uidHex){
                    // event emit
                    self.emit('data', JSON.stringify(msg));
                    old_uid = uidHex;
                }
            }
            
        } catch (err) {
            logger.log("error", "[NFC-SENSOR] error on reading : " + err.message)
        }
        

        setTimeout(this.readSensor.bind(this), SLEEP_TIME); 
    };
    
    util.inherits(NfcSensor, EventEmitter);
    NfcSensor.prototype.initSensor = initSensor;
    NfcSensor.prototype.readSensor = readSensor;
    NfcSensor.prototype.getSensorInfo = getSensorInfo;
    

    NfcSensor.prototype.writeSensor = function (msg){
        
        var msgObj = JSON.parse(msg);
        if(typeof(msgObj.command) != "undefined"){
            if(msgObj.command == "association"){
                var uid = msgObj.uid;
                var data = msgObj.data;
               
            }
            else if(msgObj.command == "reset_old_data"){
                old_uid = '';
                logger.log("info", "[NFC-SENSOR] Old Uid Reset complete");
            }
        }
    }
    
    
    factory.NfcSensor = NfcSensor;
}


util.inherits(NfcSensorFactory, EventEmitter);
module.exports = new NfcSensorFactory();