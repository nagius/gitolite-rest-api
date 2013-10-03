require_relative '../../lib/repo_config'

describe RepoConfig do
  let(:gitolite_admin_class_double) { double('admin') }
  let(:gitolite_ssh_key_class_double) { double('ssh_key') }
  let(:gitolite_group_class_double) { double('group') }
  let(:gitolite_repo_class_double) { double('repo') }
  let(:method_chain_double) { double('method_chain') }
  let(:hash) { Hash.new }
  let(:list) { Array.new }
  let(:user) { 'user' }
  let(:key_string) { 'key string' }
  let(:repo) { 'repo' }
  let(:group) { 'group' }
  let(:admin_path) { 'admin_path' }
  let(:permission) { 'RW+' }
  let(:string_empty) { '' }

  let(:repo_config) do
    RepoConfig.new(admin_path)
  end

  before do
    stub_const 'Gitolite::GitoliteAdmin', gitolite_admin_class_double
    stub_const 'Gitolite::Config::Group', gitolite_group_class_double
    stub_const 'Gitolite::Config::Repo', gitolite_repo_class_double
    stub_const 'Gitolite::SSHKey', gitolite_ssh_key_class_double

    gitolite_admin_class_double.should_receive(:new).with(admin_path).and_return(gitolite_admin_class_double)
  end

  it "should list users" do
    gitolite_admin_class_double.should_receive(:ssh_keys).and_return(hash)
    hash.should_receive(:keys).and_return(list)
    
    users = repo_config.users
    users.should be_an_instance_of(Array)
  end

  it "should list repos" do
    gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
    method_chain_double.should_receive(:repos).and_return(hash)
    hash.should_receive(:keys).and_return(list)

    repos = repo_config.repos
    repos.should be_an_instance_of(Array)
  end

  it "should list user groups" do
    hash = { "repo1" => gitolite_group_class_double, "repo2" => gitolite_group_class_double }
    gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
    method_chain_double.should_receive(:groups).and_return(hash)
    gitolite_group_class_double.should_receive(:users).twice.and_return(list)

    groups = repo_config.groups
    groups.should be_an_instance_of Hash
  end

  it "should add a new repo" do
    gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
    method_chain_double.should_receive(:add_repo).with(repo).and_return(true)

    result = repo_config.add_repo repo
    result.should be_true
  end

  it "should add a new user" do
    gitolite_ssh_key_class_double.should_receive(:from_string).with(key_string, user).and_return(gitolite_ssh_key_class_double)
    gitolite_admin_class_double.should_receive(:add_key).with(gitolite_ssh_key_class_double).and_return(true)

    result = repo_config.add_user(user, key_string)
    result.should be_true
  end

  describe ".remove_user" do
    context "user has one key" do
      it "should remove the key" do
        gitolite_admin_class_double.stub_chain(:ssh_keys, :keys, :[]).with(user).and_return(gitolite_ssh_key_class_double)
        gitolite_admin_class_double.should_receive(:rm_key).once.with(gitolite_ssh_key_class_double)

        repo_config.remove_user user
      end
    end

    context "user has many keys" do
      it "should remove all keys" do
        gitolite_admin_class_double.stub_chain(:ssh_keys, :keys, :[]).with(user).and_return([gitolite_ssh_key_class_double, gitolite_ssh_key_class_double])
        gitolite_admin_class_double.should_receive(:rm_key).twice.with(gitolite_ssh_key_class_double)

        repo_config.remove_user user
      end
    end
  end

  it "should remove a repo" do
    gitolite_admin_class_double.should_receive(:rm_repo).with(repo).and_return(true)

    result = repo_config.remove_repo repo
    result.should be_true
  end

  describe ".add_group" do
    context "with no users passed as argument" do
      it "should create the group" do
        gitolite_group_class_double.should_receive(:new).with(group).and_return(gitolite_group_class_double)
        gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
        method_chain_double.should_receive(:groups).and_return(hash)
        hash.should_receive(:[]=).with(group, gitolite_group_class_double)

        repo_config.add_group group
      end
    end

    context "with an array of users passed as parameter" do
      it "should create the group and add the users" do
        gitolite_group_class_double.should_receive(:new).with(group).and_return(gitolite_group_class_double)
        gitolite_group_class_double.should_receive(:users=).with(list)
        gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
        method_chain_double.should_receive(:groups).and_return(hash)
        hash.should_receive(:[]=).with(group, gitolite_group_class_double)

        repo_config.add_group group, list
      end
    end
  end

  it "should be able to add an user in a group" do
    gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
    method_chain_double.should_receive(:groups).and_return(hash)
    hash.should_receive(:[]).with(group).and_return(gitolite_group_class_double)
    gitolite_group_class_double.should_receive(:users).and_return(list)
    list.should_receive(:push).with(user)

    repo_config.add_to_group user, group
  end

  describe ".set_permission" do
    context "with one user passed as parameter" do
      it "should set the permission for that user in that repository" do
        gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
        method_chain_double.should_receive(:get_repo).with(repo).and_return(gitolite_repo_class_double)
        gitolite_repo_class_double.should_receive(:add_permission).with(permission, string_empty, user)

        repo_config.set_permission({ :user => user,  :repo => repo, :permissions => permission })
      end
    end

    context "with many users passed as parameter" do
      it "should set the permissions to all users passed as parameter" do
        users = [user, user, user]
        gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
        method_chain_double.should_receive(:get_repo).with(repo).and_return(gitolite_repo_class_double)
        gitolite_repo_class_double.should_receive(:add_permission).with(permission, string_empty, user, user, user)

        repo_config.set_permission({ :users => users,  :repo => repo, :permissions => permission })
      end
    end

    context "with a group passed as parameter" do
      it "should add the permission to all members of the group" do
        users = [user, user, user]
        gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
        method_chain_double.should_receive(:get_repo).with(repo).and_return(gitolite_repo_class_double)

        gitolite_admin_class_double.stub_chain(:config, :groups, :[]).with(group).and_return(gitolite_group_class_double)
        gitolite_group_class_double.should_receive(:users).and_return(users)

        gitolite_repo_class_double.should_receive(:add_permission).with(permission, string_empty, user, user, user)

        repo_config.set_permission({ :group => group, :permissions => permission, :repo => repo })
      end
    end
  end
end