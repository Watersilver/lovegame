local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"

local Curse = {}

function Curse.initialize(instance)
end

Curse.functions = {

  unstoppable_update = function (self)
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
