class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :status
      t.references :player_a
      t.references :player_b

      t.timestamps
    end
  end
end
