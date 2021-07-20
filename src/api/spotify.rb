# ----------------------
# SpotifyのAPIを管理
# ----------------------

class SpotifyManager
  require 'rspotify'

  def initialize()
    Dotenv.load
    RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_SECRET_ID'])
  end

  # 音楽を検索する
  def search_music(query)
    returnData = []
    tracks = RSpotify::Track.search(query, market:'JP')
    tracks.each_entry do |track|
      returnData.append({
        "artworkUrl100" => track.album.images[1]['url'],
        "trackName" => track.name,
        "artistName" => track.artists.first.name,
        "collectionName" => track.album.name,
        "trackTimeMillis" => track.duration_ms,
        "trackViewUrl" => track.external_urls['spotify'],
        "trackId" => track.id
      })
    end
    return returnData
  end

  # IDがわかっている音楽を検索する(複数)
  def search_music_by_id(query)
    return_data = []
    query.each do |track|
      track_data = search_music_by_id_single(track)
      if track_data != false
        return_data.append(track_data)
      end
    end
    return return_data
  end

  # IDがわかっている音楽を検索する(1つ)
  def search_music_by_id_single(query)
    begin
      track = RSpotify::Track.find(query)
      returnData = {
        "artworkUrl100" => track.album.images[1]['url'],
        "trackName" => track.name,
        "artistName" => track.artists.first.name,
        "collectionName" => track.album.name,
        "trackTimeMillis" => track.duration_ms,
        "trackViewUrl" => track.external_urls['spotify'],
        "trackId" => track.id
      }
      return returnData
    rescue => exception
      return false
    end
  end

  # 曲が存在するかを確認する
  def check_music(query)
    if search_music_by_id_single(query) != false
      return true
    else
      return false
    end
  end
end
