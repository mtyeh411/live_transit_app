class VehiclePositionController < ApplicationController
  before_filter :default_format_json

  respond_to :json

  def show
    @vehicle_positions = VehiclePosition.all if params[:stop_id]
    #PrivatePub.publish_to('/messages/new', positions: @vehicle_positions)
    respond_with(@vehicle_positions)
  end

  private
  def default_format_json
    request.format = 'json'
  end
end
