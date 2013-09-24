class StopsController < ApplicationController
  before_action :get_trip_day

  def show
    @stop = Gtfs::Stop.find_by_stop_code params[:id]  

    respond_to do |format|
      format.html { render :show }
    end
  end

  # TODO move to StopTimesController
  def show_times 
    @stop = Gtfs::Stop.find_by_stop_code params[:id]  
    @times = @stop.stop_times.by_service_id params[:service_id]

    respond_to do |format|
      format.json { render :show_times }
    end
  end

  def index
    coords = params[:location].match /(-*\d+.?\d+),(-*\d+.?\d+)/
    if coords
      origin = [coords[1], coords[2]]
    else
      origin = "#{params[:location]}, Montgomery County MD"
    end

    @stops = Gtfs::Stop.within(0.25, :origin => origin).select(:stop_code, :stop_name, :wheelchair_boarding, :stop_lat, :stop_lon)

    respond_to do |format|
      format.json { render :json => @stops }
    end
  end

  private
  def get_trip_day
    TripDayPublisher.perform unless $redis.get 'trip_day'
    @trip_day = $redis.get 'trip_day'
  end
end
