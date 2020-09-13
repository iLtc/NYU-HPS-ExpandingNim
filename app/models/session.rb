class Session < ApplicationRecord
  belongs_to :player_a, class_name: 'User'
  belongs_to :player_b, class_name: 'User', optional: true
end
