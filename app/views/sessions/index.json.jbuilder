json.status "success"

json.sessions @sessions do |session|
  json.id session.id
  json.status session.status
  json.player_a session.player_a.nil? ? nil : session.player_a.name
  json.player_b session.player_b.nil? ? nil : session.player_b.name
  json.joinable session.player_b.nil? ? true : false
end