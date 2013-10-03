require_relative '../spec_helper'

describe Sinatra::Application do
  context "responding to GET /repos" do
    it "should return status code 200" do
      get '/repos'
      last_response.status.should be_eql 200
      JSON.parse(last_response.body).should be_an_instance_of Array
    end
  end
end