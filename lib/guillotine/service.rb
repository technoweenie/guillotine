module Guillotine
  class Service
    # Deprecated until v2
    NullChecker = Guillotine::HostChecker

    class Options < Struct.new(:required_host, :strip_query, :strip_anchor)
      def self.from(value)
        case value
        when nil, "" then new
        when String, Regexp then new(value)
        when Hash then
          opt = new
          value.each do |key, value|
            opt[key] = value
          end
          opt
        when self then value
        else
          raise ArgumentError, "Unable to convert to Options: #{value.inspect}"
        end
      end

      def strip_query?
        strip_query != false
      end

      def strip_anchor?
        strip_anchor != false
      end

      def host_checker
        @host_checker ||= HostChecker.matching(required_host)
      end
    end

    attr_reader :db, :options

    # This is the public API to the Guillotine service.  Wire this up to Sinatra
    # or whatever.  Every public method should return a compatible Rack Response:
    # [Integer Status, Hash headers, String body].
    #
    # db            - A Guillotine::Adapter instance.
    # required_host - Either a String or Regex limiting which domains the
    #                 shortened URLs can come from.
    #
    def initialize(db, value = nil)
      @db = db
      @options = Options.from(value)
    end

    # Public: Gets the full URL for a shortened code.
    #
    # code - A String short code.
    #
    # Returns 302 with the Location header pointing to the URL on a hit,
    # or 404 on a miss.
    def get(code)
      if url = @db.find(code)
        [302, {"Location" => parse_url(url).to_s}]
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
        @options.host_checker.call url
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
        parse_url(str.to_s)
      end
    end

    def parse_url(url)
      @db.parse_url(url, @options)
    end
  end
end
