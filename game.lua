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
  roomName = u.utf8_sub(roomName,i,j)
  local x = u.utf8_sub(roomName, string.find(roomName, "%d+") or -1)
  roomName = string.gsub(roomName, x, "", 1)
  local y = u.utf8_sub(roomName, string.find(roomName, "%d+") or -1)

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
    if pauser then
      snd.bgmV2:muffle()
    else
      snd.bgmV2:unmuffle()
    end
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

  -- local newRoom = assert(love.filesystem.load(roomTarget))()

  local chunk, errmsg = love.filesystem.load(roomTarget)
  if not errmsg then
    return chunk()
  else
    local w = u.split(roomTarget, "_at")
    local dims = u.split(w[2], "x")
    local worldName = w[1]
    local x = tonumber(string.gsub(dims[1], "_", "-"), 10)
    local y = tonumber(string.gsub(dims[2], "_", "-"), 10)
    local z = tonumber(string.gsub(dims[3], "_", "-"), 10)

    if x == nil or y == nil or z == nil then
      assert(false, errmsg)
      return
    end

    local level = GCON.ldtk:findRoom(worldName,x,y,z)

    if not level then
      assert(false, errmsg)
      return
    end

    local room = {}
    room.ldtk = {
      worldName = worldName,
      x = x,
      y = y,
      z = z
    }

    for _, field in ipairs(level.fieldInstances) do
      if field.__identifier == "MusicInfo" then
        room.music_info = snd[field.__value]
      elseif field.__identifier == "AmbientLightType" then
        room.ambientLightType = field.__value
      elseif field.__identifier == "GameScale" then
        room.game_scale = field.__value
      end
    end

    room.width = level.pxWid
    room.height = level.pxHei
    room.downTrans = {
      -- {
      --   roomTarget = "Rooms/w100x101.lua",
      --   xleftmost = 0, xrightmost = 520,
      --   xmod = 0, ymod = 0
      -- }
    }
    room.rightTrans = {
      -- {
      --   roomTarget = "Rooms/w101x100.lua",
      --   yupper = 0, ylower = 520,
      --   xmod = 0, ymod = 0
      -- }
    }
    room.leftTrans = {
      -- {
      --   roomTarget = "Rooms/w099x100.lua",
      --   yupper = 0, ylower = 520,
      --   xmod = 0, ymod = 0
      -- }
    }
    room.upTrans = {
      -- {
      --   roomTarget = "Rooms/w100x099.lua",
      --   xleftmost = 0, xrightmost = 520,
      --   xmod = 0, ymod = 0
      -- }
    }

    for _, neighbor in ipairs(level.__neighbours) do
      if neighbor.dir == "n" then
        local lvl = GCON.ldtk:findLevelByIid(worldName, neighbor.levelIid)
        if lvl then
          local startDiff = lvl.worldX - level.worldX
          local t = {
            roomTarget = lvl.identifier,
            xleftmost = startDiff, xrightmost = startDiff + lvl.pxWid,
            xmod = -startDiff,
            ymod = 0
          }
          table.insert(room.upTrans, t)
        end
      elseif neighbor.dir == "s" then
        local lvl = GCON.ldtk:findLevelByIid(worldName, neighbor.levelIid)
        if lvl then
          local startDiff = lvl.worldX - level.worldX
          local t = {
            roomTarget = lvl.identifier,
            xleftmost = startDiff, xrightmost = startDiff + lvl.pxWid,
            xmod = -startDiff,
            ymod = 0
          }
          table.insert(room.downTrans, t)
        end
      elseif neighbor.dir == "e" then
        local lvl = GCON.ldtk:findLevelByIid(worldName, neighbor.levelIid)
        if lvl then
          local startDiff = lvl.worldY - level.worldY
          local t = {
            roomTarget = lvl.identifier,
            yupper = startDiff, ylower = startDiff + lvl.pxHei,
            xmod = 0,
            ymod = -startDiff
          }
          table.insert(room.rightTrans, t)
        end
      elseif neighbor.dir == "w" then
        local lvl = GCON.ldtk:findLevelByIid(worldName, neighbor.levelIid)
        if lvl then
          local startDiff = lvl.worldY - level.worldY
          local t = {
            roomTarget = lvl.identifier,
            yupper = startDiff, ylower = startDiff + lvl.pxHei,
            xmod = 0,
            ymod = -startDiff
          }
          table.insert(room.leftTrans, t)
        end
      end
    end

    return room
  end
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
