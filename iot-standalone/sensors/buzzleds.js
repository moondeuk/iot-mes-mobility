var gpio, parseArgs, recurseLoop, runSequence, switchPin;

var mraa = require('mraa'); //require mraa


off = function(pin){
    var myDigitalPin = new mraa.Gpio(pin);
    myDigitalPin.dir(mraa.DIR_OUT);
    myDigitalPin.write(0);  
}

on = function(pin){
    var myDigitalPin = new mraa.Gpio(pin);
    myDigitalPin.dir(mraa.DIR_OUT);
    myDigitalPin.write(1);  
}

switchPin = function(myDigitalPin, state, duration, callback) {
    myDigitalPin.dir(mraa.DIR_OUT);
    myDigitalPin.write(state);  
    setTimeout(callback, duration);
};

recurseLoop = function(sequence, myDigitalPin, state, callback) {
  var duration;
  if (!(duration = sequence.splice(0, 1)[0])) {
        switchPin(myDigitalPin, 0, 0, callback);
  } else {
        switchPin(myDigitalPin, state, duration, function() {
        recurseLoop(sequence, myDigitalPin, +(!state), callback);
    });
  }
};

runSequence = function(pin, sequence, callback) {
    
    var myDigitalPin = new mraa.Gpio(pin);
    
    recurseLoop(sequence, myDigitalPin, 1, function() {
        
    });

};

parseArgs = function(args) {
  var callback, sequence;
  sequence = args[0] instanceof Array ? args[0] : [args[0] || 1000];
  if (typeof args[1] === 'function') {
    callback = args[1];
  } else if (typeof args[2] === 'function' || args.length === 2) {
    callback = args[2];
    sequence.push(args[1]);
  } else {
    callback = args[3];
    while (args[2] -= 1) {
      sequence.push(args[1], args[0]);
    }
  }
  return [sequence, callback];
};

module.exports = {
  beep: function() {
    return runSequence.apply(this, [7].concat(parseArgs(arguments)));
  },
  green: function() {  
    return runSequence.apply(this, [10].concat(parseArgs(arguments)));
  },
  red: function() {
    return runSequence.apply(this, [9].concat(parseArgs(arguments)));
  },
  blue: function() {
    return runSequence.apply(this, [8].concat(parseArgs(arguments)));
  },
  off: function() {
    off(7);  
    off(8);
    off(9);
    off(10);
  }
    
};