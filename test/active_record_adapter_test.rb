require File.expand_path('../helper', __FILE__)

begin
  require 'active_record'
  class ActiveRecordAdapterTest < Guillotine::TestCase
    ADAPTER = Guillotine::ActiveRecordAdapter.new :adapter => 'sqlite3', :database => ':memory:'
    ADAPTER.setup

    def setup
      @db = ADAPTER
    end

    def test_adding_a_link_returns_code
      code = @db.add 'aaa'
      assert_equal 'aaa', @db.find(code)
    end

    def test_adding_duplicate_link_returns_same_code
      code = @db.add 'bbb'
      assert_equal code, @db.add('bbb')
    end

    def test_adds_url_with_custom_code
      assert_equal 'code', @db.add('ccc', 'code')
      assert_equal 'ccc', @db.find('code')
    end

    def test_clashing_urls_raises_error
      code = @db.add 'ddd'
      assert_raises Guillotine::DuplicateCodeError do
        code = @db.add 'eee', code
      end
    end

    def test_missing_code
      assert_nil @db.find('missing')
    end

    def test_gets_code_for_url
      code = @db.add 'fff'
      assert_equal code, @db.code_for('fff')
    end

    def test_clears_code_for_url
      code = @db.add 'ggg'
      assert_equal 'ggg', @db.find(code)

      @db.clear 'ggg'

      assert_nil @db.find(code)
    end
  end
rescue LoadError
  puts "skipping ActiveRecord tests: #{$!}"
end

