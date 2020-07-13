local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"

local Beetle = {}

function Beetle.initialize(instance)
  instance.sprite_info = im.spriteSettings.beetle
  instance.hp = 1
  instance.image_speed = 0.08
  instance.physical_properties.shape = ps.shapes.circleHalf
end

Beetle.functions = {

  enemyUpdate = function (self, dt)
    local vx, vy = self.body:getLinearVelocity()
    self.speed = math.sqrt(vx*vx + vy*vy)
    -- Movement behaviour
    if self.behaviourTimer < 0 then
      self.direction = math.pi * 2 * love.math.random()
      self.behaviourTimer = love.math.random(2)
    end
    if self.invulnerable then
      self.direction = nil
    end

    td.analogueWalk(self, dt)
  end,

  -- draw = function (self)
  --   et.functions.draw(self)
  -- end
}

function Beetle:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Beetle, instance, init) -- add own functions and fields
  return instance
end

return Beetle
