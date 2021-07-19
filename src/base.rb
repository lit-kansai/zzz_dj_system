# frozen_string_literal: true

class Base < Sinatra::Base
  helpers do
    def notfound(error = nil)
      status 404
      erb :not_found
    end

    def internal_error(error = nil)
      status 500
      json({ ok: false, status: 'error', code: 500, error: error, stacktrace: Thread.current.backtrace })
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