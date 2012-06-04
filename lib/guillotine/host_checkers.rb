module Guillotine
  class HostChecker
    def self.matching(arg)
      case arg
      when HostChecker then arg
      else (all.detect { |ch| ch.match?(arg) } || self).new(arg)
      end
    end

    def self.all
      @all ||= []
    end

    def initialize(arg = nil)
      @error_response = [422, {}, @error]
    end

    def valid?(url)
      true
    end

    def call(url)
      @error_response unless valid?(url)
    end
  end

  class RegexHostChecker < HostChecker
    def self.match?(arg)
      arg.is_a?(Regexp)
    end

    attr_reader :regex

    def initialize(regex)
      @error = "URL must match #{regex.inspect}"
      @regex = regex
      super
    end

    def valid?(url)
      url.host.to_s =~ @regex
    end
  end

  class StringHostChecker < HostChecker
    def self.match?(arg)
      arg.is_a?(String)
    end

    attr_reader :host

    def initialize(host)
      @error = "URL must be from #{host}"
      @host = host
      super
    end

    def valid?(url)
      url.host == @host
    end
  end

  HostChecker.all << RegexHostChecker << StringHostChecker
end

