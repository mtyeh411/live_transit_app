require 'spec_helper'

describe RoutesController do
  let!(:stop) { create(:stop) }
  let!(:route) { create(:route) }
  let!(:trip) { create(:trip) }
  let!(:stop_time) { create(:stop_time) }

  before(:each) { get :index, {:stop_id => stop.stop_code, :format => :json} }

  it 'responds successfully' do
    expect(response).to be_success
    expect(response.status).to eq(200)
  end

  it { expect(assigns(:stop)).to eq(stop) }

  it { expect(response).to render_template('geojson/route/featurecollection') }
end
