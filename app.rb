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
require "./util/apple_music"
require "./util/spotify"
require "./util/dj_manager"
require "./util/spotify_user.rb"

Dotenv.load
@@dj_manager = DJManager.new()
@@spotify_user = SpotifyUserManager.new()
@@spotify_user_id = ""

helpers do
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
  set :show_exceptions, false
end

not_found do
  erb :not_found
end

# ==========================================
# メンバーもアクセス可能
# ==========================================

# メンバーが曲をリクエストする（検索）
get '/:team_id' do
  team_id = params[:team_id]
  redirect not_found if !@dj_manager.team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  query = params[:q]
  add_list = add_list_init(params[:add_list])
  @add_musics = @dj_manager.search_music_by_id(@team.player, add_list)
  @musics = @dj_manager.search_music(@team.player, query)
  erb :index
end

# メンバーが曲をリクエストする（曲の確認 & ラジオネーム & メッセージ）
get '/:team_id/confirm' do
  team_id = params[:team_id]
  @dj_manager.team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  add_list = add_list_init(params[:add_list])
  @add_musics = @dj_manager.search_music_by_id(@team.player, add_list)
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
    if @dj_manager.check_music(team.player, track_id)
      message.musics.create(track: track_id)
    end
  end
  redirect params[:team_id]
end

# リストを整理する
def add_list_init(add_list)
  if add_list.blank? || add_list == ""
    add_list = []
  else
    add_list = add_list.split('-')
  end
end


# ==========================================
# Only Mentor
# ==========================================

# チーム一覧を表示
get '/admin/all' do
  protect!
  @teams = Team.all
  erb :admin_all
end

# 新しくチームを作成する
get '/admin/edit/:team_id?' do
  protect!
  @team = Team.find_by(url_name: params[:team_id])
  erb :admin_edit
end

# チームを管理する（リクエスト済の曲を検索する）
get '/admin/:team_id' do
  protect!
  team_id = params[:team_id]
  redirect not_found if !@@dj_manager.team_check(team_id)
  @team = Team.find_by(url_name: team_id)
  messages = @team.messages
  @team_messages = messages.reject{ |doc| !check_message(doc.name) || !check_message(doc.content) }
  track_id_list = messages.map { |message| message.musics.map{ |doc| doc['track'] } }
  @team_musics = @@dj_manager.search_music_by_id(@team.player, track_id_list.flatten.uniq)
  @team_music_names = track_id_list.flatten.map{ |id| Music.find_by(track: id).message['name'] }
  erb :admin_view
end

# Spotifyにログイン
get '/admin/spotify/login' do
  redirect @@spotify_user.login
end

# 帰ってくるところ
get '/admin/spotify/callback' do
  erb :spotify_get_access_token
end

# access tokenを取得
post '/admin/spotify/access_token' do
  @@spotify_user_id = params[:user_id]
  redirect '/admin/all'
end

# チームを作る
post '/admin/edit/:id?' do
  protect!
  if params[:id] == nil
    Team.create(
      url_name: params[:url_name],
      mentor: params[:mentor],
      description: params[:description],
      player: params[:player]
    )
  else
    team = Team.find(params[:id])
    team.update(
      url_name: params[:url_name],
      mentor: params[:mentor],
      description: params[:description],
      player: team.player
    )
  end
  redirect '/admin/' + params[:url_name]
end

# メッセージのフィルタリング
def check_message(message)
  ng_word = ['test', 'facebook!!', '${return_var}']
  if message.blank? || message =~ /\A[0-9]+\z/
    return false
  else
    ng_word.each do |word|
      if message.include?(word)
        return false
      end
    end
    return true
  end
end