# Guillotine

Simple URL Shortener hobby kit.  Currently used to shorten URLs at GitHub.com, and also available as a an [installable Heroku app](https://github.com/mrtazz/katana).

## USAGE

The easiest way to use it is with the built-in memory adapter.

```ruby
# app.rb
require 'guillotine'
module MyApp
  class App < Guillotine::App
    adapter = Guillotine::Adapters::MemoryAdapter.new
    set :service => Guillotine::Service.new(adapter)

    get '/' do
      redirect 'https://homepage.com'
    end
  end
end
```

```ruby
# config.ru
require "rubygems"
require File.expand_path("../app.rb", __FILE__)
run MyApp::App
```

Once it's running, add URLs with a simple POST.

    curl http://localhost:4567 -i \
      -F "url=http://techno-weenie.net"

You can specify your own code too:

    curl http://localhost:4567 -i \
      -F "url=http://techno-weenie.net" \
      -F "code=abc"

## Sequel

The memory adapter sucks though.  You probably want to use a DB.  Check
out the [Sequel gem](http://sequel.rubyforge.org/) for more examples.
It'll support SQLite, MySQL, PostgreSQL, and a bunch of other databases.

```ruby
require 'guillotine'
require 'sequel'
module MyApp
  class App < Guillotine::App
    db = Sequel.sqlite
    adapter = Guillotine::Adapters::SequelAdapter.new(db)
    set :service => Guillotine::Service.new(adapter)
  end
end
```

You'll need to initialize the DB schema with something like this
(depending on which DB you use):

```
CREATE TABLE IF NOT EXISTS `urls` (
  `url` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  UNIQUE KEY `url` (`url`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

## Redis

Redis works well, too.  The sample below is [adapted](https://github.com/mrtazz/katana/blob/master/app.rb) from [Katana](https://github.com/mrtazz/katana), a hosted wrapper around Guillotine designed for Heroku.

```ruby
require 'guillotine'
require 'redis'

module MyApp
  class App < Guillotine::App
    # use redis adapter with redistogo on Heroku
    uri = URI.parse(ENV["REDISTOGO_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    adapter = Guillotine::Adapters::RedisAdapter.new(redis)
    set :service => Guillotine::Service.new(adapter)
  end
end
```

## Riak

If you need to scale out your url shortening services across the cloud,
you can use Riak!

```ruby
require 'guillotine'
require 'riak/client'
module MyApp
  class App < Guillotine::App
    client = Riak::Client.new :protocol => 'pbc', :pb_port => 8087
    bucket = client['guillotine']
    adapter = Guillotine::Adapters::RiakAdapter.new(bucket)
    set :service => Guillotine::Service.new(adapter)
  end
end
```

## Cassandra

you can use Cassandra!

```ruby
require 'guillotine'
require 'cassandra'

module MyApp
  class App < Guillotine::App
    cassandra = Cassandra.new('Cassandra', '127.0.0.1:9160')
    adapter = Guillotine::Adapters::CassandraAdapter.new(cassandra)

    set :service => Guillotine::Service.new(adapter)
  end
end```

You need to create keyspace and column families as below

```sql
CREATE KEYSPACE url_shortener;
USE url_shortener;

CREATE COLUMN FAMILY urls
WITH comparator = UTF8Type
AND key_validation_class=UTF8Type
AND column_metadata = [{column_name: code, validation_class: UTF8Type}];

CREATE COLUMN FAMILY codes
WITH comparator = UTF8Type
AND key_validation_class=UTF8Type
AND column_metadata = [{column_name: url, validation_class: UTF8Type}];
```sql

## Domain Restriction

You can restrict what domains that Guillotine will shorten.

```ruby
require 'guillotine'
module MyApp
  class App < Guillotine::App
    adapter = Guillotine::Adapters::MemoryAdapter.new
    # only this domain
    set :service => Guillotine::Service.new(adapter,
      'github.com')

    # or, any *.github.com domain
    set :service => Guillotine::Service.new(adapter,
      /(^|\.)github\.com$/)

    # or set a simple wildcard
    set :service => Guillotine::Servicew.new(adapter,
      '*.github.com')
  end
end
```

## Not TODO

* Statistics
* Authentication
