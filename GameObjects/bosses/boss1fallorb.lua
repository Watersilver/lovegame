local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"

local Orb = {}

function Orb.initialize(instance)
  instance.sprite_info = { im.spriteSettings.testlift }
  instance.physical_properties.bodyType = "static"
  instance.physical_properties.shape = ps.shapes.rect1x1
  instance.image_speed = 0
  instance.hp = 4 --love.math.random(3)
  instance.shielded = true
  instance.shieldWall = true
  instance.unpushable = true
  instance.harmless = true
  instance.gravity = 300
  instance.zvel = 0
  instance.zo = - 111
end

Orb.functions = {
  load = function (self)
    et.functions.load(self)
  end,

  enemyUpdate = function (self, dt)
    td.zAxis(self, dt)
    sh.handleShadow(self)
    if self.zo < 0 and self.zo > -15 then
      self.harmless = false
    else
      self.harmless = true
      if self.zo == 0 then self.unpushable = false end
    end
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  beginContact = u.emptyFunc,

  preSolve = function (self, a, b, coll, aob, bob)
    if self.zo < 0 then coll:setEnabled(false) end
  end
}

function Orb:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Orb, instance, init) -- add own functions and fields
  return instance
end

return Orb
