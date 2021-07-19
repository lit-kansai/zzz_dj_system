class ChangeTrackToMusics < ActiveRecord::Migration[5.2]
  def change
    change_column :musics, :track, :string
  end
end
