var Bleacon = require('bleacon');
var EventEmitter = require('events').EventEmitter;
var util = require('util');

var SENSOR_ID = 'SN3-Bluetooth-LE';
var THREDTHOLD_ACCURACY = 0.5;
var NO_MATCHING_DATA = 'NO_MATCHING_DATA';

var EXIT_GRACE_PERIOD = 2000;



function BeaconScannerFactory(options){
        
    // Now scan and identify any cards that come in range (1 for now)
    var factory = this;
    var msg = {};
    var old_uuid = '';
    var id_associations = [];
    var logger;
    var inRange = [];
    var nearestBleacon;
    
    function BeaconScanner(options){
        var self = this;
        logger = options.logger;
    }

    var initSensor = function (){
        var self = this;
    };
    
    setInterval(function() {
      for (var id in inRange) {
        if (inRange[id].lastSeen < (Date.now() - EXIT_GRACE_PERIOD)) {
          var bleacon = inRange[id].bleacon;

          logger.log("info", '[BEACON-SCANNER] iBeacon exited (UUID :'+  bleacon.uuid + ', ACCURACY: ' + bleacon.accuracy + ')');

          delete inRange[id];
        }
      }
    }, EXIT_GRACE_PERIOD / 2);
    
    function getAssociatedData(id){
        for(var i=0;i<id_associations.length;i++){
            if(id_associations[i].id == id){
                return id_associations[i].data;
            }
        }
        
        return NO_MATCHING_DATA;
    }
            
    /*
    function getNearestBleacon(){
        var nearestBleacon;
        
        for(var id in inRange) {
            if(nearestBleacon) {
                if(inRange[id].bleacon.accuracy < nearestBleacon.accuracy) {
                    nearestBleacon = inRange[id].bleacon;
                }    
            }
            else{
                nearestBleacon = inRange[id].bleacon;
            }
        }
        
        return nearestBleacon;
    }*/
    
    var readSensor = function () {
        var self = this;
        logger.log("info", '[BEACON-SCANNER] ***********************');
        logger.log("info", "[BEACON-SCANNER] iBeacon Scanner Started....");

        Bleacon.startScanning();
        Bleacon.on('discover', function (bleacon){
            
            if(bleacon.accuracy < 0 ){
                // ignore
                return;
            }
            
            var id = bleacon.uuid + bleacon.major + bleacon.minor;
            var entered = !inRange[id];
            
                    
            if (entered){
                logger.log("info", '[BEACON-SCANNER] iBeacon entered (UUID :'+  bleacon.uuid + ', ACCURACY: ' + bleacon.accuracy + ')');
            }
            
            inRange[id] = {
                bleacon: bleacon
            };
            inRange[id].lastSeen = Date.now();
            
            if(nearestBleacon) {
                if(inRange[id].bleacon.accuracy < nearestBleacon.accuracy) {
                    nearestBleacon = inRange[id].bleacon;
                }    
            }
            else{
                nearestBleacon = inRange[id].bleacon;
            }
        
            /*
            var nearestBeacon = getNearestBleacon();
            */
            
            var nearestBeacon = nearestBleacon;
            
            if(old_uuid != nearestBeacon.uuid && nearestBeacon.accuracy < THREDTHOLD_ACCURACY){      

                logger.log("info", '[BEACON-SCANNER] Nearest iBeacon in Region is '+  nearestBeacon.uuid + '\t' + nearestBeacon.accuracy);

                // Build JSON data.
                msg.sensor_id = SENSOR_ID;
                msg.uuid = nearestBeacon.uuid;
                msg.data = getAssociatedData(nearestBeacon.uuid);
                msg.accuracy = nearestBeacon.accuracy;
                msg.proximity = nearestBeacon.proximity;
                msg.major = nearestBeacon.major;
                msg.minor = nearestBeacon.minor;

                self.emit('data', JSON.stringify(msg));

                old_uuid = bleacon.uuid;
            }

        });
    }
    
    var writeSensor = function (msg) {
        var msgObj = JSON.parse(msg);
        if(typeof(msgObj.command) != "undefined"){
            if(msgObj.command == "association"){
                var id = msgObj.id;
                var data = msgObj.data;
                var matching_index = -1;
                for(var i=0;i<id_associations.length;i++){
                    if(getAssociatedData(id) != NO_MATCHING_DATA)
                        matching_index = i;
                }
                
                if(matching_index > -1){
                    id_associations[matching_index].data = data;
                }
                else{
                    id_associations.push({"id":id, "data":data});
                }
                
                logger.log("info", "[BEACON-SCANNER] Association Complete (id :" + id, ", data :" + data + ")");
            }
            else if(msgObj.command == "reset_old_data"){
                old_uuid = '';
                logger.log("info", "[BEACON-SCANNER] Old UUid Reset complete");
            }
        }
    };
    
    var getSensorInfo = function(){
        var info = {};
        info.sensor_id = SENSOR_ID;
        
        var ids = [];
        for(i=0;i<id_associations.length;i++){
            ids.push(id_associations[i]);
        }
        
        info.ids = ids;
        
        return info;
    }
       
    util.inherits(BeaconScanner, EventEmitter);
    
    BeaconScanner.prototype.initSensor = initSensor;
    BeaconScanner.prototype.readSensor = readSensor;
    
    BeaconScanner.prototype.writeSensor = writeSensor;
    BeaconScanner.prototype.getSensorInfo = getSensorInfo;
    
    factory.BeaconScanner = BeaconScanner;
}


util.inherits(BeaconScannerFactory, EventEmitter);
module.exports = new BeaconScannerFactory();