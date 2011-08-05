require File.expand_path('../helper', __FILE__)

class AppTest < Guillotine::TestCase
  ADAPTER = Guillotine::Adapters::MemoryAdapter.new
  Guillotine::App.set :db, ADAPTER

  include Rack::Test::Methods

  def test_adding_a_link_returns_code
    url = 'http://github.com'
    post '/', :url => url
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

  def app
    Guillotine::App
  end
end
