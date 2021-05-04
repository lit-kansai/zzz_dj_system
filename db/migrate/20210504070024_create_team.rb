class CreateTeam < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :url_name
      t.string :mentor
      t.string :description
      t.timestamps null: false
    end
  end
end
