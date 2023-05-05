local p = require "GameObjects.prototype"
local boss2 = require "GameObjects.bosses.boss2.boss2"
local o = require "GameObjects.objects"

local Boss2Spawner = {}

function Boss2Spawner.initialize(instance)
end

Boss2Spawner.functions = {
  late_update = function(self)
    if not pl1 or not pl1.exists then return end
    if pl1.y < 146 then
      o.addToWorld(boss2:new{x = 184, y = 80, xstart = 184, ystart = 80})
      o.removeFromWorld(self)
    end
  end
}

function Boss2Spawner:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Boss2Spawner, instance, init) -- add own functions and fields
  return instance
end

return Boss2Spawner
