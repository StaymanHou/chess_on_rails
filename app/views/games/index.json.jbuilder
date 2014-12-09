json.array!(@games) do |game|
  json.extract! game, :id, :pgn
  json.url game_url(game, format: :json)
end
