require 'sinatra/base'

module Guillotine
  class App < Sinatra::Base
    set :required_host, nil

    get "/:code" do
      code = params[:code]
      if url = settings.db.find(Addressable::URI.escape(code))
        redirect settings.db.parse_url(url).to_s
      else
        halt 404, simple_escape("No url found for #{code}")
      end
    end

    post "/" do
      url  = settings.db.parse_url params[:url].to_s

      if !(url && url.scheme =~ /^https?$/)
        halt 422, simple_escape("Invalid url: #{url}")
      end

      case settings.required_host
      when String
        if url.host != settings.required_host
          halt 422, simple_escape("URL must be from #{settings.required_host}")
        end
      when Regexp
        if url.host.to_s !~ settings.required_host
          halt 422, simple_escape("URL must match #{settings.required_host.inspect}")
        end
      end

      begin
        if code = settings.db.add(url.to_s, params[:code])
          redirect code, 201
        else
          halt 422, simple_escape("Unable to shorten #{url}")
        end
      rescue Guillotine::DuplicateCodeError => err
        halt 422, simple_escape(err.to_s)
      end
    end

    # Guillotine output is supposed to be text/plain friendly, so only strip
    # /<|>/.  Broken tie fighter :(  If you're passing these characters in,
    # you're probably doing something naughty.
    def simple_escape(s)
      s.gsub! /<|>/, ''
      s
    end
  end
end
