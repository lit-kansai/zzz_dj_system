class CreateMessage < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :name
      t.integer :team_id
      t.text :content
      t.timestamps null: false
    end
  end
end
