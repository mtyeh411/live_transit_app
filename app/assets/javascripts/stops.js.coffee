$(document).ready ->
  socket = io.connect 'http://localhost:5001'

  stop = $('#stop')
  vehicle_markers = {}
  route_colors = {}
  colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]

  # setup map
  stop_coords = [stop.data('lat'), stop.data('lon')]
  map = L.mapbox.map('map', 'mtyeh411.map-g1l1wfpm').setView(stop_coords, 13)

  # mark bus stop
  stop_geojson =
    type: "Feature",
    properties:
      title: "Stop #{stop.data('id')}",
      "marker-size": "large",
      "marker-color": "#75ea0f",
      "marker-symbol": "bus"
    geometry:
      type: "Point",
      coordinates: [stop.data('lon'), stop.data('lat')]
  L.mapbox.markerLayer(stop_geojson).addTo(map)

  # fetch stop routes
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

    vehicle_markers[vehicle_id] = L.geoJson(data, pointToLayer: (feature, coords) ->
      route = feature.properties.route

      vehicle_map_icon = L.divIcon(
        iconSize: null,
        html:"<span class='vehicle_map_text' style='border-color:#{route_colors[route]}'>#{route}</span>",
        className:"vehicle_map_icon"
      )

      vehicle_popup = "<b>to #{feature.properties.trip_headsign}</b> <br/> <small>vehicle #{feature.properties.vehicle_id} updated at #{moment.unix(feature.properties.timestamp).format("LT")}</small>"

      vehicle_markers[vehicle_id] = L.marker(coords, {icon: vehicle_map_icon}).bindPopup(vehicle_popup).addTo(map)

    ).addTo(map)


