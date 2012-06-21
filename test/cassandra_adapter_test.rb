require File.expand_path('../helper', __FILE__)

begin
  require "rubygems"
  require "cassandra"
  require 'cassandra/mock'

  class CassandraAdapterTest < Guillotine::TestCase
    @test_schema = JSON.parse(File.read(File.join(File.expand_path(File.dirname(__FILE__)), '..','config', 'cassandra_config.json')))
    @cassandra_mock = Cassandra::Mock.new('url_shortener', @test_schema)
    @cassandra_mock.clear_keyspace!
    ADAPTER = Guillotine::CassandraAdapter.new @cassandra_mock

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
      code = @db.add 'abc'
      assert_raise Guillotine::DuplicateCodeError do
        @db.add 'ghi', code
      end
    end

    def test_missing_code
      assert_nil @db.find('missing')
    end

    def test_gets_code_for_url
      code = @db.add 'abc'
      assert_equal code, @db.code_for('abc')
    end

    def test_clears_code_for_url
      code = @db.add 'abc'
      assert_equal 'abc', @db.find(code)

      @db.clear 'abc'

      assert_nil @db.find(code)
    end

    def test_read_only
      Guillotine::CassandraAdapter.new @cassandra_mock, true
      code = @db.add 'abc'
      assert_equal nil, code
    end
  end

rescue LoadError
  puts "Skipping Cassandra tests: #{$!}"
end
