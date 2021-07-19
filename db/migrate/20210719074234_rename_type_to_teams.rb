class RenameTypeToTeams < ActiveRecord::Migration[5.2]
  def change
    rename_column :teams, :type, :player
  end
end
