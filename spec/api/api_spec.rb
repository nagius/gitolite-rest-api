require_relative '../spec_helper'

describe Sinatra::Application do
  context "responding to GET /repos" do

    it "should return the list of repositories" do
      get '/repos'

      last_response.status.should be_eql 200
      JSON.parse(last_response.body).should be_an_instance_of Array
    end
  end

  context "responding to GET /users" do

    it "should return the list of users" do
      get '/users'

      last_response.status.should be_eql 200
      JSON.parse(last_response.body).should be_an_instance_of Array
    end
  end

  context "responding to POST /users" do
    it "should create the repo" do
      post '/users', :username => "test"

      last_response.status.should be_eql 201
    end
  end

  context "responding to GET /groups" do

    it "should return the list of groups" do
      get '/groups'

      last_response.status.should be_eql 200
      JSON.parse(last_response.body).should be_an_instance_of Hash
    end
  end
end