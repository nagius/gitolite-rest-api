require_relative '../../lib/repo_config'

describe RepoConfig do
  let(:gitolite_admin_class_double) { double('admin') }
  let(:gitolite_ssh_key_class_double) { double('ssh_key') }
  let(:method_chain_double) { double('method_chain') }
  let(:hash) { Hash.new }
  let(:list) { Array.new }
  let(:user) { 'user' }
  let(:key_string) { 'key string' }
  let(:repo) { 'repo' }
  let(:admin_path) { 'admin_path' }

  let(:repo_config) do
    RepoConfig.new(admin_path)
  end

  before do
    stub_const 'Gitolite::GitoliteAdmin', gitolite_admin_class_double
    stub_const 'Gitolite::SSHKey', gitolite_ssh_key_class_double

    gitolite_admin_class_double.should_receive(:new).with(admin_path).and_return(gitolite_admin_class_double)
  end

  it "should list users" do
    gitolite_admin_class_double.should_receive(:ssh_keys).and_return(hash)
    hash.should_receive(:keys).and_return(list)
    
    users = repo_config.get_users
    users.should be_an_instance_of(Array)
  end

  it "should list repos" do
    gitolite_admin_class_double.should_receive(:config).and_return(method_chain_double)
    method_chain_double.should_receive(:repos).and_return(hash)
    hash.should_receive(:keys).and_return(list)

    repos = repo_config.get_repos
    repos.should be_an_instance_of(Array)
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
end