module Guillotine
  # Stores shortened URLs in memory.  Totally scales.
  class MemoryAdapter < Adapter
    attr_reader :hash, :urls
    def initialize
      reset
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
      if existing_code = @urls[url]
        existing_code
      else
        code = get_code(url, code, length, charset)
        
        if existing_url = @hash[code]
          raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
        end
        @hash[code] = url
        @urls[url]  = code
        code
      end
    end

    # Public: Retrieves a URL from the code.
    #
    # code - The String code to lookup the URL.
    #
    # Returns the String URL, or nil if none is found.
    def find(code)
      @hash[code]
    end

    # Public: Retrieves the code for a given URL.
    #
    # url - The String URL to lookup.
    #
    # Returns the String code, or nil if none is found.
    def code_for(url)
      @urls[url]
    end

    # Public: Removes the assigned short code for a URL.
    #
    # url - The String URL to remove.
    #
    # Returns nothing.
    def clear(url)
      if code = @urls.delete(url)
        @hash.delete code
      end
    end

    def reset
      @hash = {}
      @urls = {}
    end
  end
end
