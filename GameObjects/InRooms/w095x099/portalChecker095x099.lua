local game = require "game"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"

local PC = {}

function PC.initialize(instance)
  instance.shrubRoomTarget = "Rooms/w095x098b.lua"
  instance.normalRoomTarget = game.room.upTrans[1].roomTarget
end

PC.functions = {
update = function (self, dt)
  -- shrub is temporary. Make into golden shrubery or something more specific
  if pl1 and pl1.liftedOb and pl1.liftedOb.lift_info == "shrub" then
    game.room.upTrans[1].roomTarget = self.shrubRoomTarget
  else
    game.room.upTrans[1].roomTarget = self.normalRoomTarget
  end
end
}

function PC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(PC, instance, init) -- add own functions and fields
  return instance
end

return PC
