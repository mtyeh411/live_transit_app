class TripDayPublisher
  def self.logger
    @@logger ||= Logger.new("#{Rails.root}/log/trip_day_publisher.log")
  end

  def self.perform 
    trip_day = find_trip_day

    if trip_day
      self.logger.info("found trip with service_id #{trip_day.service_id} for #{Date.current}")
      $redis.set 'trip_day', trip_day.service_id
      $redis.publish 'gtfsr/trip_day_update', trip_day.service_id
    end
  end

  private
  def self.find_trip_day 
    Gtfs::TripDay.find_by_day Date.current.in_time_zone.to_i
  end
end
