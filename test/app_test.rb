require File.expand_path('../helper', __FILE__)

class AppTest < Guillotine::TestCase
  ADAPTER = Guillotine::Adapters::MemoryAdapter.new
  Guillotine::App.set :db, ADAPTER

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

  def test_adding_duplicate_link_returns_same_code
    url  = 'http://github.com'
    code = ADAPTER.add url

    post '/', :url => url
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

  def test_rejects_non_http_urls
    post '/', :url => 'ftp://abc.com'
    assert_equal 422, last_response.status
  end

  def test_reject_shortened_url_from_other_domain
    Guillotine::App.set :required_host, 'abc.com'
    post '/', :url => 'http://github.com'
    assert_equal 422, last_response.status
    assert_match /must be from abc\.com/, last_response.body

    post '/', :url => 'http://abc.com/def'
    assert_equal 201, last_response.status
  ensure
    Guillotine::App.set :required_host, nil
  end

  def test_reject_shortened_url_from_other_domain_by_regex
    Guillotine::App.set :required_host, /abc\.com$/
    post '/', :url => 'http://github.com'
    assert_equal 422, last_response.status
    assert_match /must match \/abc\\.com/, last_response.body

    post '/', :url => 'http://abc.com/def'
    assert_equal 201, last_response.status

    post '/', :url => 'http://www.abc.com/def'
    assert_equal 201, last_response.status
  ensure
    Guillotine::App.set :required_host, nil
  end

  def app
    Guillotine::App
  end
end
