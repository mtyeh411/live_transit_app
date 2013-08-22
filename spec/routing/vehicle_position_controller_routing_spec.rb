require 'spec_helper'

describe VehiclePositionController do
  let(:stop_route) { '/vehicle_positions/stop/21234' }

  it 'routes to stop_route' do
    get(stop_route).should route_to(:controller => 'vehicle_position', :action => 'show', :stop_id => '21234')
  end

  context 'when a non-valid format is requested' do
    it 'should not route' do
      get(stop_route + '.html').should_not be_routable
      get(stop_route + '.xml').should_not be_routable
    end
  end

  context 'when json format is requested' do
    it 'should route' do
      get(stop_route + '.json').should be_routable
    end
  end
end

