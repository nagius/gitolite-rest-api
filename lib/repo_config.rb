require 'gitolite'

class RepoConfig
  def initialize(conf_path)
    @repo = Gitolite::GitoliteAdmin.new(conf_path)
  end

  def get_users
    @repo.ssh_keys.keys
  end

  def get_repos
    @repo.config.repos.keys
  end

  def get_groups
    result = Hash.new
    groups = @repo.config.groups
    groups.each do | key, value |
      result[key.to_sym] = value.users
    end

    result
  end

  def add_repo(repo_name)
    @repo.config.add_repo(repo_name)
  end

  def add_user(user, str_key)
    key = Gitolite::SSHKey.from_string(str_key, user)
    @repo.add_key(key)
  end

  def remove_user(username)
    key = @repo.ssh_keys.keys[username]
    key = [key] unless key.instance_of? Array

    key.each do |item|
      @repo.rm_key(item)
    end
  end

  def remove_repo(repo_name)
    @repo.rm_repo(repo_name)
  end
end