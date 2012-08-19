require 'sinatra/base'

module Guillotine
  # Essentially herds Sinatra input to Guillotine::Service, and ensures the
  # output is fit Sinatra to return.
  class App < Sinatra::Base
    set :service, nil

    get "/" do
      if params[:code].nil?
        default_url = settings.service.default_url
        redirect default_url if !default_url.nil?
      end
    end

    get "/:code" do
      escaped = Addressable::URI.escape(params[:code])
      status, head, body = settings.service.get(escaped)
      [status, head, simple_escape(body)]
    end

    post "/" do
      status, head, body = settings.service.create(params[:url], params[:code])

      if loc = head['Location']
        head['Location'] = File.join(request.url, loc)
      end

      [status, head, simple_escape(body)]
    end

    # Guillotine output is supposed to be text/plain friendly, so only strip
    # /<|>/.  Broken tie fighter :(  If you're passing these characters in,
    # you're probably doing something naughty.
    def simple_escape(s)
      s = s.to_s
      s.gsub! /<|>/, ''
      s
    end
  end
end

