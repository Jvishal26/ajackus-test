class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :billetto_id
      t.string :title
      t.text :description
      t.string :image_url
      t.datetime :starts_at

      t.timestamps
    end
    add_index :events, :billetto_id, unique: true
  end
end
