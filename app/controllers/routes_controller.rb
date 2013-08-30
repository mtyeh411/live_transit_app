class RoutesController < ApplicationController
  respond_to :json

  def index
    @stop = Gtfs::Stop.find_by_stop_code(params[:stop_id])
    @routes = @stop.routes
    render template: "geojson/route/featurecollection"
  end
end
