$(document).ready ->
  socket = io.connect 'http://localhost:5001'
  stop = $('#stop')
  vehicle_markers = {}
  route_colors = {}
  colors = ["red", "green", "blue", "yellow"]

  # setup map
  stop_coords = [stop.data('lat'), stop.data('lon')]
  map = L.mapbox.map('map', 'examples.map-uci7ul8p').setView(stop_coords, 13)

  # fetch route geojson data
  color_index = 0
  $.get "#{stop.data('id')}/routes.json", (data) ->
    L.geoJson(data, style: (feature) ->
      route_name = feature.properties.short_name

      if !route_colors[route_name]
        route_colors[route_name] = colors[color_index]
        color_index++

      color: route_colors[route_name],
      opacity: 0.2
    ).addTo(map)

  # subscribe to vehicle updates
  socket.on 'gtfsr/'+stop.data('id')+'/vehicle_updates', (data) ->
    vehicle_id = data.properties.vehicle_id
    vehicle_markers[vehicle_id].clearLayers() if vehicle_markers[vehicle_id]
    vehicle_markers[vehicle_id] = L.geoJson(data).addTo(map)

