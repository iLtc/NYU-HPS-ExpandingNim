class CreateMoves < ActiveRecord::Migration[6.0]
  def change
    create_table :moves do |t|
      t.references :user, null: false, foreign_key: true
      t.references :session, null: false, foreign_key: true
      t.timestamp :start_time
      t.timestamp :end_time
      t.integer :stones_before
      t.integer :stones_removed
      t.integer :stones_after
      t.integer :reset_before
      t.boolean :reset
      t.integer :reset_after

      t.timestamps
    end
  end
end
