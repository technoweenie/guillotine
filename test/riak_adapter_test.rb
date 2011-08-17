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
    CODE_BUCKET = client['guillotine-code-test']
    URL_BUCKET  = client['guillotine-url-test']
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
      code = @db.add 'abc'
      assert_equal code, @db.add('abc')

      URL_BUCKET.delete Digest::SHA1.hexdigest('abc')
      CODE_BUCKET.delete code
    end

    def test_adds_url_with_custom_code
      assert_equal 'code', @db.add('def', 'code')
      assert_equal 'def', @db.find('code')

      URL_BUCKET.delete Digest::SHA1.hexdigest('def')
      CODE_BUCKET.delete 'code'
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
  end
rescue LoadError
  puts "Skipping Riak tests: #{$!}"
end

