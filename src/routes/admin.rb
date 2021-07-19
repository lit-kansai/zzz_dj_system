# frozen_string_literal: true

require './src/base.rb'

class AdminRouter < Base
  def initialize(app = nil, **kwargs)
    super(app)
    @dj_manager = DJManager.new
  end

  # チーム一覧を表示
  get '/admin/all' do
    @teams = Team.all
    erb :admin_all
  end

  # 新しくチームを作成する
  get '/admin/edit/:team_id?' do
    @team = Team.find_by(url_name: params[:team_id])
    erb :admin_edit
  end

  # チームを管理する（リクエスト済の曲を検索する）
  get '/admin/:team_id' do
    team_id = params[:team_id]
    @dj_manager.team_check(team_id)
    @team = Team.find_by(url_name: team_id)
    messages = @team.messages
    @team_messages = messages.reject{ |doc| !check_message(doc.name) || !check_message(doc.content) }
    track_id_list = messages.map { |message| message.musics.map{ |doc| doc['track'] } }
    @team_musics = @dj_manager.search_music_by_id(@team.player, track_id_list.flatten.uniq)
    @team_music_names = track_id_list.flatten.map{ |id| Music.find_by(track: id).message['name'] }
    erb :admin_view
  end

  # 存在しない曲を削除する(Apple MusicかSpotifyか見分ける必要があるので一旦フリーズ)
  # get '/admin/clear' do
    # music_all = Music.all
    # for music in music_all do
    #   if !@apple_music.check_music(music.track)
    #     music.delete()
    #   end
    # end
    # return json({ status: 'success', code: 200})
  # end

  # チームを作る
  post '/admin/edit/:id?' do
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
        player: params[:player]
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
end