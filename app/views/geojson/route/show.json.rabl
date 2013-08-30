object @route

node(:type) { 'Feature' }

node(:properties) do |r|
  {
    :agency_id => r.agency_id,
    :short_name => r.route_short_name,
    :long_name => r.route_long_name
  }
end

node(:geometry) do |r|
  {
    :type => 'MultiLineString',
    :coordinates => r.coordinates
  }
end
