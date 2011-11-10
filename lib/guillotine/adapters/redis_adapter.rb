require "json"

module Guillotine
  module Adapters
    # Stores shorterned URL in memory^H^H^H^H Redis. Fully web scale.
    class RedisAdapter < MemoryAdapter

      # Public: Set the Redis instance so we can persist urls and hashes into
      # Redis.
      #
      # redis - The Redis instance to persist to.
      def initialize(redis)
        @redis = redis
        @urls = JSON.parse(@redis.get("guillotine:urls") || "{}")
        @hash = JSON.parse(@redis.get("guillotine:hash") || "{}")
      end

      # Public: Stores the shortened version of a URL and persists to Redis.
      # 
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        code = super(url, code)
        persist_to_redis
        code
      end

      # Public: Removes the assigned short code for a URL and persists to
      # Redis.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        super(url)
        persist_to_redis
      end

      # Persist the URLs and Hashes to Redis.
      #
      # Returns nothing.
      def persist_to_redis
        @redis.set "guillotine:urls", @urls.to_json
        @redis.set "guillotine:hash", @hash.to_json
      end
    end
  end
end
