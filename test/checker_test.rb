require File.expand_path('../helper', __FILE__)

module Guillotine
  class NullCheckerTest < TestCase
    Checker = Guillotine::Service::NullChecker.new

    def test_allows_all_urls
      [nil, '', 'abc'].each do |url|
        assert_nil Checker.call(url), url.inspect
      end
    end
  end
end

