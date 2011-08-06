require 'active_record'

module Guillotine
  module Adapters
    class ActiveRecordAdapter < Adapter
      class Url < ActiveRecord::Base; end

      def initialize(config)
        Url.establish_connection config
      end
      
      def add(url)
        if row = Url.select(:code).where(:url => url).first
          row[:code]
        else
          code = shorten url
          Url.create :url => url, :code => code
          code
        end
      end

      def find(code)
        if row = Url.select(:url).where(:code => code).first
          row[:url]
        end
      end

      def setup
        Url.connection.create_table :urls do |t|
          t.string :url, :unique => true
          t.string :code, :unique => true
        end
      end
    end
  end
end
