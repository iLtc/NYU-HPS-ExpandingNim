class Session < ApplicationRecord
  belongs_to :player_a, class_name: 'User'
  belongs_to :player_b, class_name: 'User', optional: true
  has_many :moves
  
  def status_message
    return case self.status
      when "wait_for_b_join"
        "Wait for Player B to Join"
      when "wait_for_a_move"
        "Wait for Player A's Move"
      when "wait_for_b_move"
        "Wait for Player B's Move"
      when "end"
        "Game Over"
      else
        "Unknown Status"
    end
  end
end
