require File.expand_path('../helper', __FILE__)

module Guillotine
  class MatchingCheckerTest < TestCase
    def test_regex_checker_is_matched
      checker = HostChecker.matching(/a/)
      assert_kind_of RegexHostChecker, checker
      assert_equal /a/, checker.regex
    end

    def test_wildcard_checker_is_matched
      checker = HostChecker.matching('*.foo.com')
      assert_kind_of WildcardHostChecker, checker
      assert_equal 'foo.com', checker.host
    end

    def test_string_checker_is_matched
      checker = HostChecker.matching('foo.com')
      assert_kind_of StringHostChecker, checker
      assert_equal 'foo.com', checker.host
    end

    def test_hostchecker_matches_self
      checker = HostChecker.new
      assert_equal checker, HostChecker.matching(checker)
    end
  end

  class CheckerTest < TestCase
    def test_allows_urls
      allowed_urls.each do |url|
        assert_nil checker.call(uri(url)), url
      end
    end

    def test_rejects_urls
      rejected_urls.each do |url|
        assert res = checker.call(uri(url)), "#{checker.inspect} matched #{url.inspect}"
        assert_equal 422, res.first, res.inspect
      end
    end

    def allowed_urls
      ['abc']
    end

    def rejected_urls
      []
    end

    def checker
      @checker ||= build_checker
    end

    def build_checker
      HostChecker.new
    end

    def uri(url)
      Addressable::URI.parse "http://#{url}"
    end
  end

  class WildcardHostCheckerTest < CheckerTest
    def build_checker
      WildcardHostChecker.new '*.foo.com'
    end

    def allowed_urls
      %w(foo.com foo.com/a abc.foo.com/a)
    end

    def rejected_urls
      %w(bar.com foo.com.uk foobcom)
    end

    def test_parses_host
      assert_equal 'foo.com', checker.host
    end

    def test_builds_custom_error
      assert_match /must be from foo\.com/, checker.error_response[2]
    end
  end

  class StringHostCheckerTest < CheckerTest
    def build_checker
      StringHostChecker.new('foo.com')
    end

    def allowed_urls
      %w(foo.com foo.com/a)
    end

    def rejected_urls
      %w(bar.com)
    end
  end

  class RegexHostCheckerTest < CheckerTest
    def build_checker
      RegexHostChecker.new(/a/)
    end

    def allowed_urls
      %w(abc.com aaa.com)
    end

    def rejected_urls
      %w(b.com)
    end
  end
end

