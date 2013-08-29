# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stop_time, :class=>Gtfs::StopTime do
    stop_id 17133
    trip_id 399785
    stop_sequence 1
    arrival_time 78900
    departure_time 78900
  end
end
