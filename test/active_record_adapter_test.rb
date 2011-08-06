require File.expand_path('../helper', __FILE__)

begin
  require 'active_record'
  class ActiveRecordAdapterTest < Guillotine::TestCase
    ADAPTER = Guillotine::Adapters::ActiveRecordAdapter.new :adapter => 'sqlite3', :database => ':memory:'
    ADAPTER.setup

    def setup
      @db = ADAPTER
    end

    def test_adding_a_link_returns_code
      code = @db.add 'abc'
      assert_equal 'abc', @db.find(code)
    end

    def test_adding_duplicate_link_returns_same_code
      code = @db.add 'abc'
      assert_equal code, @db.add('abc')
    end
  end
rescue LoadError
  puts "skipping ActiveRecord tests: #{$!}"
end

