class SpotifyUserManager
  def login
    uri = URI.parse("https://accounts.spotify.com/authorize")
    uri.query = URI.encode_www_form({
      response_type: 'token',
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      scope: 'playlist-modify-private playlist-modify-public streaming playlist-modify-private',
      redirect_uri: ENV['SPOTIFY_REDIRECT_URI'],
      state: SecureRandom.hex(5)
    })
    return uri
  end

  def get_user_data(oauth_code)
    uri = URI.parse("https://api.spotify.com/v1/me")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    # request["Authorization"] = "Bearer " + oauth_code
    request["Authorization"] = "Bearer BQCT7C5n2TAVo77l-LJPxWTCuBAem0JoHoS7tSYNwOKhdxR7RPN-liVJTrYgeBzjgDHvaxJSO3AU0KLz9mMlEMuOjUYZGOZPN5dfRNLelPY5JdKpKbIhMRUXFvKW8wvCgUC_giCfn38QK_blVkVEUfHVFbfC87941S8g6FYw3KXHK5kpW3czXBNsvdifP8rgmXH_N63nAkd2dVAJ4bPT9ptmXp6BRCLe-fQRK5-Wz3CxpA"
    # request["Authorization"] = "Bearer BQAka7lsQy2eA2eSEbjY218R71GiMLzlYz5z3XYCPiKqZ5EUL_llAeseSDwiqHyTCgHl3C63wB1S24n1j0xhcuh0mCp47lcU4VhW9TpwP4qIuhhn-TH-y37qzW_-Y48Lxgmy_Q1iv1isRoMYvKASrBuMvfnL0S0vcVHQNB_DQjjfc01MoGwIH5VOSrSlNbfhb6nXswM5Ng398b_NEquNRTqvXV7g"
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return response.body
  end
end

