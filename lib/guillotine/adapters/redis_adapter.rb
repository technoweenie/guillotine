module Guillotine
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
    # length - The maximum length of the short code desired
    # charset - An array of characters which will be present in short code. eg. ['a', 'b', 'c', 'd', 'e', 'f']
    #
    # Returns the unique String code for the URL.  If the URL is added
    # multiple times, this should return the same code.
    def add(url, code = nil, length = nil, charset = nil)
      if existing_code = @redis.get(url_key(url))
        existing_code
      else 
        code = get_code(url, code, length, charset)
       
        if existing_url = @redis.get(code_key(code))
          raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
        end
        @redis.set code_key(code), url
        @redis.set url_key(url), code
        code
      end
    end

    # Public: Retrieves a URL from the code.
    #
    # code - The String code to lookup the URL.
    #
    # Returns the String URL, or nil if none is found.
    def find(code)
      @redis.get code_key(code)
    end

    # Public: Retrieves the code for a given URL.
    #
    # url - The String URL to lookup.
    #
    # Returns the String code, or nil if none is found.
    def code_for(url)
      @redis.get url_key(url)
    end

    # Public: Removes the assigned short code for a URL.
    #
    # url - The String URL to remove.
    #
    # Returns nothing.
    def clear(url)
      if code = @redis.get(url_key(url))
        @redis.del url_key(url)
        @redis.del code_key(code)
      end
    end

    def code_key(code)
      "guillotine:hash:#{code}"
    end

    def url_key(url)
      "guillotine:urls:#{url}"
    end
  end
end
