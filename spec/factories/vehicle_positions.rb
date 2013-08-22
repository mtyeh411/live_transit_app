# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vehicle_position do
    lat "9.99"
    lon "9.99"
    bearing "9.99"
    odometer "9.99"
    speed "9.99"
    timestamp "2013-08-16 10:12:30"
    trip nil
    vehicle nil
  end
end
