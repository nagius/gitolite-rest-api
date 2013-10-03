require 'sinatra'
require 'sinatra/config_file'
require 'lib/repo_config'

config_file 'config.yml'
repo_config = nil

before do
  repo_config = RepoConfig.new(settings.gitolite_root_dir)
end
