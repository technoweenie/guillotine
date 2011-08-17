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
      url  = params[:url].to_s
      code = params[:code]

      if url.empty?
        halt 422, "Invalid url: #{url.inspect}"
      end
      url.strip!

      begin
        if code = settings.db.add(url, code)
          redirect code
        else
          halt 422, "Unable to shorten #{url}"
        end
      rescue Guillotine::DuplicateCodeError => err
        halt 422, err.to_s
      end
    end
  end
end
