local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local u = require "utilities"

local Antifairy = {}

function Antifairy.initialize(instance)
  instance.levitating = true -- can go through over hazardous floor
  instance.maxspeed = 80
  instance.direction = math.random()*2*math.pi
  instance.sprite_info = { im.spriteSettings.testenemy4 }
  instance.physical_properties.restitution = 1
  instance.image_speed = 0.3
  instance.hp = 1 --love.math.random(3)
  instance.shielded = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.shieldWall = true
end

Antifairy.functions = {
  load = function (self)
    et.functions.load(self)
    self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, self.direction))
  end,

  enemyUpdate = u.emptyFunc,

  endContact = function(self, a, b, coll, aob, bob)
    -- restitution doesn't result in a perfect elastic bounce, so fix here
    self._, self.direction = u.cartesianToPolar(self.body:getLinearVelocity())
    self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, self.direction))
  end
}

function Antifairy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Antifairy, instance, init) -- add own functions and fields
  return instance
end

return Antifairy
