require 'sinatra/base'

module Guillotine
  class App < Sinatra::Base
    get "/:code" do
      code = params[:code]
      if url = settings.db.find(code)
        redirect url
      else
        halt 404, "No url found for #{code}"
      end
    end

    post "/" do
      url = params[:url]
      if code = settings.db.add(url)
        redirect code
      else
        halt 500, "Unable to shorten #{url}"
      end
    end
  end
end
