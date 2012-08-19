# Changelog

## v1.3.0

* Add Cassandra Adapter [rajeshucsb]
* Add option to stop stripping URL queries or Anchors. [mrtazz]

        class MyApp < Guillotine::App
          db = Sequel.sqlite
          adapter = Guillotine::Adapters::SequelAdapter.new(db)

          # OLD required host configuration, deprecated
          set :service => Guillotine::Service.new(adapter, 'github.com')

          # NEW required host configuration.
          set :service => Guillotine::Service.new(adapter,
            :required_host => 'github.com', :strip_query => false)
        end

## v1.2.1

* Fix WildcardHostChecker error responses.

## v1.2.0

* Add a simple wildcard host checker.

        Guillotine::Service.new(adapter, '*.foo.com')

* Guillotine::Adapters has been deprecated until v2.  Adapters are now in the
  top level namespace.
* Memory Adapter can be reset in tests

