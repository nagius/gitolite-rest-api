require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'json'
require_relative 'lib/repo_config'

config_file 'config.yml'
repo_config = nil

before do
  repo_config = RepoConfig.new(settings.gitolite_root_dir)
end

get '/repos' do
  respond_to do |f|
    f.json { JSON.dump(repo_config.repos) }
  end
end