require 'active_record'

module Guillotine
  class ActiveRecordAdapter < Adapter
    class Url < ActiveRecord::Base; end

    def initialize(config)
      Url.establish_connection config
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
      if row = Url.select(:code).where(:url => url).first
        row[:code]
      else
        code = get_code(url, code, options)

        begin
          Url.create :url => url, :code => code
        rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid
          row = Url.select(:url).where(:code => code).first
          existing_url = row && row[:url]
          raise DuplicateCodeError.new(existing_url, url, code)
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
      Url.where(:url => url).delete_all
    end

    # Public: Removes the assigned short code.
    #
    # code - The String code to remove.
    #
    # Returns nothing.
    def clear_code(code)
      Url.where(:code => code).delete_all
    end

    def setup
      conn = Url.connection
      conn.create_table :urls do |t|
        t.string :url
        t.string :code
      end

      conn.add_index :urls, :url, :unique => true
      conn.add_index :urls, :code, :unique => true
    end

    def select(field, query)
      if row = Url.select(field).where(query).first
        row[field]
      end
    end
  end
end
