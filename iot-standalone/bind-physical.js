bindPhysical = function (options){
  var client = options.client;
  var sensor = options.sensor;
  var receiveTopic = options.receiveTopic;
  var transmitTopic = options.transmitTopic;
  var qos = options.qos || 0;
  

  client.subscribe(receiveTopic, {qos: qos});

  sensor.on('data', function(data){
    client.publish(transmitTopic, data, {qos: qos});
    console.log("Message publised.");
  });


  client.on('message', function(topic, data, packet){
    try{
      if(topic === receiveTopic){
        sensor.writeSensor(data);
      }
    }catch(exp){
      console.log('error on message', exp);
      //self.emit('error', 'error receiving message: ' + exp);
    }
  });


}


module.exports = bindPhysical;