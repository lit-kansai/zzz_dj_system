class AddTypeToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :type, :integer, default: 0, null: false
  end
end
