object false

node(:type) { "FeatureCollection" }

node(:features) do 
  partial "geojson/route/index", object: @routes
end
