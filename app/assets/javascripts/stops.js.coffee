$(document).ready ->
  # variables
  stop = $('#stop')
  stop_coords = [stop.data('lat'), stop.data('lon')]
  service_id = $('#schedule').data('service-id')

  vehicle_markers = []
  scrollers = {}
  route_colors = {}
  colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]
  scroller_item_width = 131 # default

  window.socket = io.connect "http://#{location.hostname}:5001"
  map = L.mapbox.map('map', 'mtyeh411.map-g1l1wfpm').setView(stop_coords, 16)

  # subscribe to vehicle updates
  socket.on "gtfsr/#{stop.data('code')}/vehicle_updates", (data) ->
    update_vehicle_marker data

  # subscribe to trip day updates
  socket.on 'gtfsr/trip_day_update', (data) ->
    $('#schedule').data('day', moment().hours(0).minutes(0).seconds(0))
    $('#schedule').data('service-id', data.service_id)
    get_schedule data.service_id

  # subscribe to stop trip updates
  socket.on "gtfsr/#{stop.data('code')}/trip_update_updates", (data) ->
    jq_time = $(".time[data-trip-id='#{data.trip_id}']")
    new_time = jq_time.data('scheduled-arrival') + data.arrival
    punctuality = if data.arrival>0 then 'late' else 'early'
    jq_time.attr('data-timestamp', new_time)
    jq_time.attr('data-punctuality', punctuality)
    jq_time.html("#{moment.unix(new_time).format('h:mm A')}*")

    _.each $('.route'), (e) ->
      sort_times e.id

  # sort times for a route
  sort_times = (route) ->
    times = _.sortBy $("##{route} .scroller li"), (time) ->
      return $(time).attr('data-timestamp')
    $("##{route} .scroller ul").html times


  # scroll timetable for route to time that are nearest to timestamp
  scroll_to_nearest_time = (route, timestamp) ->
    selector = "##{route} .scroller li"

    next_arrival = ($(selector).filter (index) ->
      $(this).data('timestamp') > timestamp
    ).first()

    if next_arrival.data()
      if moment.unix(next_arrival.data('timestamp')).diff(moment(), 'minutes') < 30
        index = $(selector).index(next_arrival)+1
        show_next_arrival route, next_arrival.data()
      else
        index = $(selector).index(next_arrival)
    else
      index = $(selector).length

    scrollers[route].scrollTo (index)*scroller_item_width*-1, 0, '2ms'
   
  # scroll to nearest times
  scroll_to_nearest_times = (timestamp) ->
    _.each $('.route'), (e) ->
      scroll_to_nearest_time e.id, timestamp

  # show next arrival time given route DOM id and next arrival data
  show_next_arrival = (route, data) ->
    content = "#{moment.unix(data['timestamp']).format('h:mm A')}#{if data['punctuality'] then '*' else ''} to #{data.tripHeadsign}"
    punctuality = data['punctuality'] || ''
    $("##{route} .next-arrival").html(content).attr('data-punctuality', punctuality)

  # get schedule
  get_schedule = (service_id) ->
    $.get "#{stop.data('code')}/schedules/#{service_id}", (data) ->
      sorted_times = _.groupBy _.sortBy(data, (time) ->
        time.arrival_time
      ), (time) -> time.route_short_name

      context = {
        day: $('#schedule').data('day'),
        routes: _.pairs sorted_times
      }

      timetable = HandlebarsTemplates['stops/stop_times'] context
      $('#schedule').html(timetable)
      scroller_item_width = $('.scroller li.time').outerWidth()
      _.each $('.scroller'), (el) ->
        $(el).width ($(el).find('li').length+5)*scroller_item_width
      
      # set up scrollers
      _.each $('.route'), (e) ->
        selector = "##{e.id} .scroller-wrapper"
        scroller = new IScroll selector, {
          #mouseWheel: true,
          scrollX: true,
          scrollY: false,
          keyBinding: true,
          snap: $("##{e.id} .scroller li"),
          snapSpeed: 1000,
          click: true
        }
        scrollers[e.id] = scroller

      window.scrollers = _.clone scrollers

      scroll_to_nearest_times moment().unix()

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
        html:"
          <div class='vehicle_marker_icon' style='background-color:#{route_colors[route]}; transform:rotate(#{135+feature.properties.bearing}deg); -webkit-transform:rotate(#{135+feature.properties.bearing}deg); -moz-transform:rotate(#{135+feature.properties.bearing}deg);'>
            <div class='map-text' style='transform:rotate(#{215-feature.properties.bearing}deg); -webkit-transform:rotate(#{215-feature.properties.bearing}deg); -moz-transform:rotate(#{215-feature.properties.bearing}deg)'>#{route}</div>
          </div>
        ",
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
    $.get "#{stop.data('code')}/routes.json", (data) ->
      L.geoJson(data, style: (feature) ->
        route_name = feature.properties.short_name

        if !route_colors[route_name]
          route_colors[route_name] = colors[color_index]
          color_index++

        color: route_colors[route_name],
        opacity: 0.2
      ).addTo(map)

  # timed methods
  setInterval ->
    remove_old_vehicle_markers(5)
    scroll_to_nearest_times moment().unix()
  , 60*1000

  setup_map()
  get_schedule service_id

  $('#nearest-arrival').on 'click', (e) ->
    scroll_to_nearest_times moment().unix()

  true
