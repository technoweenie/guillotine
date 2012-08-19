require File.expand_path('../helper', __FILE__)

module Guillotine
  class OptionsTest < TestCase
    def test_parses_from_options
      options = Service::Options.new
      assert_equal options.object_id, Service::Options.from(options).object_id
    end

    def test_parses_from_string
      options = Service::Options.from('abc')
      assert_equal 'abc', options.required_host
      assert options.strip_query?
      assert options.strip_anchor?
    end

    def test_parses_from_regex
      options = Service::Options.from(/abc/)
      assert_equal /abc/, options.required_host
      assert options.strip_query?
      assert options.strip_anchor?
    end

    def test_parses_from_hash
      options = Service::Options.from(:strip_query => true,
        :strip_anchor => false)
      assert_nil options.required_host
      assert options.strip_query?
      assert !options.strip_anchor?
    end

    def test_parses_from_bad_hash
      assert_raises NameError do
        Service::Options.from :foo => 1
      end
    end

    def test_parses_from_unknown
      assert_raises ArgumentError do
        Service::Options.from 123
      end
    end

    def test_parses_from_empty_string
      options = Service::Options.from('')
      assert_nil options.required_host
      assert options.strip_query?
      assert options.strip_anchor?
    end

    def test_parses_from_nil
      options = Service::Options.from(nil)
      assert_nil options.required_host
      assert options.strip_query?
      assert options.strip_anchor?
    end
  end
end

