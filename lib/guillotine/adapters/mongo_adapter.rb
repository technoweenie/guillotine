require 'mongo'

module Guillotine
  module Adapters
    class MongoAdapter < Adapter
      def initialize(collection)
        @collection = collection
        @collection.ensure_index([['url',  Mongo::ASCENDING]])

        # \m/
        @transformers = {
          :url => lambda { |doc| doc['url'] },
          :code => lambda { |doc| doc['_id'] }
        }
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
        select :url, :_id => code
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        select :code, :url => url
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        @collection.remove(:url => url)
      end

      def select(field, query)
        @collection.find_one(query, {:transformer => @transformers[field]})
      end
      
    private
      def insert(url, code)
        if existing_url = find(code)
          raise DuplicateCodeError.new(existing_url, url, code) if url != existing_url
        end
        @collection.insert(:_id => code, :url => url)
        code
      end
    end
  end
end
