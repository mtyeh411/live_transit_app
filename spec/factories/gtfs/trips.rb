# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip, :class=>Gtfs::Trip do
    trip_id 399785
    route_id 2640
    service_id '1_merged_416773'
    trip_headsign 'Friendship Heights'
    block_id 'b_54428'
    shape_id 11048
  end
end
