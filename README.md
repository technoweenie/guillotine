# Guillotine

Simple URL Shortener hobby kit.

## USAGE

The easiest way to use it is with the built-in memory adapter.

```ruby
# app.rb
require 'guillotine'
module MyApp
  class App < Guillotine::App
    set :db => Guillotine::Adapters::MemoryAdapter.new

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

The memory adapter sucks though.  You probably want to use a DB.

```ruby
require 'guillotine'
require 'sequel'
module MyApp
  class App < Guillotine::App
    set :db => Guillotine::Adapters::SequelAdapter.new(Sequel.sqlite)
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
    set :db => Guillotine::Adapters::RiakAdapter.new(bucket)
  end
end
```

## Domain Restriction

You can restrict what domains that Guillotine will shorten.

```ruby
require 'guillotine'
module MyApp
  class App < Guillotine::App
    # only this domain
    set :required_host, 'github.com'

    # or, any *.github.com domain
    set :required_host, /(^|\.)github\.com$/
  end
end
```

## Not TODO

* Statistics
* Authentication
