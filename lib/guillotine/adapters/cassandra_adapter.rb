module Guillotine
  class CassandraAdapter < Adapter
    # Public: Initialise the adapter with a Redis instance.
    #
    # cassandra - A Cassandra instance to persist urls and codes to.
    def initialize(cassandra, read_only = false)
      @cassandra = cassandra
      @read_only = read_only
    end

    # Public: Stores the shortened version of a URL.
    #
    # url     - The String URL to shorten and store.
    # code    - Optional String code for the URL.
    # options - Optional Guillotine::Service::Options
    #
    # Returns the unique String code for the URL.  If the URL is added
    # multiple times, this should return the same code.
    def add(url, code = nil, options = nil)
      return if @read_only
      if existing_code = code_for(url)
        existing_code
      else
        code = get_code(url, code, options)

        if existing_url = find(code)
          raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
        end
        @cassandra.insert("codes", code, 'url' => url)
        @cassandra.insert("urls", url, 'code' => code)
        code
      end
    end

    # Public: Retrieves a URL from the code.
    #
    # code - The String code to lookup the URL.
    #
    # Returns the String URL, or nil if none is found.
    def find(code)
      obj = @cassandra.get("codes", code)
      obj.nil? ? nil : obj["url"]
    end

    # Public: Retrieves the code for a given URL.
    #
    # url - The String URL to lookup.
    #
    # Returns the String code, or nil if none is found.
    def code_for(url)
      obj = @cassandra.get("urls", url)
      obj.nil? ? nil : obj["code"]
    end

    # Public: Removes the assigned short code for a URL.
    #
    # url - The String URL to remove.
    #
    # Returns nothing.
    def clear(url)
      if code = code_for(url)
        purge(code, url)
      end
    end

    # Public: Removes the assigned short code.
    #
    # code - The String code to remove.
    #
    # Returns nothing.
    def clear_code(url)
      if url = find(code)
        purge(code, url)
      end
    end

    def purge(code, url)
      @cassandra.remove("urls", url)
      @cassandra.remove("codes", code)
    end
  end
end
