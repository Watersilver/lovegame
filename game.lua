local u = require "utilities"
local snd = require "sound"

local game = {}

game.room = nil
game.prevRoom = nil

game.paused = false --{player = "player1"}

function game.getRoomElevation()
  if not game.room then return 0 end
  local roomName = session.latestVisitedRooms and session.latestVisitedRooms:getLast()
  if not roomName then return 0 end
  if u.ends_with(roomName, "h") then
    return 1
  end
  return game.room.elevation or 0
end

function game.isWorldScreen()
  if not game.room then return false end
  local roomName = session.latestVisitedRooms and session.latestVisitedRooms:getLast()
  if not roomName then return false end
  local i = string.find(roomName, "w%d+x%d+%a?")
  if not i then return false end
  return true
end

function game.wasWorldScreen()
  if not game.room then return false end
  local roomName = session.latestVisitedRooms and session.latestVisitedRooms.length > 1 and session.latestVisitedRooms:get(-2)
  if not roomName then return false end
  local i = string.find(roomName, "w%d+x%d+%a?")
  if not i then return false end
  return true
end

---@param prev? boolean
function game.getRoomCoords(prev)
  if not game.room then return nil end
  local roomName = session.latestVisitedRooms and (
    prev
    and session.latestVisitedRooms:get(-2)
    or session.latestVisitedRooms:getLast()
  )
  if not roomName then return nil end
  local i, j = string.find(roomName, "w%d+x%d+%a?")
  if not i then return nil end
  roomName = string.sub(roomName, i, j)
  local x = string.sub(roomName, string.find(roomName, "%d+") or -1)
  roomName = string.gsub(roomName, x, "", 1)
  local y = string.sub(roomName, string.find(roomName, "%d+") or -1)

  return tonumber(x), tonumber(y)
end

---@param prev? boolean
function game.getRoomGlobalCoords(prev)
  if not game.room then return nil end
  local x, y = game.getRoomCoords(prev)

  return x and ((tonumber(x) - 90) * 512), y and ((tonumber(y) - 95) * 512)
end

function game.pause(pauser)
  if not game.unpausable or not pauser then
    game.paused = pauser
    snd.play(pauser and glsounds.pauseOpen or glsounds.pauseClose)
  end
end

function game.transition(trans)
  game.paused = true
  game.transitioning = trans
  game.transitioning.xmod = game.transitioning.xmod or 0
  game.transitioning.ymod = game.transitioning.ymod or 0
  game.lastSide = trans.side or "portal"
  game.prevRoom = game.room
end

function game.cutscenePause(pause)
  game.paused = pause
  game.cutscene = pause
end

function game.change_room(roomTarget)
  -- local roomTarget = u.utf8_backspace(roomTarget, 4)
  -- return require(roomTarget)

  -- placed above assert so it doesn't get messed up in the first room (room0)
  -- If below, game will think last room visited is room0
  if session.latestVisitedRooms then
    session.latestVisitedRooms:add(roomTarget)
  end
  local newRoom = assert(love.filesystem.load(roomTarget))()
  return newRoom
end

--[[
{
  type = "scrolling" or "whiteScreen",
  progress = 0 to 1,
  side = "left" or "up" or "down" or "right" or nil
}
]]
game.transitioning = false

return game
