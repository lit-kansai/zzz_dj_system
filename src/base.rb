# frozen_string_literal: true

class Base < Sinatra::Base
  helpers do
    def notfound(error = nil)
      status 404
    end

    def internal_error(error = nil)
      status 500
      json({ ok: false, status: 'error', code: 500, error: error, stacktrace: Thread.current.backtrace })
    end

    def protect!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      username = ENV['BASIC_AUTH_USERNAME']
      password = ENV['BASIC_AUTH_PASSWORD']
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
    end
  end

  configure do
    set :views, File.join(root, '../views')
    set :show_exceptions, false
  end

  configure :development do
    register Sinatra::Reloader
  end
end