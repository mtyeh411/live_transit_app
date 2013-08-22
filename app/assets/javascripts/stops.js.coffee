$(document).ready ->
  socket = io.connect 'http://localhost:5001'
  stop_id = $('#stop').data('id')

  # setup map
  stop_coords = [39.182,-77.264]
  map = L.mapbox.map('map', 'examples.map-uci7ul8p').setView(stop_coords, 13)

  # subscribe to vehicle updates
  socket.on 'gtfsr/'+stop_id+'/vehicle_updates', (data) ->
    L.geoJson(data).addTo(map)

