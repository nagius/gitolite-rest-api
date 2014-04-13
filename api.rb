require_relative 'lib/repo_config'
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'json'

config_file 'config.yml'
DELETED_STATUS = 204
CREATED_STATUS = 201
BAD_REQUEST_STATUS = 400

before do
  @repo_config = RepoConfig.new(settings.gitolite_root_dir)
end

get '/repos' do
  respond_to do |f|
    f.json { JSON.dump(@repo_config.repos) }
  end
end

post '/repos' do
  if params[:repo_name].to_s.empty?	# Check both nil and empty
    return BAD_REQUEST_STATUS
  end

  @repo_config.add_repo params[:repo_name]

  CREATED_STATUS
end

delete '/repos/:repo_name' do
  @repo_config.remove_repo params[:repo_name]

  DELETED_STATUS
end

get '/users' do
  respond_to do |f|
    f.json { JSON.dump(@repo_config.users) }
  end
end

post '/users' do
  @repo_config.add_user params[:username], params[:ssh_key]

  CREATED_STATUS
end

delete '/users/:username' do
  @repo_config.remove_user params[:username]

  DELETED_STATUS
end

get '/groups' do
  respond_to do |f|
    f.json { JSON.dump(@repo_config.groups) }
  end
end

post '/groups' do
  if params[:username]
    @repo_config.add_group params[:group_name], params[:username]
  else
    @repo_config.add_group params[:group_name]
  end

  CREATED_STATUS
end

delete '/groups/:group_name' do
  @repo_config.remove_group params[:group_name]

  DELETED_STATUS
end

delete '/groups/:group_name/user/:username' do
  @repo_config.remove_from_group params[:username], params[:group_name]

  DELETED_STATUS
end

post '/:repo/permissions' do
  keys = ['user', 'users', 'group', 'repo', 'permissions']
  method_params = {}
  keys.each do | key |
    method_params[key.to_sym] = params[key.to_sym] if params[key.to_sym]
  end

  @repo_config.set_permissions method_params
end
