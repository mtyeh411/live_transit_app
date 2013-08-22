class VehiclePosition < ActiveRecord::Base
  belongs_to :trip
  belongs_to :vehicle

  validates :lat, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :lon, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :bearing, numericality: { less_than: 360 }
  validates :odometer, numericality: { less_than: 1000000 }
  validates :speed, numericality: { less_than: 100 }

  def geometry
    {
      :type => "Point",
      :coordinates => [lon, lat] 
    }
  end
end
