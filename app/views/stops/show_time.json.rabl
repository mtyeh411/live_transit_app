object @time

attributes :id, :trip_id

node(:trip_headsign) do |t|
  t.trip.trip_headsign
end

node(:route_short_name) do |t|
  t.route.route_short_name 
end

node(:route_long_name) do |t|
  t.route.route_long_name 
end

node(:arrival_time) do |t|
  Date.current.in_time_zone.to_i + t.arrival_time
end

node(:departure_time) do |t|
  Date.current.in_time_zone.to_i + t.departure_time
end
