module Gitio
  module Adapters
    class SequelAdapter < Adapter
      def initialize(db)
        @db = db
        @table = @db[:urls]
      end
      
      def add(url)
        if row = @table.select(:code).where(:url => url).first
          row[:code]
        else
          code = shorten url
          @table << {:url => url, :code => code}
          code
        end
      end

      def find(code)
        if row = @table.select(:url).where(:code => code).first
          row[:url]
        end
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
