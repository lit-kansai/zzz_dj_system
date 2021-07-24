# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require "sinatra/json"
require 'net/http'
require "json"
require 'uri'
require 'dotenv'

require "./models"
require './src/base'
require "./src/api/apple_music"
require "./src/api/spotify"
require './src/dj_manager'
require './src/routes/public'
require './src/routes/admin'

use AdminRouter
use PublicRouter

not_found do
  erb :not_found
end