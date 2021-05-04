require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require "sinatra/json"
require 'net/http'
require "json"
require 'uri'

def search_music(query) 
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({ term: query, country: "JP", media: "music", limit: 15 })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  return returned_json["results"]
end

def search_add_music(query)
  uri = URI("https://itunes.apple.com/lookup")
  uri.query = URI.encode_www_form({ id: query, country: "JP" })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  return returned_json["results"]
end

def add_list_init(add_list)
  if add_list == nil || add_list == ""
    add_list = []
  else
    add_list = add_list.split('-')
  end
end

get '/' do
  'Hello'
end

get '/:team_id' do
  team_id = params[:team_id]
  query = params[:q]
  add_list = add_list_init(params[:add_list])
  @add_musics = search_add_music(add_list.join(","))
  @musics = search_music(query)
  erb :index
end

get '/:team_id/confirm' do
  add_list = add_list_init(params[:add_list])
  @add_musics = search_add_music(add_list.join(","))
  erb :confirm
end

# 曲の追加
post '/music/temp/add' do
  trackId = params[:trackId]
  add_list = add_list_init(params[:add_list])
  if !add_list.include?(trackId)
    add_list.append(trackId)
  end
  uri = URI(params[:team_id])
  uri.query = URI.encode_www_form({ q: params[:q].to_s, add_list: add_list.join("-") })
  redirect uri
end

# 曲の削除
post '/music/temp/delete' do
  trackId = params[:trackId]
  add_list = add_list_init(params[:add_list])
  if add_list.include?(trackId)
    add_list.delete(trackId)
  end
  uri = URI(params[:team_id])
  uri.query = URI.encode_www_form({ q: params[:q].to_s, add_list: add_list.join("-") })
  redirect uri
end

# 確認画面へ
post '/confirm' do
  url = "/" + params[:team_id] + "/confirm"
  uri = URI(url)
  uri.query = URI.encode_www_form({ add_list: params[:add_list].to_s })
  redirect uri
end

# 登録
post '/submit' do
  team_id = params[:team_id]
  add_list = add_list_init(params[:add_list])
  name = params[:radio_name]
  comment = params[:comment]
end   