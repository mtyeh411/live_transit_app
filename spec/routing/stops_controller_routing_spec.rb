require 'spec_helper'

describe StopsController do
  describe 'get #show' do
    let(:resource) { 'stops' }
    let(:id) { '21234' }

    context 'nests geojson route resources' do
      let(:nested_resource) { 'routes' }

      it 'routes to routes index' do
        get("/#{resource}/#{id}/#{nested_resource}").should route_to(:controller=>nested_resource, :action=>'index', :stop_id=>id)
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

