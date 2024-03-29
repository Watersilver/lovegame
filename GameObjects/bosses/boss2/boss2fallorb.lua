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
  expl.commonExplosion(self)
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
  instance.physical_properties.masks = {PLAYERJUMPATTACKCAT}
  instance.image_speed = 0
  instance.hp = 4 --love.math.random(3)
  instance.shielded = true
  instance.shieldWall = true
  instance.unpushable = true
  instance.canBeRolledThrough = false
  instance.harmless = true
  instance.gravity = 300
  instance.attackDodger = true
  instance.attackDmg = 2
  instance.zvel = 0 -- 55
  instance.zo = - 150
  instance.grounded = false
  instance.explosionSound = {"Effects/Oracle_Rock_Shatter"}
  instance.throw_collision = throw_collision

  instance.floorTiles = {role = "thrownFloorTilesIndex"}
end

Orb.functions = {
  load = function (self)
    et.functions.load(self)
    if self.breakOnLanding then
      self.body:setType("dynamic")
      snd.play(glsounds.blockFall)
    end

  end,

  destroy = function (self)
    if self.groundType == "gap" then
      expl.plummet(self)
    elseif self.groundType == "water" then
      expl.sink(self)
    else
      expl.commonExplosion(self)
    end
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
          if self.groundType == "solid" then
            gsh.newShake(mainCamera, "displacement", 0.5)
            self.unpushable = false
            self.pushback = true
            self.attackDodger = false
            self.touchedGround = true
          end
          if self.breakOnLanding then
            o.removeFromWorld(self)
          end
        end
      end
    end

    if self.floorTiles[1] then
      local x, y = self.body:getPosition()
      -- I could be stepping on up to four tiles. Find closest to determine mods
      local closestTile
      local closestDistance = math.huge
      local previousClosestDistance
      for _, floorTile in ipairs(self.floorTiles) do
        previousClosestDistance = closestDistance
        closestDistance = math.min(u.distanceSqared2d(x, y, floorTile.xstart, floorTile.ystart), closestDistance)
        if closestDistance < previousClosestDistance then
          closestTile = floorTile
        end
      end
      self.xClosestTile = closestTile.xstart
      self.yClosestTile = closestTile.ystart
      if closestTile.water then
        self.groundType = "water"
      elseif closestTile.gap then
        self.groundType = "gap"
      else
        self.groundType = "solid"
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

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- remember tiles
    u.rememberFloorTile(self, other)
  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Forget Floor tiles
    u.forgetFloorTile(self, other)
  end,

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
