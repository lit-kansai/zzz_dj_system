require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require "sinatra/json"
require 'net/http'
require "json"

def search_music(query) 
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({ term: query, country: "JP", media: "music", limit: 15 })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  return returned_json["results"]
end

get '/' do
  
end

get '/:team_id' do
  trackId = params[:trackId]
  if trackId
    addId = params[:addId]
    if addId == nil
      addId = " "
    end
    addId = addId + "," + trackId
    url = request.path + "?q=" + params[:q] + "&addId=" + addId
    redirect url.to_s
  else
    query = params[:q]
    @musics = search_music(query)
    erb :index
  end
end

get '/:team_id/message' do
  '検索ID'
end

get '/:team_id/complete' do
  '送信後に送られる画面'
end

post '/:team_id' do
  team_id = params[:team_id]
  q = params[:q]
  addId = params[:addId].split(',')
  trackId = params[:trackId]
  if addId == nil || addId == ""
    addId = []
  end
  if !addId.include?(trackId)
    addId.append(params[:trackId])
  end
  url = "/" + team_id + "?q=" + q + "&addId=" + addId.join(",")
  redirect url.to_s
end