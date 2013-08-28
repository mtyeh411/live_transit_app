$(document).ready ->
  socket = io.connect 'http://localhost:5001'
  stop = $('#stop')

  # setup map
  stop_coords = [stop.data('lat'), stop.data('lon')]
  map = L.mapbox.map('map', 'examples.map-uci7ul8p').setView(stop_coords, 13)

  # subscribe to vehicle updates
  socket.on 'gtfsr/'+stop.data('id')+'/vehicle_updates', (data) ->
    L.geoJson(data).addTo(map)

