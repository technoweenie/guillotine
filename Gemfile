source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'test-unit'

if ENV['TRAVIS']
  gem 'sequel'
  gem 'sqlite3'
  gem 'redis'
  gem 'mongo'
  gem 'bson_ext'
  gem 'riak-client', '~> 0.9.0'
end

# Bundler isn't designed to provide optional functionality like this.  You're
# on your own
#
#group :riak do
#  gem 'riak-client'
#end
#
#group :sequel do
#  gem 'sequel'
#end
#
#group :active_record do
#  gem 'activerecord'
#end
#
#group :sequel, :active_record do
#  gem 'sqlite3'
#end
