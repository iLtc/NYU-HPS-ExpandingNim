json.status "success"
json.game_status @session.status

json.moves @session.moves do |move|
  json.player move.user.name
  json.time move.end_time.to_i - move.start_time.to_i
  json.stones_removed move.stones_removed
  json.stones_left move.stones_after
  json.reset move.reset
end