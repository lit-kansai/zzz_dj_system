require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require "sinatra/json"
require 'net/http'
require "json"
require 'uri'
require "./models"

# 音楽を検索する
def search_music(query) 
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({ term: query, country: "JP", media: "music", limit: 15 })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  return returned_json["results"]
end

# IDがわかっている音楽を検索する
def search_music_by_id(query)
  uri = URI("https://itunes.apple.com/lookup")
  uri.query = URI.encode_www_form({ id: query.join(','), country: "JP" })
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

# チームが存在するかを確認する
def team_check(team_id)
  if !Team.find_by(url_name: team_id)
    redirect not_found
  end
end

# チーム一覧を表示
get '/admin/all' do
  @teams = Team.all
  erb :admin_all
end

# 新しくチームを作成する
get '/admin/team_create' do
  erb :admin_create
end

# チームを管理する（リクエスト済の曲を検索する）
get '/admin/:team_id' do
  team_id = params[:team_id]
  team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  messages = Team.find_by(url_name: team_id).messages
  @team_messages = messages.reject{ |doc| doc.content.blank? }
  track_id_list = messages.map { |message| message.musics.map{ |doc| doc['track'] } }
  @team_musics = search_music_by_id(track_id_list.flatten.uniq)
  @team_music_names = track_id_list.flatten.map{ |id| p Music.find_by(track: id).message['name'] }
  erb :admin_view
end

# メンバーが曲をリクエストする（検索）
get '/:team_id' do
  team_id = params[:team_id]
  team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  query = params[:q]
  add_list = add_list_init(params[:add_list])
  @add_musics = search_music_by_id(add_list)
  @musics = search_music(query)
  erb :index
end

# メンバーが曲をリクエストする（曲の確認 & ラジオネーム & メッセージ）
get '/:team_id/confirm' do
  team_id = params[:team_id]
  team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  add_list = add_list_init(params[:add_list])
  @add_musics = search_music_by_id(add_list)
  erb :confirm
end

# 曲の追加処理（メンバーによる一時追加）
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

# 曲の削除処理（メンバーによる一時追加）
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

# 確認画面への遷移用
post '/confirm' do
  url = "/" + params[:team_id] + "/confirm"
  uri = URI(url)
  uri.query = URI.encode_www_form({ add_list: params[:add_list].to_s })
  redirect uri
end

# 曲の登録処理（メンバーによる一時追加を確定させる）
post '/submit' do
  add_list = add_list_init(params[:add_list])
  team = Team.find_by(url_name: params[:team_id])
  message = team.messages.create(name: params[:radio_name],content: params[:message])
  add_list.map do |track_id|
    message.musics.create(track: track_id)
  end
  redirect params[:team_id]
end

# チームを作る
post '/admin/team_create' do
  Team.create(
    url_name: params[:url_name],
    mentor: params[:mentor],
    description: params[:description]
  )
  redirect '/'
end

# 404
not_found do
  erb :not_found
end