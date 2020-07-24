local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"

local Skeleton = {}

function Skeleton.initialize(instance)
  instance.sprite_info = im.spriteSettings.skeleton
  instance.hp = 4
  instance.image_speed = 0.2
  instance.maxspeed = 40
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
end

Skeleton.functions = {
  enemyUpdate = function (self, dt)
    -- Movement behaviour
    if self.behaviourTimer < 0 then
      self.direction = math.pi * 2 * love.math.random()
      self.behaviourTimer = love.math.random(2)
    end

    td.analogueWalk(self, dt)
  end,

  enemyBeginContact = function (self, other, myF, otherF, coll)

    -- Get vector perpendicular to collision
    local nx, ny = coll:getNormal()

    -- make sure it points AWAY from obstacle if applied to object
    local dx, dy = self.x - other.x, self.y - other.y
    if nx * dx < 0 or ny * dy < 0 then -- checks if they have different signs
      nx, ny = -nx, -ny
    end
    self._, self.direction = u.cartesianToPolar(u.reflect(self.vx, self.vy, nx, ny))
  end,
}


function Skeleton:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Skeleton, instance, init) -- add own functions and fields
  return instance
end

return Skeleton
