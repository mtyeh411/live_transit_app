var io = require('socket.io').listen(5001),
    redis = require('redis').createClient();

// subscribe to redis
redis.psubscribe('gtfsr/*');

io.sockets.on('connection', function(socket) {
  // relay redis message to connected socket
  redis.on('pmessage', function(pattern, channel, message) {
    socket.emit(channel, JSON.parse(message)); 
  });
});
