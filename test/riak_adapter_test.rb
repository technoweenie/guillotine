require File.expand_path('../helper', __FILE__)

begin
  require 'riak/client'

  # Assumes a local dev install of riak is setup
  #
  #   http://wiki.basho.com/Building-a-Development-Environment.html
  # 
  # Riak should be accessible from:
  #
  #   http://localhost:8091/riak/guillotine-test
  class RiakAdapterTest < Guillotine::TestCase
    client      = Riak::Client.new(:http_port => 8091)
    CODE_BUCKET = client["guillotine-code-test-#{Process.pid}"]
    URL_BUCKET  = client["guillotine-url-test-#{Process.pid}"]
    ADAPTER = Guillotine::Adapters::RiakAdapter.new CODE_BUCKET, URL_BUCKET

    def setup
      @db = ADAPTER
    end

    def test_adding_a_link_returns_code
      code = @db.add 'abc'
      assert_equal 'abc', @db.find(code)

      URL_BUCKET.delete Digest::SHA1.hexdigest('abc')
      CODE_BUCKET.delete code
    end

    def test_adding_duplicate_link_returns_same_code
      code = @db.add 'Abc'
      assert_equal code, @db.add('ABc')

      URL_BUCKET.delete Digest::SHA1.hexdigest('abc')
      CODE_BUCKET.delete code
    end

    def test_adds_url_with_custom_code
      code = '%E2%9C%88'
      assert_equal code, @db.add('def', code)
      assert_equal 'def', @db.find(code)

      URL_BUCKET.delete Digest::SHA1.hexdigest('def')
      CODE_BUCKET.delete code
    end

    def test_adds_url_with_missing_url_key
      url  = 'inconsistent'
      code = "#{url}_code"
      sha  = @db.url_key url
      url_obj = URL_BUCKET.new sha
      url_obj.content_type = Guillotine::Adapters::RiakAdapter::PLAIN
      url_obj.data = code
      url_obj.store

      assert_nil @db.find(code)

      added_code = @db.add url

      assert_equal code, added_code
      assert_equal url, @db.find(code)
    end

    def test_clashing_urls_raises_error
      code = @db.add 'abc'
      assert_raises Guillotine::DuplicateCodeError do
        @db.add 'def', code
      end

      URL_BUCKET.delete Digest::SHA1.hexdigest('abc')
      URL_BUCKET.delete Digest::SHA1.hexdigest('def')
      CODE_BUCKET.delete code
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

    def test_clears_code_for_url
      code = @db.add 'abc'
      assert_equal 'abc', @db.find(code)

      @db.clear 'abc'

      assert_nil @db.find(code)
    end
  end
rescue LoadError
  puts "Skipping Riak tests: #{$!}"
end

