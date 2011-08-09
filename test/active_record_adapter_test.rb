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

    def test_adds_url_with_custom_code
      assert_equal 'code', @db.add('def', 'code')
      assert_equal 'def', @db.find('code')
    end

    def test_clashing_urls_raises_error
      code = @db.add '123'
      assert_raises Guillotine::DuplicateCodeError do
        code = @db.add '456', code
      end
    end
  end
rescue LoadError
  puts "skipping ActiveRecord tests: #{$!}"
end

