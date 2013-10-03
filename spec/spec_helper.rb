require File.join(File.dirname(__FILE__), '..', 'api.rb')
require 'rack/test'
require 'json'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end