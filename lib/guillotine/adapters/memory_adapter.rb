module Guillotine
  module Adapters
    # Stores shortened URLs in memory.  Totally scales.
    class MemoryAdapter < Adapter
      def initialize
        @hash = {}
        @urls = {}
      end

      # Public: Stores the shortened version of a URL.
      # 
      # url - The String URL to shorten and store.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url)
        if code = @urls[url]
          code
        else
          code = shorten(url)
          @hash[code] = url
          @urls[url]  = code
          code
        end
      end

      # Public: Retrieves a URL from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns the String URL.
      def find(code)
        @hash[code]
      end
    end
  end
end
