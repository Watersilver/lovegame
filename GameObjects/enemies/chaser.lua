local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local expl = require "GameObjects.explode"
local proj = require "GameObjects.enemies.projectile"
local u = require "utilities"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local function withdraw(instance, bool)
  instance.image_index = 0
  instance.harmless = bool
  instance.canBeBullrushed = bool
  instance.withdrawn = bool
  -- instance.weakShield = not bool
  instance.startedMoving = not bool
  if not bool then
    instance.withdrawTimer = 0.3
    snd.play(instance.moveSound)
    local xMintx, yMinty = instance.target.x - instance.x, instance.target.y - instance.y
    if math.abs(xMintx) > math.abs(yMinty) then
      instance.fx = instance.mass * 50 * u.sign(xMintx)
    else
      instance.fy = instance.mass * 50 * u.sign(yMinty)
    end
    instance.image_speed = 0.5
  else
    instance.fx, instance.fy = 0, 0
    instance.image_speed = 0
  end
  instance.body:setLinearDamping(instance[(bool and "still" or "moving") .. "Damping"])
  instance.sprite = im.sprites["Enemies/Chaser/" .. (bool and "waiting" or "chasing")]
end

local Chaser = {}

function Chaser.initialize(instance)
  instance.maxspeed = 50
  instance.sprite_info = im.spriteSettings.chaser
  instance.physical_properties.density = 4000
  instance.stillDamping = 40
  instance.movingDamping = 0.5
  instance.hp = 1 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.sightWidth = 12
  instance.sightDistance = 112
  instance.facing = "all4"
  instance.universalForceMod = 0
  instance.shieldWall = true
  instance.shielded = true
  instance.pushback = true
  instance.mediumShield = true
  instance.moveSound = snd.load_sound({"Effects/Oracle_Block_Push"})
end

Chaser.functions = {
  enemyLoad = function (self)
    self.mass = self.body:getMass()
    withdraw(self, true)
    self.fx, self.fy = 0, 0
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1

    -- Only look when still
    local hasSeenTarget = not self.startedMoving and self:lookFor(self.target)

    -- If see target move towards it
    if hasSeenTarget then
      withdraw(self, false)
    end

    -- Check if I must withdraw
    if self.withdrawTimer then
      -- Can't withdraw immediatelly after coming out of shell
      self.withdrawTimer = self.withdrawTimer - dt
      if self.withdrawTimer < 0 then self.withdrawTimer = nil end
    else
      -- If I can't move when I'm supposed to be moving, widthdraw
      if not self.withdrawn and math.abs(self.vx) < 1 and math.abs(self.vy) < 1 then
        withdraw(self, true)
      end
    end

    self.body:applyForce(self.fx, self.fy)
  end,

  -- enemyBeginContact = function (self, other)
  --   withdraw(self, true)
  -- end,

  -- hitSolidStatic = function (self, other)
  --   withdraw(self, true)
  -- end,

  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

  end,

  preSolve = function(self, a, b, coll, aob, bob)

  end,
}

function Chaser:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Chaser, instance, init) -- add own functions and fields
  return instance
end

return Chaser
