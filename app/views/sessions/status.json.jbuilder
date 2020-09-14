json.status "success"
json.game_status @session.status
json.your_turn @your_turn

if @your_turn
  json.message "It's your turn now. Please make a move."
  json.stones_left @session.left_stones
  json.reset @session.reset
  json.current_max @session.current_max
  json.accept_max_value @session.accept_max_stones
  json.start_time @current_player.start_time
  json.time_left @current_player.left_time - (DateTime.now.to_i - @current_player.start_time.to_i)
else
  json.message "It's not your turn yet. Please wait for other player. Please don't refresh too frequently. Status: " + @session.status_message
end