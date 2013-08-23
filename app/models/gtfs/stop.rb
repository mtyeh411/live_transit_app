class Gtfs::Stop < ActiveRecord::Base
  has_many :stop_times, :foreign_key => "stop_id", :primary_key => "stop_id"
  has_many :trips, :through => :stop_times

  def geometry
    {
      :type => "Point",
      :coordinates => [stop_lon, stop_lat]
    }
  end

  def to_param
    self.stop_code
  end
end
