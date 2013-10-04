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
    repo = Gitolite::Config::Repo.new(repo_name)
    @repo.config.add_repo(repo)
    save "added repo #{repo_name} (by API)"
  end

  def add_user(user, str_key)
    key = Gitolite::SSHKey.from_string(str_key, user)
    @repo.add_key(key)
    save "added user: #{user} (by API)"
  end

  def remove_user(username)
    key = @repo.ssh_keys.keys[username]
    key = [key] unless key.instance_of? Array

    key.each do |item|
      @repo.rm_key(item)
    end

    save "removed user #{username} (by API)"
  end

  def remove_repo(repo_name)
    @repo.rm_repo(repo_name)
    save "removed repo #{repo_name} (by API)"
  end

  def add_group(group_name, users=nil)
    group = Gitolite::Config::Group.new(group_name)
    group.users = users if users
    @repo.config.groups[group_name] = group
    save "added group #{group_name} (by API)"
  end

  def add_to_group(username, group_name)
    group = @repo.config.groups[group_name]
    group.users.push(username)
    save "added #{username} to group #{group_name} (by API)"
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
    save "gave permission[#{permissions}] to #{permission_to} in #{repo}"
  end

  private
    def save(commit_msg)
      @repo.save_and_apply(commit_msg)
    end
end