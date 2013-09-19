$(document).ready ->
  # variables
  stop = $('#stop')
  vehicle_markers = []
  route_colors = {}
  colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]

  get_schedule = (service_id) ->
    console.log service_id
    $.get "#{stop.data('id')}/schedules/#{service_id}", (data) ->
      window.times = data

      sorted_times = _.groupBy _.sortBy(data, (time) ->
        time.arrival_time
      ), (time) -> time.route_short_name

      window.sorted_times = sorted_times

      context = {
        day: $('#schedule').data('day'),
        routes: _.pairs sorted_times
      }

      window.context = context

      timetable = HandlebarsTemplates['stops/stop_times'] context
      $('#schedule').html(timetable)

  remove_old_vehicle_markers = (expiry) ->
    oldest_update_to_keep = moment().subtract(expiry, 'minutes').unix()
    old_vehicles = _.filter(vehicle_markers, (vehicle) ->
      vehicle.timestamp < oldest_update_to_keep
    )
    _.each(old_vehicles, (vehicle) ->
      vehicle.marker.clearLayers()
    )
    vehicle_markers = _.difference(vehicle_markers, old_vehicles)

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

  # remove old vehicle markers every minute
  setInterval ->
    remove_old_vehicle_markers(5)
  , 60*1000

  # show today's schedule
  service_id = $('#schedule').data('service-id')
  get_schedule service_id

  # socket.io subscriptions
  socket = io.connect "http://#{location.hostname}:5001"
  socket.on 'gtfsr/'+stop.data('id')+'/vehicle_updates', (data) ->
    vehicle_id = data.properties.vehicle_id

    # update/insert marker in vehicle_markers
    vehicle = _.findWhere(vehicle_markers, {vehicle_id: vehicle_id}) || {vehicle_id: vehicle_id}
    vehicle.timestamp = data.properties.timestamp

    vehicle.marker.clearLayers() if vehicle.marker
    vehicle.marker = L.geoJson(data, pointToLayer: (feature, coords) ->
      route = feature.properties.route

      vehicle_map_icon = L.divIcon(
        iconSize: null,
        html:"<span class='vehicle_map_text' style='border-color:#{route_colors[route]}'>#{route}</span>",
        className:"vehicle_map_icon"
      )

      vehicle_popup = "<b>to #{feature.properties.trip_headsign}</b> <br/> <small>vehicle #{feature.properties.vehicle_id} updated at #{moment.unix(feature.properties.timestamp).format("LT")}</small>"

      vehicle.marker = L.marker(coords, {icon: vehicle_map_icon}).bindPopup(vehicle_popup).addTo(map)

    ).addTo(map)

    vehicle_index = _.indexOf(vehicle_markers, vehicle)
    if vehicle_index > -1
      vehicle_markers[vehicle_index] = vehicle
    else
      vehicle_markers.push vehicle

  # subscribe to trip day updates
  socket.on 'gtfsr/trip_day_update', (service_id) ->
    $('#schedule').data('day', moment().hours(0).minutes(0).seconds(0))
    get_schedule service_id
