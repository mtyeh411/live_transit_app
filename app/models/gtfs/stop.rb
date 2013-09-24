class Gtfs::Stop < ActiveRecord::Base
  has_many :stop_times, :foreign_key => "stop_id", :primary_key => "stop_id"
  has_many :trips, :through => :stop_times
  has_many :routes, -> {distinct}, :through => :trips

  acts_as_mappable :lat_column_name => :stop_lat, :lng_column_name => :stop_lon

  def geometry
    {
      :type => "Point",
      :coordinates => [stop_lon, stop_lat]
    }
  end

  def to_param
    self.stop_code
  end

  def times_by_service service_id
    Gtfs::Stop.joins('INNER JOIN stop_time_services ON stop_time_services.stop_id=stops.stop_id').
    where('stop_time_services.stop_id = ? AND stop_time_services.service_id = ?', self.stop_id, service_id) 
  end
end
