local u = require "utilities"

local game = {}

game.room = nil

game.paused = false --{player = "player1"}

function game.pause(pauser)
  if not game.unpausable or not pauser then
    game.paused = pauser
  end
end

function game.transition(trans)
  game.paused = true
  game.transitioning = trans
end

function game.change_room(roomTarget)
  -- local roomTarget = u.utf8_backspace(roomTarget, 4)
  -- return require(roomTarget)
  newRoom = assert(love.filesystem.load(roomTarget))()
  return newRoom
end

game.transitioning = false --[[
{
  type = "scrolling" or "whiteScreen",
  progress = 0 to 1,
  side = "left" or "up" or "down" or "right" or nil
}
]]

return game
