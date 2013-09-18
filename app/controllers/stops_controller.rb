class StopsController < ApplicationController
  before_action :get_trip_day

  def show
    @stop = Gtfs::Stop.find_by_stop_code params[:id]  

    respond_to do |format|
      format.html { render :show }
    end
  end

  def schedule
    @stop = Gtfs::Stop.find_by_stop_code params[:stop_id]  
    @times = @stop.stop_times.by_service_id params[:service_id]

    respond_to do |format|
      format.json { render json: @times }
    end
  end

  private
  def get_trip_day
    $redis.set 'action', action_name
    TripDayPublisher.perform unless $redis.get 'trip_day'
    @trip_day = $redis.get 'trip_day'
  end
end
