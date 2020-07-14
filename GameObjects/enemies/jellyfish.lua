local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local u = require "utilities"
local o = require "GameObjects.objects"
local td = require "movement"; td = td.top_down

local js = require "GameObjects.enemies.jellysmall"

local function setDuration(instance)
  if instance.state == "float" then
    -- How long before next shock
    instance.duration = love.math.random() * 4 + 3
  else
    -- How long before next float
    instance.duration = love.math.random() + 1
  end
end

local Zora = {}

function Zora.initialize(instance)
  instance.sprite_info = im.spriteSettings.jellyfish
  instance.hp = 3 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.untouchable = true
  instance.giveChaseChance = 0.5 -- Chase player
  instance.zo = -4
  instance.lowestZo = -2
  instance.gravity = 6
  instance.zvel = 0
  instance.grounded = false
  instance.flying = true -- can go through walls
  instance.controlledFlight = true
  instance.lowFlight = true
  instance.state = "float"
  instance.attackDmgFloat = 2
  instance.attackDmgShock = 4
  instance.attackDmg = instance.attackDmgFloat
  instance.ballbreakerEvenIfHigh = true
  instance.shockSound = snd.load_sound({"Effects/Oracle_Link_Shock"})
  instance.drops = {
    -- {value = "fairy", chance = 1}
  }

  setDuration(instance)
end

Zora.functions = {
  enemyLoad = function (self)
    self.timer = 0
    self.sprite = im.sprites["Enemies/Jellyfish/" .. self.state]
    self.mass = self.body:getMass()
  end,

  die = function (self)
    local xdis = 5
    local j1 = js:new{
      xstart = self.x + xdis, ystart = self.y,
      x = self.x + xdis, y = self.y,
      layer = self.layer
    }
    o.addToWorld(j1)
    local j2 = js:new{
      xstart = self.x - xdis, ystart = self.y,
      x = self.x - xdis, y = self.y,
      layer = self.layer
    }
    o.addToWorld(j2)
    et.functions.die(self)
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1
    self.body:setLinearDamping(0)

    if self.timer > self.duration then
      self.timer = 0
      if self.state == "float" then
        self.state = "shock"
        -- Rubber ring protects you from shock
        if not session.bounceRing then
          self.attackShakeMagn = 5
          self.attackShakeDur = 1.5
          self.attackDmg = self.attackDmgShock
          self.altHurtSound = self.shockSound
          self.canBeBullrushed = false
        end
      else
        self.state = "float"
        self.attackShakeMagn = nil
        self.attackShakeDur = nil
        self.attackDmg = self.attackDmgFloat
        self.altHurtSound = nil
        self.canBeBullrushed = true
      end
      self.sprite = im.sprites["Enemies/Jellyfish/" .. self.state]
      setDuration(self)
    end

    if self.state == "float" then

      td.zAxis(self, dt)

      if self.zo > self.lowestZo then
        self.zvel = 8
        local _, dir
        if love.math.random() < self.giveChaseChance then
          -- Vector pointing to target
          local dx, dy = self.target.x - self.x, self.target.y - self.y
          -- Get direction to target
          _, dir = u.cartesianToPolar(dx, dy)
        else
          -- Random direction
          dir = (love.math.random() * 2 - 1) * math.pi
        end
        self.body:applyLinearImpulse(u.polarToCartesian(self.mass * 15, dir))
      end

      if self.zvel < 0 then
        self.image_index = 1
        self.body:setLinearDamping(3)
      else
        self.image_index = 0
      end

    elseif self.state == "shock" then
      self.image_index = 1 - self.image_index
      self.body:setLinearDamping(3)
    end

    self.timer = self.timer + dt
    sh.handleShadow(self)
  end,

  hitBySword = function (self, other, myF, otherF)
    -- Rubber ring protects you from shock
    if self.state ~= "shock" or session.bounceRing then
      et.functions.hitBySword(self, other, myF, otherF)
    else
      if other.creator and other.creator.takeDamage then
        other.creator:takeDamage(self)
      end
    end
  end,
}

function Zora:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Zora, instance, init) -- add own functions and fields
  return instance
end

return Zora
