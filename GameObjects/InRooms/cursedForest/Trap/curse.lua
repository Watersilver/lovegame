local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"

local Curse = {}

function Curse.initialize(instance)
end

Curse.functions = {

  update = function (self, dt)
    if not self.TransRanAtLeastOnce then self:trans_draw() end
    self.transRan = false
  end,

  draw = function (self)
    -- transdraw doesn't run if draw doesnt exist, so add this here
  end,

  -- not for drawing in this case but it's the
  -- only one that only runs durin transition
  trans_draw = function (self)
    if self.transRan then return end
    self.transRan = true
    self.TransRanAtLeastOnce = true

    local previousRoomName = session.latestVisitedRooms:get(session.latestVisitedRooms.length - 2)

    game.room.upTrans = {
      {
        roomTarget = previousRoomName,
        xleftmost = 0, xrightmost = 520,
        xmod = 0, ymod = 0
      }
    }
    game.room.downTrans = {
      {
        roomTarget = previousRoomName,
        xleftmost = 0, xrightmost = 520,
        xmod = 0, ymod = 0
      }
    }
    game.room.leftTrans = {
      {
        roomTarget = previousRoomName,
        yupper = 0, ylower = 520,
        xmod = 0, ymod = 0
      }
    }
    game.room.rightTrans = {
      {
        roomTarget = previousRoomName,
        yupper = 0, ylower = 520,
        xmod = 0, ymod = 0
      }
    }
    o.removeFromWorld(self)
  end
}

function Curse:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Curse, instance, init) -- add own functions and fields
  return instance
end

return Curse
