var bindSensor = require("./bind-sensor.js");
var mqtt = require('mqtt');
var nfcSensorFactory = require('./sensors/nfc-sensor.js');
var lightBuzzerFactory = require('./sensors/light-buzzer.js');
var beaconScannerFactory = require('./sensors/beacon-scanner.js');
var vehicleStatusFactory = require('./sensors/vehicle-status.js');
var vehicleInfoService = require('./vehicle-info-service.js');
var winston = require('winston'), fs = require('fs'), logDir = 'log';
var BROKER_URL = 'tcp://127.0.0.1';

var mqtt_client = mqtt.connect(BROKER_URL, {'keepalive' : 60});

if(!fs.existsSync(logDir)){
    fs.mkdirSync(logDir);
}

var logger = new winston.Logger({
    transports: [
        new (winston.transports.Console)({colorize: true}),
        new (winston.transports.File)({
            name: 'info-file',
            filename: './log/log-info.log',
            level: 'info',
            maxsize: 1024 * 1024 * 5, // 5 MB
            maxfiles: '50'
        }),
        new (winston.transports.File)({
         name: 'error-file',
            filename: './log/log-error.log',
            level: 'error',
            maxsize: 1024 * 1024 * 5, // 5MB,
         maxfiles: '50'
        })
    ],
    exceptionHandlers: [
        new winston.transports.File({
            filename: 'log/exception.log'
        })
    ]
});

mqtt_client.on('close', handle_mqtt_close);
mqtt_client.on('connect', handle_mqtt_connect);
mqtt_client.on('reconnect', handle_mqtt_reconnect);
mqtt_client.on('error', handle_mqtt_err);
mqtt_client.on('message', handle_messsage);

function handle_mqtt_connect()
{
    logger.log("info", "[MQTT-CLIENT] MQTT Connect...");
}

function handle_mqtt_subscribe(err, granted)
{
    logger.log("info", "[MQTT-CLIENT] MQTT Subscribe...");

    if (err)
    {
        logger.log("error", "[MQTT-CLIENT] error:" + err);
    }
}

function handle_mqtt_reconnect(err)
{
    logger.log("info", "[MQTT-CLIENT] MQTT Reconnect...");

    if (err)
    {
        logger.log("error", "[MQTT-CLIENT] error:" + err);
    }
}

function handle_mqtt_err(err)
{
    logger.log("info", "[MQTT-CLIENT] MQTT Error...");

    if (err)
    {
        logger.log("error", "[MQTT-CLIENT] error:" + err);
    }
}

function handle_mqtt_close()
{
    logger.log("info", "[MQTT-CLIENT] MQTT Close...");
}

function after_publish()
{
    logger.log("info", "[MQTT-CLIENT] Message publised.");
}

function handle_messsage(topic, message, packet) 
{
    logger.log("info", '[MQTT-CLIENT] Message received!');
    logger.log("info", '[MQTT-CLIENT] msg = ' + message.toString());
}

var nfcSensor = new nfcSensorFactory.NfcSensor({"logger":logger});
nfcSensor.initSensor();
nfcSensor.readSensor();
bindSensor({ sensor: nfcSensor,
  client: mqtt_client,
  transmitTopic: 'sensors/NFC/msg',
  receiveTopic: 'sensors/NFC/control',
  logger: logger,
  qos:2
})

var lightBuzzer = new lightBuzzerFactory.LightBuzzer({"logger":logger});
lightBuzzer.initSensor();
bindSensor({ sensor: lightBuzzer,
  client: mqtt_client,
  transmitTopic: 'sensors/light-buzzer/msg',
  receiveTopic: 'sensors/light-buzzer/control',
  logger: logger,            
  qos:2            
});

var beaconScanner = new beaconScannerFactory.BeaconScanner({"logger":logger});
beaconScanner.initSensor();
beaconScanner.readSensor();
bindSensor({ sensor: beaconScanner, 
    client: mqtt_client,
    transmitTopic: 'sensors/BeaconScanner/msg',
    receiveTopic: 'sensors/BeaconScanner/control',
    logger: logger,            
    qos:2
});

var vehicleStatus = new vehicleStatusFactory.VehicleStatus({"logger":logger});

bindSensor({ sensor: vehicleStatus, 
    client: mqtt_client,
    transmitTopic: 'sensors/VehicleStatus/msg',
    receiveTopic: 'sensors/VehicleStatus/control',
    qos:2,
    logger:logger
});

vehicleInfoService({ 
    sensor: beaconScanner, 
    client: mqtt_client,
    nfcSensor: nfcSensor,
    beaconSensor : beaconScanner,
    lightBuzzer : lightBuzzer,
    vehicleStatus : vehicleStatus,
    logger: logger
});