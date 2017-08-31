var express = require('express');

vehicleInformationService = function (options){
    
    var app = express();
    var nfcSensor = options.nfcSensor;
    var beaconSensor = options.beaconSensor;
    var vehicleStatus = options.vehicleStatus;
    
    
    app.get('/vehicle-information', function(req, res) {
        
        
        console.log('Vehicle Information Requested');
        res.end(vehicleStatus.getInformation()); 
    });
    
    
    app.get('/sensor-information/nfc-sensor', function(req, res) {
        console.log('NFC Sensor Information Requested');
        
        res.end(nfcSensor.getSensorInfo()); 
    });
  
    app.get('/sensor-information/beacon-sensor', function(req, res) {
        console.log('Beacon Scanner Information Requested');
        
        res.end(beaconSensor.getSensorInfo()); 
    });
    
    var server = app.listen(8081, function () {

        var host = server.address().address
        var port = server.address().port

        console.log("Vehicle Information Service listening at http://%s:%s", host, port)
    })
    

}


module.exports = vehicleInformationService;