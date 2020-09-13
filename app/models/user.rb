class User < ApplicationRecord
  has_one :player_a_session, class_name: 'Session', foreign_key: 'player_a_id'
  has_one :player_b_session, class_name: 'Session', foreign_key: 'player_b_id'
end
