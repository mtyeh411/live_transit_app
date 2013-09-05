object @vehicle

node(:type) { 'Feature' }

node(:properties) do |v|
  {
    :id => v.id,
    :timestamp => v.timestamp,
    :trip_id => v.trip_id,
    :vehicle_id => v.vehicle_id,
    :route => v.trip.route.route_short_name,
    :trip_headsign => v.trip.trip_headsign
  }
end

node(:geometry) do |v| 
  { :type=>'Point', :coordinates=>[v.lon, v.lat] }
end
