require 'spec_helper'

describe "Cloud Tunnel Redirect App" do

  describe "GET /" do
    it "should return a 404 by default" do
      get '/'
      last_response.should be_not_found
    end

    it "should return a 404 if a route is not matched" do
      get 'http://test1.myapp.com'
      last_response.should be_not_found
    end

    it "should redirect if a route is matched" do
      Route.create(:source => 'test1', :destination => 'http://somewhere.else.com')
      get 'http://test1.myapp.com/'
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == 'http://somewhere.else.com/'
    end
  end

  describe "POST /route" do
    it "should return 403 if invalid parameters" do
      post '/route', {:foo => 'test', :bar => 'dev.example.com'}
      last_response.status.should == 403
    end

    it "should be successful if a route is updated" do
      Route.create(:source => 'test', :destination => 'somewhere.else.com')
      post '/route', {:source => 'test', :destination => 'dev.example.com'}
      last_response.should be_ok
    end

    it "should be successful if a route is created" do
      post '/route', {:source => 'test', :destination => 'dev.example.com'}
      last_response.should be_ok
    end
  end

  describe "DELETE /route" do
    it "should be successful if a route is delted" do
      Route.create(:source => 'test_delete', :destination => 'somewhere.else.com')
      lambda do
        delete '/route', {:source => 'test_delete'}
      end.should change{Route.count}.by(-1)
      last_response.should be_ok
    end

    it "should return a 404 if the route does not exist" do
      delete '/route', {:source => 'test_not_found'}
      last_response.should be_not_found
    end

    it "should return 403 if invalid parameters" do
      delete '/route', {:foo => 'test'}
      last_response.status.should == 403
    end
  end
end
