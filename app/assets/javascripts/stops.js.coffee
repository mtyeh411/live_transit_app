$(document).ready ->
  socket = io.connect 'http://localhost:5001'
  stop = $('#stop')
  vehicle_markers = {}

  # setup map
  stop_coords = [stop.data('lat'), stop.data('lon')]
  map = L.mapbox.map('map', 'examples.map-uci7ul8p').setView(stop_coords, 13)

  # fetch route geojson data
  $.get "#{stop.data('id')}/routes.json", (data) ->
    L.geoJson(data).addTo(map)

  # subscribe to vehicle updates
  socket.on 'gtfsr/'+stop.data('id')+'/vehicle_updates', (data) ->
    vehicle_id = data.properties.vehicle_id
    vehicle_markers[vehicle_id].clearLayers() if vehicle_markers[vehicle_id]
    vehicle_markers[vehicle_id] = L.geoJson(data).addTo(map)

