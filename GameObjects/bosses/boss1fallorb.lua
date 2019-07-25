local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local o = require "GameObjects.objects"
local u = require "utilities"
local expl = require "GameObjects.explode"
local snd = require "sound"
local shdrs = require "Shaders.shaders"
local gsh = require "gamera_shake"

local dc = require "GameObjects.Helpers.determine_colliders"

-- local liftableShader = shdrs.playerHitShader

local function throw_collision(self)
  local explOb = expl:new{
    x = self.x or self.xstart, y = self.y or self.ystart,
    layer = self.layer,
    explosionNumber = self.explosionNumber,
    sprite_info = self.explosionSprite,
    image_speed = self.explosionSpeed,
    sounds = snd.load_sounds({explode = self.explosionSound})
  }
  o.addToWorld(explOb)
end

local sprite_info = {im.spriteSettings.boss1Orb}
local shadowsprite = {im.spriteSettings.boss1OrbShadow}

local Orb = {}

function Orb.initialize(instance)
  instance.sprite_info = sprite_info
  instance.shadowsprite = shadowsprite
  instance.physical_properties.bodyType = "static"
  -- instance.physical_properties.shape = ps.shapes.rect1x1
  instance.physical_properties.shape = ps.shapes.circle1
  instance.image_speed = 0
  instance.hp = 4 --love.math.random(3)
  instance.shielded = true
  instance.shieldWall = true
  instance.unpushable = true
  instance.harmless = true
  instance.gravity = 300
  instance.attackDodger = true
  instance.zvel = 0-- 55
  instance.zo = - 150
  instance.grounded = false
  instance.explosionSound = {"Effects/Oracle_Rock_Shatter"}
  instance.throw_collision = throw_collision
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
      if self.zo == 0 then
        if not self.touchedGround then
          gsh.newShake(mainCamera, "displacement")
          self.unpushable = false
          self.pushback = true
          self.attackDodger = false
          self.touchedGround = true
        end
      end
    end
    -- if self.liftable then self.myShader = liftableShader end
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  beginContact = u.emptyFunc,

  preSolve = function (self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if self.zo < 0 then coll:setEnabled(false) end
    if other.boss1laser then o.removeFromWorld(self) end
  end,

  -- draw = function (self)
  --   local worldShader = love.graphics.getShader()
  --   love.graphics.setShader(self.myShader)
  --   et.functions.draw(self)
  --   love.graphics.setShader(worldShader)
  -- end
}

function Orb:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Orb, instance, init) -- add own functions and fields
  return instance
end

return Orb
