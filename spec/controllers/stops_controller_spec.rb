require 'spec_helper'

describe StopsController do
 let!(:stop) { create(:stop) } 

 before(:each) { get :show, {:id => stop.id}}

 it 'responds successfully' do
  expect(response).to be_success
  expect(response.status).to eq(200)
 end

 it { expect(assigns(:stop)).to eq(stop) }

 it { expect(response).to render_template('show')}
end
