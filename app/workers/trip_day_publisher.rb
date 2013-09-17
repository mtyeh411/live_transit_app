class TripDayPublisher
  attr_accessor :date

  def initialize date
    @date = date 
  end

  def perform 
    $redis.set 'trip_day', find_trip_day.service_id
    $redis.publish 'trip_day_update', find_trip_day.service_id
  end

  private
  def find_trip_day 
    Gtfs::TripDay.find_by_day @date
  end
end
