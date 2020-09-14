class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :token
      t.integer :left_resets
      t.integer :left_time
      t.timestamp :start_time

      t.timestamps
    end
  end
end
