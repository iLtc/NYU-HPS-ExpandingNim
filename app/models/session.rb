class Session < ApplicationRecord
  belongs_to :player_a, class_name: 'User', optional: true
  belongs_to :player_b, class_name: 'User', optional: true
  has_many :moves
  
  validates :initial_stones, presence: true
  validates :initial_stones, inclusion: { in: 1..1000,
    message: "is not between 1 and 1000" }
  
  def status_message
    return case self.status
           when "wait_for_a_join"
             "Wait for Player A to Join"
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
