local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local expl = require "GameObjects.explode"
local proj = require "GameObjects.enemies.projectile"
local u = require "utilities"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local function toggleTransparency(instance, bool)
  instance.harmless = bool
  -- ATTACK DODGER MEANS WEAPON WONT ACT AS IF IT HIT something
  -- CHECK IT HERE, ON JUMPY AND ZORA TO MAKE SURE I DOT NEED ANYTHING MORE
  instance.attackDodger = bool
  instance.undamageable = bool
  instance.transparent = bool
end

local Robe = {}

function Robe.initialize(instance)
  instance.sprite_info = im.spriteSettings.robe
  instance.hp = 3 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.duration = 3
  -- instance.universalForceMod = 0
  instance.untouchable = true
  instance.image_speed = 0
  instance.image_index = 0
  instance.faceTarget = true

  toggleTransparency(instance, true)
end

Robe.functions = {
  enemyLoad = function (self)
    self.timer = 0
    self.sprite = im.sprites["Enemies/Robe/robe"]
  end,

  destroy = function (self)
    self.creator.pause = false
    if not self.dissapeared then self.creator.robes = self.creator.robes - 1 end
    self.creator:resetTimer(self.duration - self.timer)
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1

    -- Determine life state
    if self.timer > self.duration then
      self.dissapeared = true
      o.removeFromWorld(self)
    elseif self.timer > 2.5 then
      toggleTransparency(self, true)
    elseif self.timer > 1.6 then
      -- Attack if not attacked yet
      if not self.robeMissile then
        local floorImIn = math.floor(self.image_index)
        self.robeMissile = proj:new{
          xstart = self.x, ystart = self.y,
          attackDmg = 3, layer = self.layer + 1,
          sprite_info = im.spriteSettings.robeMissile,
          image_index = floorImIn,
          image_speed = 0,
          direction = (1 - floorImIn) * math.pi * 0.5,
          maxspeed = 200
        }
        o.addToWorld(self.robeMissile)
      end
    elseif self.timer > 1 then
      toggleTransparency(self, false)
      self.image_speed = 0
    elseif self.timer == 0 then
      -- Face towards player at start
      if self.target and self.faceTarget then
        if math.abs(self.target.x - self.x) > math.abs(self.target.y - self.y) then
          if self.target.x > self.x then
            self.image_index = 1
          else
            self.image_index = 3
          end
        else
          if self.target.y > self.y then
            self.image_index = 0
          else
            self.image_index = 2
          end
        end
      end
    end

    self.timer = self.timer + dt
  end,

  draw = function (self)
    local r, g, b, a = love.graphics.getColor();
    love.graphics.setColor(r, g, b, self.transparent and a * 0.5 or a);
    et.functions.draw(self)
    love.graphics.setColor(r, g, b, a);
  end,

  trans_draw = function (self)
    local r, g, b, a = love.graphics.getColor();
    love.graphics.setColor(r, g, b, self.transparent and a * 0.5 or a);
    et.functions.trans_draw(self)
    love.graphics.setColor(r, g, b, a);
  end,

  enemyBeginContact = function (self, other)

    -- Occupy tile
    if other.floor then
      other.occupied = other.occupied and other.occupied + 1 or 1
    end
  end,

  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Unoccupy tile
    if other.occupied then
      other.occupied = other.occupied - 1
      if other.occupied < 1 then other.occupied = nil end
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    if self.transparent then
      coll:setEnabled(false)
      self.body:setLinearVelocity(0, 0)
    end
  end,
}

function Robe:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Robe, instance, init) -- add own functions and fields
  return instance
end

return Robe
