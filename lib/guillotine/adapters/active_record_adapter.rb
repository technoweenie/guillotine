require 'active_record'

module Guillotine
  module Adapters
    class ActiveRecordAdapter < Adapter
      class Url < ActiveRecord::Base; end

      def initialize(config)
        Url.establish_connection config
      end
      
      # Public: Stores the shortened version of a URL.
      # 
      # url  - The String URL to shorten and store.
      # code - Optional String code for the URL.
      #
      # Returns the unique String code for the URL.  If the URL is added
      # multiple times, this should return the same code.
      def add(url, code = nil)
        if row = Url.select(:code).where(:url => url).first
          row[:code]
        else
          code ||= shorten url
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
        if row = Url.select(:url).where(:code => code).first
          row[:url]
        end
      end

      # Public: Retrieves the code for a given URL.
      #
      # url - The String URL to lookup.
      #
      # Returns the String code, or nil if none is found.
      def code_for(url)
        if row = Url.select(:code).where(:url => url).first
          row[:code]
        end
      end

      # Public: Removes the assigned short code for a URL.
      #
      # url - The String URL to remove.
      #
      # Returns nothing.
      def clear(url)
        Url.where(:url => url).delete_all
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
    end
  end
end
