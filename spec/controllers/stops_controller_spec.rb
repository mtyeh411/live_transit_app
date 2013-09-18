require 'spec_helper'

describe StopsController do
 let!(:stop) { create(:stop) } 
  context '#show' do
    before(:each) { get :show, {:id => stop.stop_code}}

    it 'responds successfully' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it { assigns(:stop).should eq(stop) }

    it { expect(response).to render_template('show')}
  end

  context '#schedule' do
    let!(:trip_day) { create(:trip_day) }
    # TODO create stop_time_services factory

    before(:each) { get :schedule, {:stop_id => stop.stop_code, :service_id => '1_merged_416773', :format=>'json'}}

    it 'responds successfully' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it { assigns(:stop).should eq(stop) }

    # TODO create factory to test
    #it { assigns(:times).should_not be_nil  }
    #it { response.body.should == stop_times.to_json }
 end

end
