local game = {}

game.paused = false --{player = "player1"}

function game.pause(pauser)
  if not game.unpausable or not pauser then
    game.paused = pauser
  end
end

return game
