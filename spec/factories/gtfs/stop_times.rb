# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stop_time, :class=>Gtfs::StopTime do
    stop_id 1
    trip_id 1
  end
end
