Gitolite-REST-API
=================

Gitolite-REST-API is a Sinatra REST API to manage gitolite repositories

Installation
------------

### Install Gitolite

Please refer to the [Gitolite documentation](http://gitolite.com/gitolite/index.html) for more information.

Once Gitolite is running, clone the gitolite-admin repository :

```
mkdir /srv/gitolite-rest-api
cd /srv/gitolite-rest-api
git clone gitolite@localhost:gitolite-admin.git
```

### Install Gitolite-REST-API

```
cd /srv/gitolite-rest-api
git clone https://github.com/nagius/gitolite-rest-api.git sinatra
cd sinatra
gem install bundle
bundle install
```

### Configure

Edit `config.yml` and set the value of `gitolite_root_dir` with the path of the gitolite-admin repository.

### Start Sinatra

 * For production

`rackup -p 4567`

 * For development

`shotgun -p 4567 api.rb`

API Reference
-------------

### Repositories

 * List repositories

`curl localhost:4567/repos`

 * Create repository

`curl -X POST localhost:4567/repos -d 'repo_name=foo'`

  * Delete repository

`curl -X DELETE localhost:4567/repos/foo`

### Users

 * List users

`curl localhost:4567/users`

 * Create user

`curl -X POST localhost:4567/users -d 'username=bob&ssh_key=ssh-rsa AAAAB[...]utFHF6k= bob@demo.site'`

 * Delete user

`curl -X DELETE localhost:4567/users/bob`

### Groups

 * List groups

`curl localhost:4567/groups`

 * Add a new group

`curl -X POST localhost:4567/groups -d 'group_name=sales'`

 * Add a user to a group

`curl -X POST localhost:4567/groups/sales/user -d 'username=bob'`

 * Remove a user from a group

`curl -X DELETE localhost:4567/groups/sales/user/bob`

 * Delete a group

`curl -X DELETE localhost:4567/groups/sales`

 * Add permission to a group

`curl -X POST localhost:4567/repos/foo/permissions -d 'group=sales&permissions=R'`

 * Add permission to a user

`curl -X POST localhost:4567/repos/foo/permissions -d 'user=bob&permissions=RW'`

 * Add permissions to many users

`curl -X POST localhost:4567/repos/foo/permissions -d 'users[]=bob&users[]=mary&permissions=RW'`

See [Gitolite documentation](http://gitolite.com/gitolite/index.html) for more information about permissions.


Testing
-------

Run `rake spec`


