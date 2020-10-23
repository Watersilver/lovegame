local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"
local bnd = require "GameObjects.bounceAndDie"

local function determinePositionDefault(x, y, facing, index)
  local modx, mody = 0, 0
  if facing == "up" then
    modx = 4
    mody = -7
    if index < 1 then
      mody = mody + 2
    end
  elseif facing == "down" then
    modx = -4
    mody = 10
    if index < 1 then
      mody = mody - 2
    end
  elseif facing == "left" then
    mody = 3
    modx = -8
    if index >= 1 then
      modx = modx - 2
    end
  elseif facing == "right" then
    mody = 3
    modx = 8
    if index >= 1 then
      modx = modx + 2
    end
  end
  return x + modx, y + mody
end

facingAngleTable = {
  up = 0,
  left = math.pi * 1.5,
  down = math.pi,
  right = math.pi * 0.5
}

local Sword = {}

function Sword.initialize(instance)
  instance.doesntForceDir = true
  instance.levitating = true
  instance.physical_properties.shape = ps.shapes.enemySword
  instance.physical_properties.bodyType = "kinematic"
  instance.physical_properties.masks = {PLAYERJUMPATTACKCAT}
  instance.sprite_info = im.spriteSettings.enemySword
  instance.undamageable = true
  instance.unpushable = true
  instance.canBeRolledThrough = false
  instance.canBeBullrushed = false
  instance.seeThrough = true
  instance.determinePosition = determinePositionDefault
  instance.pushback = true
  instance.shieldWall = true
  instance.shielded = true
  instance.attackDmg = 2.75
end

Sword.functions = {

  flyOff = function (self, direction)
    init = {
      angularVel = 33,
      zvel = 77,
      hasShadow = true,
      gravity = 77,
    }
    if direction then
      init.bounceDir = direction
      init.bounceSpeed = 20 + 8 * love.math.random()
    end
    bnd.quickBnD(self, {init = init})
    o.removeFromWorld(self)
  end,

  load = function (self)
    et.functions.load(self)

    Sword.functions.early_update(self, 0)
    if (not self.creator) or (not self.creator.exists) then return end
    self.x, self.y = self.determinePosition(self.creator.x, self.creator.y, self.facing, self.creator.image_index)
    self.zo = self.creator.zo
  end,

  delete = function (self)
    if self.creator then self.creator.mySword = nil end
  end,

  early_update = function (self, dt)
    if (not self.creator) or (not self.creator.exists) then
      self:flyOff()
      return
    end
    self.facing = self.creator.facing

    -- Set angle
    self.angle = facingAngleTable[self.facing]

    -- Set position
    local x, y = self.determinePosition(self.creator.x, self.creator.y, self.facing, self.creator.image_index)
    self.body:setAngle(self.angle)
    self.body:setPosition(x, y)
    self.zo = self.creator.zo
  end,

  -- enemyUpdate = function (self, dt)
  -- end,

  -- draw = function (self)
  --   et.functions.draw(self)
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  touchedBySword = function (self, other, myF, otherF)
    if (not self.creator) or (not self.creator.exists) then return end
    self.creator.triggers.swordRecoil = true
    if other.spin and other.creator and love.math.random() > self.creator.gripStrength then
      self.creator.triggers.bigRecoil = true
      -- local _, dir = u.cartesianToPolar(self.x - other.x, self.y - other.y)
      -- perpendicular
      local _, dir
      if love.math.random() > 0.5 then
        -- 90 deg
        _, dir = u.cartesianToPolar(self.y - other.creator.y, - (self.x - other.creator.x))
      else
        -- -90 deg
        _, dir = u.cartesianToPolar(-(self.y - other.creator.y), self.x - other.creator.x)
      end
      self:flyOff(dir)
    end
  end,

  touchedByBombsplosion = function (self, other, myF, otherF)
    if (not self.creator) or (not self.creator.exists) then return end
    if love.math.random() > self.creator.gripStrength * 0.5 then
      self:flyOff()
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    coll:setEnabled(false)
    -- local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
  end,
}

function Sword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Sword, instance, init) -- add own functions and fields
  return instance
end

return Sword
