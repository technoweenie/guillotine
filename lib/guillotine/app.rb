require 'sinatra/base'

module Guillotine
  class App < Sinatra::Base
    set :required_host, nil

    get "/:code" do
      code = params[:code]
      puts code.inspect
      if url = settings.db.find(Addressable::URI.escape(code))
        redirect settings.db.parse_url(url).to_s
      else
        halt 404, "No url found for #{code}"
      end
    end

    post "/" do
      url  = settings.db.parse_url params[:url].to_s

      if !(url && url.scheme =~ /^https?$/)
        halt 422, "Invalid url: #{url}"
      end

      case settings.required_host
      when String
        if url.host != settings.required_host
          halt 422, "URL must be from #{settings.required_host}"
        end
      when Regexp
        if url.host.to_s !~ settings.required_host
          halt 422, "URL must match #{settings.required_host.inspect}"
        end
      end

      begin
        if code = settings.db.add(url.to_s, params[:code])
          redirect code, 201
        else
          halt 422, "Unable to shorten #{url}"
        end
      rescue Guillotine::DuplicateCodeError => err
        halt 422, err.to_s
      end
    end
  end
end
