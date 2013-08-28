class StopsController < ApplicationController
  respond_to :html

  def show
    @stop = Gtfs::Stop.find_by_stop_code params[:id]  
  end
end
