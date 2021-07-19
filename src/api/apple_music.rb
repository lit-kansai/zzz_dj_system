# ----------------------
# Apple MusicのAPIを管理
# ----------------------

class AppleMusicManager
  # 音楽を検索する
  def search_music(query)
    uri = URI("https://itunes.apple.com/search")
    uri.query = URI.encode_www_form({ term: query, country: "JP", media: "music", limit: 15 })
    res = Net::HTTP.get_response(uri)
    returned_json = JSON.parse(res.body)
    return returned_json["results"]
  end

  # IDがわかっている音楽を検索する(160を超えるリクエストは拒否されるのでそれ以下で回す)
  def search_music_by_id(query)
    return_data = []
    query.each_slice(150) do |i|
      uri = URI("https://itunes.apple.com/lookup")
      uri.query = URI.encode_www_form({ id: (i.length >= 1 ? i.join(',') : i), country: "JP" })
      res = Net::HTTP.get_response(uri)
      returned_json = JSON.parse(res.body)
      return_data.concat(returned_json["results"])
    end
    return return_data
  end

  # 曲が存在するかを確認する
  def check_music(query)
    uri = URI("https://itunes.apple.com/lookup")
    uri.query = URI.encode_www_form({ id: query, country: "JP" })
    res = Net::HTTP.get_response(uri)
    returned_json = JSON.parse(res.body)
    if returned_json["resultCount"].to_i != 0
      return true
    else
      return false
    end
  end
end