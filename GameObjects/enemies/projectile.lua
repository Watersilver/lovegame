local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"

local dc = require "GameObjects.Helpers.determine_colliders"

local Projectile = {}

function Projectile.initialize(instance)
  instance.levitating = true
  instance.maxspeed = 80
  -- instance.physical_properties.shape = ps.shapes.bosses.boss1.laser
  instance.direction = math.random()*2*math.pi
  instance.sprite_info = { im.spriteSettings.testenemy4 }
  instance.hp = 1
  instance.vx, instance.vy = 0, 0
  instance.layer = 25
  instance.unpushable = true
end

Projectile.functions = {
  load = function (self)
    et.functions.load(self)
    self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, self.direction))
  end,

  enemyUpdate = u.emptyFunc,

  draw = function (self)
    et.functions.draw(self)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    coll:setEnabled(false)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
  end,
}

function Projectile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Projectile, instance, init) -- add own functions and fields
  return instance
end

return Projectile
