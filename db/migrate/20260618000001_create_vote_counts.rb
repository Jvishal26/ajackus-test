class CreateVoteCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :vote_counts do |t|
      t.string :billetto_event_id, null: false
      t.integer :upvotes, null: false, default: 0
      t.integer :downvotes, null: false, default: 0
      t.timestamps
    end

    add_index :vote_counts, :billetto_event_id, unique: true
  end
end
