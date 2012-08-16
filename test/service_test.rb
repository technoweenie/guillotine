require File.expand_path('../helper', __FILE__)

module Guillotine
  class ServiceTest < TestCase
    def setup
      @db = MemoryAdapter.new
      @service = Service.new @db
    end

    def test_adding_a_link_returns_code
      url = 'http://github.com'
      status, head, body = @service.create(url)
      assert_equal 201, status
      assert code_url = head['Location']
      code = code_url.gsub(/.*\//, '')

      status, head, body = @service.get(code)
      assert_equal 302, status
      assert_equal url, head['Location']
    end

    def test_adding_a_link_with_query_param_returns_code
      url = 'http://github.com?a=1'
      status, head, body = @service.create(url)
      assert_equal 201, status
      assert code_url = head['Location']
      code = code_url.gsub(/.*\//, '')

      status, head, body = @service.get(code)
      assert_equal 302, status
      assert_equal url, head['Location']
    end

    def test_adding_duplicate_link_returns_same_code
      url  = 'http://github.com'
      code = @db.add url

      status, head, body = @service.create(url + '#a=1')
      assert code_url = head['Location']
      assert_equal code, code_url.gsub(/.*\//, '')
    end

    def test_adds_url_with_custom_code
      url = 'http://github.com/abc'

      status, head, body = @service.create(url, 'code')
      assert code_url = head['Location']
      assert_equal 'code', code_url

      status, head, body = @service.get('code')
      assert_equal 302, status
      assert_equal url, head['Location']
    end

    def test_adds_url_with_custom_unicode
      url = 'http://github.com/abc'
      status, head, body = @service.create(url, '%E2%9C%88')
      assert code_url = head['Location']
      assert_match /^%E2%9C%88$/, code_url

      status, head, body = @service.get("%E2%9C%88")
      assert_equal 302, status
      assert_equal url, head['Location']
    end

    def test_redirects_to_split_url
      url = "http://abc.com\nhttp//def.com"
      @db.hash['split'] = url
      @db.urls[url] = 'split'

      status, head, body = @service.get('split')
      assert_equal "http://abc.comhttp//def.com", head['Location']
    end

    def test_clashing_urls_raises_error
      code = @db.add 'http://github.com/123'
      status, head, body = @service.create('http://github.com/456', code)
      assert_equal 422, status
    end

    def test_add_without_url
      status, head, body = @service.create(nil)
      assert_equal 422, status
    end

    def test_add_url_with_linebreak
      status, head, body = @service.create("https://abc.com\n")
      assert_equal 'SWtBvQ', head['Location']
    end

    def test_adds_split_url
      status, head, body = @service.create("https://abc.com\nhttp://abc.com")
      assert_equal 'cb5CNA', head['Location']

      assert_equal 'https://abc.comhttp//abc.com', @db.find('cb5CNA')
    end

    def test_rejects_non_http_urls
      status, head, body = @service.create('ftp://abc.com')
      assert_equal 422, status
    end

    def test_reject_shortened_url_from_other_domain
      service = Service.new @db, 'abc.com'
      status, head, body = service.create('http://github.com')
      assert_equal 422, status
      assert_match /must be from abc\.com/, body

      status, head, body = service.create('http://abc.com/def')
      assert_equal 201, status
    end

    def test_reject_shortened_url_from_other_domain_by_regex
      service = Service.new @db, /abc\.com$/
      status, head, body = service.create('http://github.com')
      assert_equal 422, status
      assert_match /must match \/abc\\.com/, body

      status, head, body = service.create('http://abc.com/def')
      assert_equal 201, status

      status, head, body = service.create('http://www.abc.com/def')
      assert_equal 201, status
    end

    def test_fixed_charset_code
      @db = MemoryAdapter.new
      length = 4
      char_set = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
      @service = Service.new @db, :length => length, :charset => char_set

      url = 'http://github.com'
      status, head, body = @service.create(url)
      assert_equal 201, status
      assert code_url = head['Location']

      assert_equal 4, code_url.length
      code_url.each_char do |c|
        assert char_set.include?(c)
      end
    end
  end
end

