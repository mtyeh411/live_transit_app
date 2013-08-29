# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stop, :class=>Gtfs::Stop do
    stop_id 17133
    stop_code 17133
    stop_name 'SILVER SPRING STATION & BAY R'
    stop_lat 38.993447
    stop_lon -77.028685
  end
end
