class Gtfs::Trip < ActiveRecord::Base
  has_many :stop_times
  has_many :stops, :through=>:stop_times
end
