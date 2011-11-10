require 'mongo'

module Guillotine
  module Adapters
    class MongoAdapter < Adapter
      def initialize(collection)
        @collection = collection
        @collection.ensure_index([['url',  Mongo::ASCENDING]])
      end
      
      # Public: Stores the shortened version of a URL.
      # 
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        code_for(url) || insert(url, code || shorten(url))
      end

      
      # Public: Retrieves a URL from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns the String URL, or nil if none is found.
      def find(code)
        @collection.find_one({_id: code}, {transformer: lambda {|doc| doc['url'] }})
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        @collection.find_one({url: url}, {transformer: lambda {|doc| doc['_id'] }})
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        @collection.remove(url: url)
      end
      
      private
      def insert(url, code)
        if existing_url = find(code)
          raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
        end
        @collection.insert({_id: code, url: url})
        code
      end

    end
  end
end