path = lambda { | *x |  File.join(File.dirname(__FILE__), x) }

require_relative path.call('..','lib/repo_config')
require 'gitolite'
require 'pry'