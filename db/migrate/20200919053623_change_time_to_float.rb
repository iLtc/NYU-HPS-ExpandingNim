class ChangeTimeToFloat < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :left_time, :float
  end
end
