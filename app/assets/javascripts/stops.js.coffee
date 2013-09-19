$(document).ready ->
  # variables
  stop = $('#stop')
  stop_coords = [stop.data('lat'), stop.data('lon')]
  service_id = $('#schedule').data('service-id')

  vehicle_markers = []
  scrollers = []
  route_colors = {}
  colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]

  socket = io.connect "http://#{location.hostname}:5001"
  map = L.mapbox.map('map', 'mtyeh411.map-g1l1wfpm').setView(stop_coords, 13)

  # subscribe to vehicle updates
  socket.on 'gtfsr/'+stop.data('id')+'/vehicle_updates', (data) ->
    update_vehicle_marker data

  # subscribe to trip day updates
  socket.on 'gtfsr/trip_day_update', (service_id) ->
    $('#schedule').data('day', moment().hours(0).minutes(0).seconds(0))
    get_schedule service_id

  # get schedule
  get_schedule = (service_id) ->
    $.get "#{stop.data('id')}/schedules/#{service_id}", (data) ->
      sorted_times = _.groupBy _.sortBy(data, (time) ->
        time.arrival_time
      ), (time) -> time.route_short_name

      context = {
        day: $('#schedule').data('day'),
        routes: _.pairs sorted_times
      }

      timetable = HandlebarsTemplates['stops/stop_times'] context
      $('#schedule').html(timetable)
      
      # WORKING ON SCROLLERS
      _.each $('.route'), (e) ->
        selector = "##{e.id} .scroller-wrapper"
        scroller = new IScroll selector, {
          mouseWheel: true,
          scrollX: true,
          scrollY: false,
          keyBinding: true,
          #snap: true,
          #snapSpeed: 400
        }

  # remove old vehicle markers
  remove_old_vehicle_markers = (expiry) ->
    oldest_update_to_keep = moment().subtract(expiry, 'minutes').unix()
    old_vehicles = _.filter(vehicle_markers, (vehicle) ->
      vehicle.timestamp < oldest_update_to_keep
    )
    _.each(old_vehicles, (vehicle) ->
      vehicle.marker.clearLayers()
    )
    vehicle_markers = _.difference(vehicle_markers, old_vehicles)

  # update vehicle marker
  update_vehicle_marker = (data) ->
    vehicle_id = data.properties.vehicle_id

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

  # setup map
  setup_map = () ->
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

  setup_map()
  get_schedule service_id
  setInterval ->
    remove_old_vehicle_markers(5)
  , 60*1000
  
  document.addEventListener 'touchmove', (e) ->
    e.preventDefault()
  , false

  true
