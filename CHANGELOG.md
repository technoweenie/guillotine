# Changelog

## master

* Add a simple wildcard host checker.

        Guillotine::Service.new(adapter, '*.foo.com')

* Guillotine::Adapters has been deprecated until v2.  Adapters are now in the
  top level namespace.
* Memory Adapter can be reset in tests

