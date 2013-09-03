## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'guillotine'
  s.version           = '1.4.0'
  s.date              = '2012-12-30'
  s.rubyforge_project = 'guillotine'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Adaptable private URL shortener"
  s.description = "Adaptable private URL shortener"

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Rick Olson"]
  s.email    = 'technoweenie@gmail.com'
  s.homepage = 'https://github.com/technoweenie/guillotine'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('sinatra', "~> 1.2.6")
  s.add_dependency('addressable', "~> 2.2.6")

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('rack-test')

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    Gemfile
    LICENSE
    README.md
    Rakefile
    config/cassandra_config.json
    config/haproxy.riak.cfg
    guillotine.gemspec
    lib/guillotine.rb
    lib/guillotine/adapters/active_record_adapter.rb
    lib/guillotine/adapters/cassandra_adapter.rb
    lib/guillotine/adapters/memory_adapter.rb
    lib/guillotine/adapters/mongo_adapter.rb
    lib/guillotine/adapters/redis_adapter.rb
    lib/guillotine/adapters/riak_adapter.rb
    lib/guillotine/adapters/sequel_adapter.rb
    lib/guillotine/app.rb
    lib/guillotine/host_checkers.rb
    lib/guillotine/service.rb
    script/cibuild
    test/active_record_adapter_test.rb
    test/app_test.rb
    test/cassandra_adapter_test.rb
    test/helper.rb
    test/host_checker_test.rb
    test/memory_adapter_test.rb
    test/mongo_adapter_test.rb
    test/options_test.rb
    test/redis_adapter_test.rb
    test/riak_adapter_test.rb
    test/sequel_adapter_test.rb
    test/service_test.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/.*_test\.rb/ }
end

