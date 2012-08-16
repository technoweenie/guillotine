require File.expand_path('../helper', __FILE__)

module Guillotine
  class AppTest < TestCase
    ADAPTER = MemoryAdapter.new
    SERVICE = Service.new(ADAPTER)
    App.set :service, SERVICE

    include Rack::Test::Methods

    def test_adding_a_link_returns_code
      url = 'http://github.com'
      post '/', :url => url
      assert_equal 201, last_response.status
      assert code_url = last_response.headers['Location']
      code = code_url.gsub(/.*\//, '')

      get "/#{code}"
      assert_equal 302, last_response.status
      assert_equal url, last_response.headers['Location']
    end

    def test_adding_a_link_with_query_params_strips_query
      query_url = 'http://github.com?a=1'
      url = 'http://github.com'
      post '/', :url => query_url
      assert_equal 201, last_response.status
      assert code_url = last_response.headers['Location']
      code = code_url.gsub(/.*\//, '')

      get "/#{code}"
      assert_equal 302, last_response.status
      assert_equal url, last_response.headers['Location']
    end

    def test_adding_a_link_with_query_params_returns_code
      with_service :strip_query => false do
        url = 'http://github.com?a=1'
        post '/', :url => url
        assert_equal 201, last_response.status
        assert code_url = last_response.headers['Location']
        code = code_url.gsub(/.*\//, '')

        get "/#{code}"
        assert_equal 302, last_response.status
        assert_equal url, last_response.headers['Location']
      end
    end

    def test_adding_a_link_with_anchor_strips_anchor
      query_url = 'http://github.com?a=1#a'
      url = 'http://github.com'
      post '/', :url => query_url
      assert_equal 201, last_response.status
      assert code_url = last_response.headers['Location']
      code = code_url.gsub(/.*\//, '')

      get "/#{code}"
      assert_equal 302, last_response.status
      assert_equal url, last_response.headers['Location']
    end

    def test_adding_a_link_with_anchor_params_returns_code
      with_service :strip_anchor => false do
        url = 'http://github.com#a'
        post '/', :url => url
        assert_equal 201, last_response.status
        assert code_url = last_response.headers['Location']
        code = code_url.gsub(/.*\//, '')

        get "/#{code}"
        assert_equal 302, last_response.status
        assert_equal url, last_response.headers['Location']
      end
    end

    def test_adding_duplicate_link_returns_same_code
      url  = 'http://github.com'
      code = ADAPTER.add url

      post '/', :url => url + '#a=1'
      assert code_url = last_response.headers['Location']
      assert_equal code, code_url.gsub(/.*\//, '')
    end

    def test_adds_url_with_custom_code
      url = 'http://github.com/abc'
      post '/', :url => url, :code => 'code'
      assert code_url = last_response.headers['Location']
      assert_match /\/code$/, code_url

      get "/code"
      assert_equal 302, last_response.status
      assert_equal url, last_response.headers['Location']
    end

    def test_adds_url_with_custom_code
      url = 'http://github.com/abc'
      post '/', :url => url, :code => '%E2%9C%88'
      assert code_url = last_response.headers['Location']
      assert_match /\/%E2%9C%88$/, code_url

      get "/%E2%9C%88"
      assert_equal 302, last_response.status
      assert_equal url, last_response.headers['Location']
    end

    def test_redirects_to_split_url
      url = "http://abc.com\nhttp//def.com"
      ADAPTER.hash['split'] = url
      ADAPTER.urls[url]     = 'split'

      get '/split'
      assert_equal "http://abc.comhttp//def.com", last_response.headers['location']
    end

    def test_clashing_urls_raises_error
      code = ADAPTER.add 'http://github.com/123'
      post '/', :url => 'http://github.com/456', :code => code
      assert_equal 422, last_response.status
    end

    def test_add_without_url
      post '/'
      assert_equal 422, last_response.status
    end

    def test_add_url_with_linebreak
      post '/', :url => "https://abc.com\n"
      assert_equal 'http://example.org/SWtBvQ', last_response.headers['location']
    end

    def test_adds_split_url
      post '/', :url => "https://abc.com\nhttp://abc.com"
      assert_equal 'http://example.org/cb5CNA', last_response.headers['location']

      assert_equal 'https://abc.comhttp//abc.com', ADAPTER.find('cb5CNA')
    end

    def test_rejects_non_http_urls
      post '/', :url => 'ftp://abc.com'
      assert_equal 422, last_response.status
    end

    def test_reject_shortened_url_from_other_domain
      App.set :service, Service.new(ADAPTER, 'abc.com')
      post '/', :url => 'http://github.com'
      assert_equal 422, last_response.status
      assert_match /must be from abc\.com/, last_response.body

      post '/', :url => 'http://abc.com/def'
      assert_equal 201, last_response.status
    ensure
      Guillotine::App.set :required_host, nil
    end

    def test_reject_shortened_url_from_other_domain_by_regex
      with_service /abc\.com$/ do
        post '/', :url => 'http://github.com'
        assert_equal 422, last_response.status
        assert_match /must match \/abc\\.com/, last_response.body

        post '/', :url => 'http://abc.com/def'
        assert_equal 201, last_response.status

        post '/', :url => 'http://www.abc.com/def'
        assert_equal 201, last_response.status
      end
    end

    def test_get_without_code_returns_default_url
      with_service :default_url => 'http://google.com' do
        get '/'
        assert_equal "http://google.com", last_response.headers['location']
      end
    end

    def test_get_without_code_no_default_url
      get '/'
      assert_equal nil, last_response.headers['location']
    end

    def app
      App
    end

    def with_service(options)
      App.set :service, Service.new(ADAPTER, options)
      yield
    ensure
      App.set :service, SERVICE
    end
  end
end

