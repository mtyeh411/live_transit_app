object @trip_update

node(:trip_id) do |t|
  t.trip_update.trip.trip_id
end

node(:arrival) do |t|
  t.trip_update.stop_time_update.first.arrival.delay
end

node(:uncertainty) do |t|
  t.trip_update.stop_time_update.first.arrival.uncertainty
end
