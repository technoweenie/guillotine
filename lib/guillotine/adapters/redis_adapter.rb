module Guillotine
  module Adapters
    class RedisAdapter < Adapter

      def initialize(redis)
        @redis = redis
      end

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

      def find(code)
        @redis.get "guillotine:hash:#{code}"
      end

      def code_for(url)
        @redis.get "guillotine:urls:#{url}"
      end

      def clear(url)
        if code = @redis.get("guillotine:urls:#{url}")
          @redis.del "guillotine:urls:#{url}"
          @redis.del "guillotine:hash:#{code}"
        end
      end
    end
  end
end
