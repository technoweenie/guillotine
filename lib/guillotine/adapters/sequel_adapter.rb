module Guillotine
  class SequelAdapter < Adapter
    def initialize(db)
      @db = db
      @table = @db[:urls]
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
      if existing = code_for(url)
        existing
      else
        code = get_code(url, code, options)
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
      select :url, :code => code
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
      @table.where(:url => url).delete
    end

    # Public: Removes the assigned short code.
    #
    # code - The String code to remove.
    #
    # Returns nothing.
    def clear_code(code)
      @table.where(:code => code).delete
    end

    def setup
      @db.create_table :urls do
        String :url
        String :code

        unique :url
        unique :code
      end
    end

    def select(field, query)
      if row = @table.select(field).where(query).first
        row[field]
      end
    end
  end
end
