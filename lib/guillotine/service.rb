module Guillotine
  class Service
    class NullChecker
      def call(url)
      end
    end

    # This is the public API to the Guillotine service.  Wire this up to Sinatra
    # or whatever.  Every public method should return a compatible Rack Response:
    # [Integer Status, Hash headers, String body].  
    #
    # db            - A Guillotine::Adapter instance.
    # required_host - Either a String or Regex limiting which domains the
    #                 shortened URLs can come from.
    #
    def initialize(db, required_host = nil)
      @db = db
      build_host_check(required_host)
    end

    # Public: Gets the full URL for a shortened code.
    #
    # code - A String short code.
    #
    # Returns 302 with the Location header pointing to the URL on a hit,
    # or 404 on a miss.
    def get(code)
      if url = @db.find(code)
        [302, {"Location" => @db.parse_url(url).to_s}]
      else
        [404, {}, "No url found for #{code}"]
      end
    end

    # Public: Maps a URL to a shortened code.
    #
    # url  - A String or Addressable::URI URL to shorten.
    # code - Optional String code to use.  Defaults to a random String.
    #
    # Returns 201 with the Location pointing to the code, or 422.
    def create(url, code = nil)
      url = ensure_url(url)

      if resp = check_host(url)
        return resp
      end

      begin
        if code = @db.add(url.to_s, code)
          [201, {"Location" => code}]
        else
          [422, {}, "Unable to shorten #{url}"]
        end
      rescue DuplicateCodeError => err
        [422, {}, err.to_s]
      end
    end

    # Checks to see if the input URL is using a valid host.  You can constrain
    # the hosts with the `required_host` argument of the Service constructor.
    #
    # url - An Addressible::URI instance to check.
    #
    # Returns a 422 Rack::Response if the host is invalid, or nil.
    def check_host(url)
      if url.scheme !~ /^https?$/
        [422, {}, "Invalid url: #{url}"]
      else
        @host_check.call url
      end
    end

    # Converts the `required_host` argument to a lambda for #check_host.
    #
    # host_check - Either a String or Regex limiting which domains the
    #              shortened URLs can come from.
    #
    # Returns nothing.
    def build_host_check(host_check)
      case host_check
      when nil
        @host_check = NullChecker.new
      when Regexp
        build_host_regex_check(host_check)
      else
        build_host_string_check(host_check.to_s)
      end
    end

    # Builds the host check lambda for regexes.
    #
    # regex - The Regexp that limits allowable URL hosts.
    #
    # Returns a Lambda that verifies an Addressible::URI.
    def build_host_regex_check(regex)
      @host_check = lambda do |url|
        if url.host.to_s !~ regex
          [422, {}, "URL must match #{regex.inspect}"]
        end
      end
    end

    # Builds the host check lambda for Strings.
    #
    # hostname - The String that limits allowable URL hosts.
    #
    # Returns a Lambda that verifies an Addressible::URI.
    def build_host_string_check(hostname)
      @host_check = lambda do |url|
        if url.host != hostname
          [422, {}, "URL must be from #{hostname}"]
        end
      end
    end

    # Ensures that the argument is an Addressable::URI.
    #
    # str - A String URL or an Addressable::URI.
    #
    # Returns an Addressable::URI.
    def ensure_url(str)
      if str.respond_to?(:scheme)
        str
      else
        str = str.to_s
        str.gsub! /\s/, ''
        str.gsub! /(\#|\?).*/, ''
        Addressable::URI.parse str
      end
    end
  end
end
