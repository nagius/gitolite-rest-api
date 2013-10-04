require_relative '../spec_helper'
require 'pry'

describe Sinatra::Application do
  let(:repo_config_double) { double() }
  let(:repo_name) { 'test' }
  let(:username) { 'user' }
  let(:ssh_key) { 'ssh_key as string' }
  let(:group_name) { 'group' }
  let(:list) { Array.new }
  let(:hash) { Hash.new }
  let(:created_http_status) { 201 }
  let(:ok_http_status) { 200 }
  let(:deleted_http_status) { 204 }

  before do
    stub_const 'RepoConfig', repo_config_double

    repo_config_double.stub(:new).and_return(repo_config_double)
  end

  context "responding to GET /repos" do

    it "should return the list of repositories" do
      repo_config_double.should_receive(:repos).and_return(list)

      get '/repos'
      last_response.status.should be_eql ok_http_status
      JSON.parse(last_response.body).should be_an_instance_of Array
    end
  end

  context "responding to POST /repos" do
    it "should create the repo" do
      repo_config_double.should_receive(:add_repo).with(repo_name)

      post '/repos', :repo_name => repo_name
      last_response.status.should be_eql created_http_status
    end
  end

  context "responding to DELETE /repos" do
    it "should delete the repository" do
      repo_config_double.should_receive(:remove_repo).with(repo_name)

      delete '/repos', :repo_name => repo_name
      last_response.status.should be_eql deleted_http_status
    end
  end

  context "responding to GET /users" do

    it "should return the list of users" do
      repo_config_double.should_receive(:users).and_return(list)

      get '/users'
      last_response.status.should be_eql ok_http_status
      JSON.parse(last_response.body).should be_an_instance_of Array
    end
  end

  context "responding to POST /users" do
    it "should create the user" do
      repo_config_double.should_receive(:add_user).with(username, ssh_key)

      post '/users', :username => username, :ssh_key => ssh_key
      last_response.status.should be_eql created_http_status
    end
  end

  context "responding to GET /groups" do
    it "should return the list of groups" do
      repo_config_double.should_receive(:groups).and_return(hash)

      get '/groups'
      last_response.status.should be_eql ok_http_status
      JSON.parse(last_response.body).should be_an_instance_of Hash
    end
  end

  context "responding to POST /groups" do
    it "should create the group" do
      repo_config_double.should_receive(:add_group).with(group_name)

      post '/groups', :group_name => group_name
      last_response.status.should be_eql created_http_status
    end

    it "should create the group and add users" do
      repo_config_double.should_receive(:add_group).with(group_name, username)

      post '/groups', :group_name => group_name, :username => username
      last_response.status.should be_eql created_http_status
    end
  end

  context "responding DELETE /groups" do
    it "should delete the group with all users" do
      repo_config_double.should_receive(:remove_group).with(group_name)

      delete '/groups', :group_name => group_name
      last_response.status.should be_eql deleted_http_status
    end
  end
end