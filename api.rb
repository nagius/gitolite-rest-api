require_relative 'lib/repo_config'
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'json'

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

post '/repos' do
  repo_config.add_repo params[:repo_name]

  201
end

get '/users' do
  respond_to do |f|
    f.json { JSON.dump(repo_config.users) }
  end
end

post '/users' do
  repo_config.add_user params[:username], params[:ssh_key]

  201
end

get '/groups' do
  respond_to do |f|
    f.json { JSON.dump(repo_config.groups) }
  end
end

post '/groups' do
  repo_config.add_group params[:group_name]

  201
end