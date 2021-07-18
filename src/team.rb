# ----------------------
# チームを管理
# ----------------------

class TeamManager
# チームが存在するかを確認する
  def team_check(team_id)
    if !Team.find_by(url_name: team_id)
      redirect not_found
    end
  end
end