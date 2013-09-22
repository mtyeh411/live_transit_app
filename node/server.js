var io = require('socket.io').listen(5001),
    redis = require('redis').createClient();

// quiet down, socket.io
io.set('log level', 1);

redis.psubscribe('gtfsr/*');

io.sockets.on('connection', function(socket) {
  // relay redis message to connected socket
  redis.on('pmessage', function(pattern, channel, message) {
    try {
      socket.emit(channel, JSON.parse(message)); 
    } catch(err) {
      console.error(err.message); 
    }
  });
});
