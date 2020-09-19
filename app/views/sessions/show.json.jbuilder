json.status "success"
json.game_status @session.status

json.moves @session.moves.order(id: :asc) do |move|
  json.player move.user.name
  json.time (move.end_time.to_f - move.start_time.to_f).round(3)
  json.stones_removed move.stones_removed
  json.stones_left move.stones_after
  json.reset move.reset
end