object @vehicle

node(:type) { 'Feature' }

node(:properties) do |v|
  {
    :id => :id,
    :timestamp => v.vehicle.timestamp,
    :trip_id => v.vehicle.trip.trip_id.to_i,
    :vehicle_id => v.vehicle.vehicle.id.to_i
  }
end

node(:geometry) do |v| 
  { :type=>'Point', :coordinates=>[v.vehicle.position.longitude, v.vehicle.position.latitude] }
end
