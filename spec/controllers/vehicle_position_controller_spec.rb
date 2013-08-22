require 'spec_helper'

describe VehiclePositionController do
  context 'GET show' do
    render_views

    let!(:position) { create(:vehicle_position) }

    before(:each) { get :show, {:stop_id => '21234'} }

    context 'with :stop_id' do
      it { expect(assigns(:vehicle_positions)).to eq([position]) }
      it { expect(response).to be_success }
      it { expect(response.status).to eq(200) }

      it 'should respond with json' do
        expect(response.header['Content-Type'].should include 'application/json')
        puts response.body
      end
    end
    
    context 'with :vehicle_id' do

    end
  end
end
