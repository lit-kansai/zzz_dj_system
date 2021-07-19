# frozen_string_literal: true

require './src/base.rb'

class PublicRouter < Base
  def initialize(app = nil, **kwargs)
    super(app)
    @dj_manager = DJManager.new
  end

  # メンバーが曲をリクエストする（検索）
  get '/:team_id' do
    team_id = params[:team_id]
    @dj_manager.team_check(team_id)
    @team = Team.find_by(url_name: team_id)
    query = params[:q]
    add_list = add_list_init(params[:add_list])
    @add_musics = @dj_manager.search_music_by_id(@team.player, add_list)
    @musics = @dj_manager.search_music(@team.player, query)
    # return @musics
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
end