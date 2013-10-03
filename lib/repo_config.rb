require 'gitolite'

class RepoConfig
  def initialize(conf_path)
    @repo = Gitolite::GitoliteAdmin.new(conf_path)
  end

  def users
    @repo.ssh_keys.keys
  end

  def repos
    @repo.config.repos.keys
  end

  def groups
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

  def add_group(group_name, users=nil)
    group = Gitolite::Config::Group.new(group_name)
    group.users = users if users
    @repo.config.groups[group_name] = group
  end

  def add_to_group(username, group_name)
    group = @repo.config.groups[group_name]
    group.users.push(username)
  end

  def set_permission(options)
    repo = @repo.config.get_repo(options[:repo])
    permission_to = nil
    
    if options.has_key? :user
      permission_to = [options[:user]]
    end

    if options.has_key? :users
      permission_to = options[:users]
    end

    if options.has_key? :group
      permission_to = @repo.config.groups[options[:group]].users
    end

    permissions = options[:permissions]

    repo.add_permission(permissions, "", *permission_to)
  end
end