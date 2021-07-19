# ----------------------
# 色々管理
# ----------------------
class DJManager
  def initialize
    @apple_music = AppleMusicManager.new
  end
  # チームが存在するかを確認する
  def team_check(team_id)
    if !Team.find_by(url_name: team_id)
      redirect not_found
    end
  end

  def player_to_string(id)
    if id == 0
      return 'Apple Music'
    else
      return 'Spotify'
    end
  end

  # 与えられれた配列に一致する曲情報を返す
  def search_music_by_id(player_id, track_id_list)
    if player_id == 0
      return @apple_music.search_music_by_id(track_id_list.flatten.uniq)
    else
      return []
    end
  end

  # キーワードから曲を検索する
  def search_music(player_id, query)
    if player_id == 0
      return @apple_music.search_music(query)
    else
      return []
    end
  end

  # 曲が本当にあるかチェック
  def check_music(player_id, track_id)
    if player_id == 0
      return @apple_music.check_music(track_id)
    else
      return true
    end
  end
end
