FactoryGirl.define do
  factory :route, :class=>Gtfs::Route do
    route_id 2640
    agency_id "MCRO"
    route_short_name "1"
    route_long_name "Silver Spring-Friendship Heights"
    route_desc nil
    route_type 3
    route_url "http://someurl.com"
    route_color "0000FF"
    route_text_color "FFFFFF"
  end
end
