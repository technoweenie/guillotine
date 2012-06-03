module Guillotine
  module Adapters
    class RedisAdapter < Adapter
      # Public: Initialise the adapter with a Redis instance.
      #
      # redis - A Redis instance to persist urls and codes to.
      def initialize(redis)
        @redis = redis
      end

      # Public: Stores the shortened version of a URL.
      #
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        if existing_code = @redis.get("guillotine:urls:#{url}")
          existing_code
        else
          code ||= shorten(url)
          if existing_url = @redis.get("guillotine:hash:#{code}")
            raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
          end
          @redis.set "guillotine:hash:#{code}", url
          @redis.set "guillotine:urls:#{url}", code
          code
        end
      end

      # Public: Retrieves a URL from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns the String URL, or nil if none is found.
      def find(code)
        @redis.get "guillotine:hash:#{code}"
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        @redis.get "guillotine:urls:#{url}"
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        if code = @redis.get("guillotine:urls:#{url}")
          @redis.del "guillotine:urls:#{url}"
          @redis.del "guillotine:hash:#{code}"
        end
      end
    end
  end
end
