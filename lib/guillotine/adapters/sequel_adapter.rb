module Guillotine
  module Adapters
    class SequelAdapter < Adapter
      def initialize(db)
        @db = db
        @table = @db[:urls]
      end
      
      # Public: Stores the shortened version of a URL.
      # 
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        if existing = code_for(url)
          existing
        else
          code ||= shorten url
          begin
            @table << {:url => url, :code => code}
          rescue Sequel::DatabaseError
            if existing_url = @table.select(:url).where(:code => code).first
              raise DuplicateCodeError.new(existing_url, url, code)
            else
              raise
            end
          end
          code
        end
      end

      # Public: Retrieves a URL from the code.
      #
      # code - The String code to lookup the URL.
      #
      # Returns the String URL.
      def find(code)
        if row = @table.select(:url).where(:code => code).first
          row[:url]
        end
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        if row = @table.select(:code).where(:url => url).first
          row[:code]
        end
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        @table.where(:url => url).delete
      end

      def setup
        @db.create_table :urls do
          string :url
          string :code

          unique :url
          unique :code
        end
      end
    end
  end
end
