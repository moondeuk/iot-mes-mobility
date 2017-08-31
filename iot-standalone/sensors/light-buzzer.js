var EventEmitter = require('events').EventEmitter;
var util = require('util');
buzzleds = require('./buzzleds.js');

const SENSOR_ID = 'SN2-LIGHT-BUZZER';
const SLEEP_TIME = 7000; // 3 seconds
const COLOR_RED = "COLOR_RED"
const COLOR_BLUE = "COLOR_BLUE"
const COLOR_GREEN = "COLOR_GREEN"

function LightBuzzerFactory(options){
        
    // Now scan and identify any cards that come in range (1 for now)
    var factory = this;

    var msg = {};
    var count = 0;
    var logger;

    
    function LightBuzzer(options){
        var self = this;
        logger = options.logger;
    }
    
    function toHex(d, pad)
    {
        // pad should be between 1 and 8
        return  ("00000000"+(Number(d).toString(16))).slice(-pad);
    }

    var initSensor = function (){
        var self = this;
        buzzleds.off();
    };
    

    var readSensor = function () {
        logger.log("info", "[LIGHT-BUZZER] This sensor doesn't provide reading function"); 
    };
    

    util.inherits(LightBuzzer, EventEmitter);
    
    LightBuzzer.prototype.initSensor = initSensor;
    LightBuzzer.prototype.readSensor = readSensor;
    
    LightBuzzer.prototype.writeSensor = function (msg){
        var msgObj = JSON.parse(msg);
        
        if (msgObj.result == "OK"){
            //buzzleds.off();
            buzzleds.green(50, 50, 10);
            buzzleds.beep(50, 50, 2); //OK
            logger.log("info", "[LIGHT-BUZZER] good signal write comlete.")
        }
        else if (msgObj.result == "NOK"){
            //buzzleds.off();
            buzzleds.red(50, 50, 10);
            buzzleds.beep(300); //OK
            logger.log("info", "[LIGHT-BUZZER] bad signal write comlete.")
        }
        else if (msgObj.result == "PROCESSING"){
            //buzzleds.off();
            buzzleds.blue(50, 50, 10);
            buzzleds.beep(50, 50, 2); //OK
            logger.log("info", "[LIGHT-BUZZER] processing signal write comlete.")
        }
    }
    
    factory.LightBuzzer = LightBuzzer;
}


util.inherits(LightBuzzerFactory, EventEmitter)
module.exports = new LightBuzzerFactory();