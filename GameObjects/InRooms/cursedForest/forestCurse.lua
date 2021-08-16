local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local snd = require "sound"

local possibleStartingRooms = {
  {weight = 1, value = "Rooms/cursedForest/r01.lua"},
  {weight = 1, value = "Rooms/cursedForest/r03.lua"},
  {weight = 1, value = "Rooms/cursedForest/r06.lua"},
  -- Dangerous. Has gap to the left
  -- {weight = 1, value = "Rooms/cursedForest/r09.lua"},
  {weight = 1, value = "Rooms/cursedForest/r10.lua"},
  {weight = 1, value = "Rooms/cursedForest/r11.lua"},
  {weight = 1, value = "Rooms/cursedForest/r12.lua"},
}

local Curse = {}

function Curse.initialize(instance)
  instance.layer = 30
  instance.transPersistent = true
  instance.ids[#instance.ids+1] = "ForestCurse"
  if o.identified.ForestCurse and o.identified.ForestCurse[1].exists then instance.dieASAP = true end
  if session.save.forestCurseLifted then instance.dieASAP = true end
end

Curse.functions = {
  load = function (self)
    if self.dieASAP then o.removeFromWorld(self) end
  end,

  getFirstRoom = function ()
    return u.chooseFromWeightTable(possibleStartingRooms)
  end,

  update = function (self, dt)
    if self.dieASAP then return end
    if not self.TransRanAtLeastOnce then self:trans_draw() end
    self.transRan = false
  end,

  draw = function (self)
    -- transdraw doesn't run if draw doesnt exist, so add this here
    -- if self.dieASAP then return end
    -- if pl1 then
    --   love.graphics.circle("fill", pl1.x, pl1.y - 33, 3)
    -- end
  end,

  -- not for drawing in this case but it's the
  -- only one that only runs durin transition
  trans_draw = function (self)
    if self.dieASAP then return end
    if self.transRan then return end
    self.transRan = true
    self.TransRanAtLeastOnce = true

    -- local roomName = session.latestVisitedRooms:get(session.latestVisitedRooms.length - 1)
    local roomName = session.latestVisitedRooms:getLast()

    -- Test if I must be deleted
    if roomName:find("Rooms/w098x102.lua") then
      game.room.leftTrans = {
        {
          roomTarget = self.getFirstRoom(),
          yupper = 0, ylower = 520,
          xmod = 0, ymod = 0
        }
      }
    elseif roomName:find("Rooms/w095x103.lua") then
      game.room.rightTrans = {
        {
          roomTarget = self.getFirstRoom(),
          yupper = 0, ylower = 520,
          xmod = 0, ymod = 0
        }
      }
    elseif roomName:find("Rooms/w096x104.lua") then
      game.room.upTrans = {
        {
          roomTarget = self.getFirstRoom(),
          xleftmost = 0, xrightmost = 520,
          xmod = 0, ymod = 0
        }
      }
    elseif roomName:find("Rooms/w096x102.lua") then
      if game.lastSide == "up" then
        game.room.downTrans = {
          {
            roomTarget = "Rooms/cursedForest/r08.lua",
            xleftmost = 0, xrightmost = 520,
            xmod = 0, ymod = 0
          }
        }
      else
        game.room.rightTrans = {
          {
            roomTarget = self.getFirstRoom(),
            yupper = 0, ylower = 520,
            xmod = 0, ymod = 0
          }
        }
      end
    elseif roomName:find("cursedForest") then
      game.room.music_info = "ambient1"
      if roomName:find("Chess") then
        -- game.room.music_info = snd.silence
        game.room.music_info = {"Silence", previousFadeOut = 0.5}
        session.startQuest("chessPuzzle1")
        session.startQuest("chessPuzzle2")
      end
    else
      o.removeFromWorld(self)
    end
  end
}

function Curse:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Curse, instance, init) -- add own functions and fields
  return instance
end

return Curse
