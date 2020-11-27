local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"
local o = require "GameObjects.objects"

local skel = require "GameObjects.enemies.skeleton"

local Mummy = {}

function Mummy.initialize(instance)
  instance.sprite_info = im.spriteSettings.mummy
  instance.image_speed = 0
  instance.image_index = 0
  instance.sightDistance = 96
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.universalForceMod = 0
  instance.maxspeed = 0
  instance.stepForce = 50
  instance.canBeRolledThrough = false
  -- Weaker if you are brave
  instance.hp = session.save.faroresCourage and 15 or 30
  instance.attackDmg = session.save.faroresCourage and 2 or 4
  instance.stepSounds = {
    [0] = snd.load_sound({"Effects/step1"}),
    [1] = snd.load_sound({"Effects/step2"})
  }
  instance.behaviourTimer = love.math.random() * 1.3
end

Mummy.functions = {
  enemyLoad = function (self)
    self.mass = self.body:getMass()
  end,

  enemyUpdate = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(self.target) end
    -- Scare player
    if self.canSeePlayer and self.target and not session.save.faroresCourage then
      self.target.triggers.shaking = true
    end

    -- Movement behaviour
    if self.behaviourTimer < 0 then
      -- Check if I was succesfull in moving
      if self.lastx then
        if u.distanceSqared2d(self.lastx, self.lasty, self.x, self.y) < 15 then
          self.unmovingAxis = self.movingAxis
        end
      end

      self.image_index = 1 - self.image_index
      -- impulse direction
      local imdirx, imdiry
      if self.canSeePlayer and self.target then
        -- Move faster
        -- self.behaviourTimer = 0.8
        self.behaviourTimer = 0.6
        -- Try to follow player
        local toPlx, toPly = self.target.x - self.x, self.target.y - self.y

        -- Determine which axis to move on
        local moveOnAxis
        if self.unmovingAxis then
          moveOnAxis = self.unmovingAxis == "hor" and "ver" or "hor"
        else
          moveOnAxis = (math.abs(toPlx) > math.abs(toPly)) and "hor" or "ver"
        end

        if moveOnAxis == "hor" then
          imdirx = u.sign(toPlx)
          imdiry = 0
          self.movingAxis = "hor"
        else
          imdirx = 0
          imdiry = u.sign(toPly)
          self.movingAxis = "ver"
        end

        -- If chasing, steps make sound
        snd.play(self.stepSounds[self.image_index])
      else
        -- Move randomly
        self.behaviourTimer = 1.3 + love.math.random() * 0.1

        -- Determine which axis to move on
        local moveOnAxis
        if self.unmovingAxis then
          moveOnAxis = self.unmovingAxis == "hor" and "ver" or "hor"
        else
          moveOnAxis = (love.math.random() < 0.5) and "hor" or "ver"
        end

        if moveOnAxis == "hor" then
          -- Move horizontally
          imdirx, imdiry = 1 - love.math.random(0, 1) * 2, 0
          self.movingAxis = "hor"
        else
          -- Move vertically
          imdirx, imdiry = 0, 1 - love.math.random(0, 1) * 2
          self.movingAxis = "ver"
        end
      end

      -- nilify collision axis
      self.unmovingAxis = nil

      -- Apply movement after calculating it
      local mXsf = self.mass * self.stepForce * (self.canSeePlayer and 1.4 or 1)
      self.body:applyLinearImpulse(imdirx * mXsf, imdiry * mXsf)

      -- Store position where movement starts to make sure I move
      self.lastx, self.lasty = self.x, self.y
    end

    td.walk(self, dt)
  end,

  hitSolidStatic = function (self, other, myF, otherF, coll)
    -- Remember on which axis I was moving when I hit wall
    self.unmovingAxis = self.movingAxis
  end,

  hitByMdust = function (self, other, myF, otherF)
    self.hitByMdust = u.emptyFunc
    other.createFire(self)
  end,

  onFireEnd = function (self)
    o.removeFromWorld(self)
    local newSkel = skel:new{
      xstart = self.x, ystart = self.y,
      x = self.x, y = self.y,
      layer = self.layer
    }
    o.addToWorld(newSkel)
  end,
}

function Mummy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Mummy, instance, init) -- add own functions and fields
  return instance
end

return Mummy
