require 'spec_helper'

describe StopsController do
  let(:resource) { 'stops' }
  let(:id) { '21234' }

  describe 'get #index' do
    let(:coords) {"38.11,-77.11"}
    let(:url) {"/#{resource}/near/coords/#{coords}"}

    it 'routes to index' do
      get(url).should route_to(:controller=>resource, :action=>'index', :coords=>coords, :search_type=>'coords', :format=>:json)
    end
  end

  describe 'get #show' do

    context 'nests schedule per route' do
      let(:service_id) { 'abc123' }
      let(:url) {"/#{resource}/#{id}/schedules/#{service_id}"}

      it 'routes to stop schedule' do
        get(url).should route_to(:controller=>resource, :action=>'show_times', :id=>id, :service_id=>service_id)
      end

      it 'only serves json' do
        get("/#{url}.html").should_not be_routable
        get("/#{url}.xml").should_not be_routable
        get("/#{url}.json").should be_routable
      end
    end

    context 'nests geojson route resources' do
      let(:nested_resource) { 'routes' }
      let(:url) {"/#{resource}/#{id}/#{nested_resource}"}

      it 'routes to routes index' do
        get(url).should route_to(:controller=>nested_resource, :action=>'index', :stop_id=>id)
      end

      it 'only serves json' do
        get("/#{url}.html").should_not be_routable
        get("/#{url}.xml").should_not be_routable
        get("/#{url}.json").should be_routable
      end
    end

    it 'routes to show stop' do
      get("/#{resource}/#{id}").should route_to(:controller=>resource, :action=>'show', :id=>id )
    end

    it 'only serves html' do
      get("/#{resource}/#{id}.json").should_not be_routable
      get("/#{resource}/#{id}.xml").should_not be_routable
      get("/#{resource}/#{id}.html").should be_routable
    end

    it 'does not allow editing' do
      get("/#{resource}/#{id}/edit").should_not be_routable
    end

    it 'does not allow updating' do
      put("/#{resource}/#{id}").should_not be_routable
    end

    it 'does not allow creating' do
      post("/#{resource}").should_not be_routable
      get("/#{resource}/new").should route_to(:action=>"show", :controller=>resource, :id=>"new")
    end

    it 'does not allow deleting' do 
      delete("/#{resource}/#{id}").should_not be_routable
    end
  end
end

