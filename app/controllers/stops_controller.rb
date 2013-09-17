class StopsController < ApplicationController
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
end
