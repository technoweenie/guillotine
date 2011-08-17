require 'sinatra/base'
require 'addressable/uri'

module Guillotine
  class App < Sinatra::Base
    set :required_host, nil

    get "/:code" do
      code = params[:code]
      if url = settings.db.find(code)
        redirect url
      else
        halt 404, "No url found for #{code}"
      end
    end

    post "/" do
      url  = Addressable::URI.parse params[:url]
      code = params[:code]

      if !(url && url.scheme =~ /^https?$/)
        halt 422, "Invalid url: #{url}"
      end

      if settings.required_host && url.host != settings.required_host
        halt 422, "URL must be from #{settings.required_host}"
      end

      begin
        if code = settings.db.add(url.to_s.strip, code)
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
