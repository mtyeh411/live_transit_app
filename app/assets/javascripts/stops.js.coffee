$(document).ready ->
  stop = $('#stop')
  stop_coords = [stop.data('lat'), stop.data('lon')]
  service_id = $('#schedule').data('service-id')
  
  # colors from the BYR color wheel
  colors = [
    "hsl(60, 99%, 60%)", # 12
    "hsl(286, 98%, 35%)", # 6
    "hsl(223, 100%, 50%)", # 3
    "hsl(198, 99%, 41%)", # 9

    "hsl(45, 100%, 49%)", # 1
    "hsl(262, 100%, 32%)", # 7
    "hsl(18, 98%, 51%)", # 4
    "hsl(95, 56%, 44%)", # 10

    "hsl(36, 98%, 49%)", # 2
    "hsl(223, 100%, 50%)", # 8
    "hsl(338, 75%, 37%)", #5
    "hsl(68, 82%, 54%)", # 11
  ]

  vehicle_markers = []
  scrollers = {}
  route_colors = {}
  color_index = 0
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
      if moment.unix(next_arrival.data('timestamp')).diff(moment(), 'minutes') < 60
        index = $(selector).index(next_arrival)
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

      # TODO DRY these hbs templates
      timetable = HandlebarsTemplates['stops/stop_times'] context
      arrivals = HandlebarsTemplates['stops/arrivals'] context
      $('#schedule').html(timetable)
      $('.next-arrivals').html(arrivals)

      # tack on space at the end for 'no more time' msg
      _.each $('.scroller'), (el) ->
        $(el).width ($(el).find('li').length+5)*scroller_item_width

      colorize_timetable()
      
      # scrollers
      scroller_item_width = $('.scroller li.time').outerWidth()
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
      scroll_to_nearest_times moment().unix()
  
      # schedule controls
      $('#schedule-controls #toggle-timetable.btn').removeClass('hidden')
      $('#schedule').addClass('hidden') # must not be hidden in order to initiate scroller

      # schedule control events
      $('#nearest-arrival').on 'click', (e) ->
        scroll_to_nearest_times moment().unix()

      $('#toggle-timetable').on 'click', (e) ->
        if $('#schedule').is(':visible')
          action = 'addClass'
          text = 'Show timetable'
        else
          action = 'removeClass'
          text = 'Hide timetable'

        $('#schedule')[action]('hidden')
        $('#schedule-controls .title')[action]('hidden')
        $('#schedule-controls #nearest-arrival.btn')[action]('hidden')
        $('#toggle-timetable').text text

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
      route_name = "route-#{feature.properties.route}"

      vehicle_map_icon = L.divIcon(
        iconSize: null,
        html:"
          <div class='vehicle_marker_icon' style='background-color:#{route_colors[route_name]}; transform:rotate(#{135+feature.properties.bearing}deg); -webkit-transform:rotate(#{135+feature.properties.bearing}deg); -moz-transform:rotate(#{135+feature.properties.bearing}deg);'>
            <div class='map-text' style='transform:rotate(#{215-feature.properties.bearing}deg); -webkit-transform:rotate(#{215-feature.properties.bearing}deg); -moz-transform:rotate(#{215-feature.properties.bearing}deg)'>#{feature.properties.route}</div>
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

  # style route geojson feature
  style_route_feature = (feature) ->
    route_name = "route-#{feature.properties.short_name}"

    if !route_colors[route_name]
      route_colors[route_name] = colors[color_index]
      color_index++

    color: route_colors[route_name],
    opacity: 0.2
  
  # gets called on each route feature before adding to geojson layer
  on_each_route_feature = (feature, layer) ->
    layer.bindPopup "<b>Route #{feature.properties.short_name}</b><br/><small>#{feature.properties.long_name}</small>"

  # show route colors on stop_times timetable/schedule
  colorize_timetable = () ->
    $.each $('.route .color-box'), (i, el) ->
      $(this).css 'background-color', route_colors[$(this).closest('.route').attr('id')]

  # setup map
  setup_map = () ->
    stop_geojson =
      type: "Feature",
      properties:
        title: "Stop #{stop.data('id')}",
        "marker-size": "large",
        "marker-color": "#555",
        "marker-symbol": "bus"
      geometry:
        type: "Point",
        coordinates: [stop.data('lon'), stop.data('lat')]

    L.mapbox.markerLayer(stop_geojson).addTo(map)

    $.get "#{stop.data('code')}/routes.json", (data) ->
      window.routes = data
      L.geoJson(data,
        style: style_route_feature,
        onEachFeature: on_each_route_feature,
      ).addTo(map)
      colorize_timetable()

  # timed methods
  setInterval ->
    remove_old_vehicle_markers(5)
    scroll_to_nearest_times moment().unix()
  , 60*1000

  setInterval ->
    $('#current-time').text moment().format('MM/DD/YYYY h:mm A')
  , 1000

  setup_map()
  get_schedule service_id

  true
