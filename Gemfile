source 'http://rubygems.org'

gemspec

gem 'rake'

group :test do
  gem 'rack-test'
end

if ENV['TRAVIS']
  gem 'sequel'
  gem 'sqlite3'
  gem 'redis'
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

