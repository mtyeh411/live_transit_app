$(document).ready ->
  $('#search button').on 'click', (e) ->
    fetch_stops $('#search input').val()

  $(document).keypress (e) ->
    fetch_stops $('#search input').val() if e.which == 13 # ENTER

  fetch_stops = (location) ->
    $.get "stops/near/#{location}", (data) ->
      stops = HandlebarsTemplates['stops/stops'] data
      $('#stops').html stops

  fetch_stops_near_me = (position) ->
    fetch_stops "#{position.coords.latitude},#{position.coords.longitude}"
    $('#search input').attr('placeholder', 'Current location')

  if navigator.geolocation
    navigator.geolocation.getCurrentPosition fetch_stops_near_me

