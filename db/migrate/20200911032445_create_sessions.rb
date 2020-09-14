class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :status
      t.integer :initial_stones
      t.integer :left_stones
      t.integer :current_max
      t.boolean :reset
      t.integer :accept_max_stones
      t.integer :winner
      t.references :player_a
      t.references :player_b

      t.timestamps
    end
  end
end
