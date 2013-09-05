class Gtfsr::VehiclePosition 
  include ActiveModel::Validations

  attr_reader :id, :timestamp, :vehicle_id, :trip_id, :stop_id, :lat, :lon, :bearing, :odometer, :speed

  validates :lat, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :lon, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :bearing, numericality: { less_than: 360 }
  validates :odometer, numericality: { less_than: 1000000 }
  validates :speed, numericality: { less_than: 100 }

  def initialize(feed_entity)
    @id =  feed_entity.id
    @timestamp = feed_entity.vehicle.timestamp

    @trip_id = feed_entity.vehicle.trip.trip_id
    @stop_id = feed_entity.vehicle.stop_id
    @vehicle_id = feed_entity.vehicle.vehicle.id 

    @lat = feed_entity.vehicle.position.latitude
    @lon = feed_entity.vehicle.position.longitude
    @bearing = feed_entity.vehicle.position.bearing
    @odometer = feed_entity.vehicle.position.odometer
    @speed = feed_entity.vehicle.position.speed
  end

  def to_param
    @id
  end

  def trip
    Gtfs::Trip.includes(:route).find_by_trip_id(@trip_id)
  end

  def stop
    Gtfs::Trip.find_by_stop_id(@stop_id)
  end
end
