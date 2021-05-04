class CreateMusic < ActiveRecord::Migration[5.2]
  def change
    create_table :musics do |t|
      t.integer :track
      t.integer :message_id
      t.timestamps null: false
    end
  end
end
