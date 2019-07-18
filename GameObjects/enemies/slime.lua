local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"

local Slime = {}

function Slime.initialize(instance)
  instance.sprite_info = im.spriteSettings.slime
  instance.hp = 1
  instance.image_speed = 0.06
end

Slime.functions = {

  enemyUpdate = function (self, dt)
    local vx, vy = self.body:getLinearVelocity()
    self.speed = math.sqrt(vx*vx + vy*vy)
    -- Movement behaviour
    if self.behaviourTimer < 0 then
      ebh.randomizeAnalogue(self, true)
    end
    if self.invulnerable then
      self.direction = nil
    end
    if self.speed > 0.4 then
      self.image_speed = self.speed * 0.003
    else
      self.image_speed = 0
      self.image_index = 1
    end
    td.analogueWalk(self, dt)
  end,

  -- hitBySword = function (self, other, myF, otherF)
  --   ebh.propelledByHit(self, other, myF, otherF, 3, 1, 1, 0.5)
  -- end,

  -- draw = function (self)
  --   et.functions.draw(self)
  -- end
}

function Slime:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Slime, instance, init) -- add own functions and fields
  return instance
end

return Slime
