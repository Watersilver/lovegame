local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local snd = require "sound"

local possibleStartingRooms = {
  {weight = 1, value = "Rooms/cursedForest/r01.lua"},
}

local Curse = {}

function Curse.initialize(instance)
  instance.layer = 30
  instance.timer = 0
  instance.transPersistent = true
  instance.ids[#instance.ids+1] = "ForestCurse"
  if o.identified.ForestCurse and o.identified.ForestCurse[1].exists then instance.dieASAP = true end
  if session.save.forsetCurseLifted then instance.dieASAP = true end
end

Curse.functions = {
  load = function (self)
    if self.dieASAP then o.removeFromWorld(self) end
  end,

  startTimer = function (self)
    self.timerRunning = true
  end,

  stopTimer = function (self)
    self.timerRunning = false
  end,

  updateTimer = function (self, dt)
    if self.timerRunning then
      self.timer = self.timer + dt
    end
  end,

  update = function (self, dt)
    if self.dieASAP then return end
    if not self.TransRanAtLeastOnce then self:trans_draw() end
    self.transRan = false

    self:updateTimer(dt)
  end,

  draw = function (self)
    if self.dieASAP then return end
    if pl1 then
      love.graphics.circle("fill", pl1.x, pl1.y - 33, 3)
    end
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
      self:stopTimer()
      game.room.leftTrans = {
        {
          -- roomTarget = "Rooms/cursedForestTemplate1.lua",
          -- roomTarget = "Rooms/cursedForest/Crossroads.lua",
          -- roomTarget = "Rooms/cursedForest/r01.lua",
          roomTarget = u.chooseFromWeightTable(possibleStartingRooms),
          yupper = 0, ylower = 520,
          xmod = 0, ymod = 0
        }
      }
    elseif roomName:find("Rooms/w096x102.lua") then
      if game.lastSide == "up" then
        self:startTimer()
        game.room.downTrans = {
          {
            roomTarget = "Rooms/cursedForest/r08.lua",
            xleftmost = 0, xrightmost = 520,
            xmod = 0, ymod = 0
          }
        }
      else
        self:stopTimer()
      end
    elseif roomName:find("cursedForest") then
      self:startTimer()
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
