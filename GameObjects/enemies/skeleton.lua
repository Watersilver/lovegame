local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"
local zAxis = require "movement"; zAxis = zAxis.top_down.zAxis
local o = require "GameObjects.objects"
local snd = require "sound"

local proj = require "GameObjects.enemies.projectile"

local Skeleton = {}

function Skeleton.initialize(instance)
  instance.sprite_info = im.spriteSettings.skeleton
  instance.hp = 4
  instance.image_speed = 0.2
  instance.maxspeed = 40
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.jumpChance = 0.7
  instance.throwySkull = false
  instance.unpushable = true
  instance.zo = 0
  instance.zvel = 0
  instance.gravity = 444
  instance.boneAvgFrequency = 5
  instance.jumpSound = glsounds.enemyJump
end

Skeleton.functions = {
  enemyLoad = function (self)
    self:resetBoneTimer()
  end,

  resetBoneTimer = function (self)
    self.boneTimer = self.boneAvgFrequency * (1 + 0.4 * love.math.random())
  end,

  enemyUpdate = function (self, dt)

    self.target = session.decoy or pl1

    -- Movement behaviour
    if self.behaviourTimer < 0 then
      self.direction = math.pi * 2 * love.math.random()
      self.behaviourTimer = love.math.random(2)
    end

    zAxis(self, dt)

    sh.handleShadow(self)

    if self.zo == 0 then
      td.analogueWalk(self, dt)
      self:grounded()

      if self.throwySkull then

        -- When bone timer is zero throw bone
        if self.boneTimer <= 0 then

          -- Only throw bone when close to player
          if u.distance2d(self.target.x, self.target.y, self.x, self.y) < 100 then
            local bone = proj:new{
              xstart = self.x, ystart = self.y,
              attackDmg = 1.3, layer = self.layer,
              sprite_info = im.spriteSettings.bone,
              enemBone = true
            }

            -- Try to hit target
            if self.target then
              local _, dir = u.cartesianToPolar(self.target.x - self.x, self.target.y - self.y)
              bone.direction = dir
            end

            o.addToWorld(bone)
          end

          self:resetBoneTimer()
        end

        self.boneTimer = self.boneTimer - dt
      end

    else
      if self.boneTimer < 1 then
        self.boneTimer = 1
      end
    end

  end,

  jump = function (self)
    self.zvel = 155
    self.harmless = true
    self.undamageable = true
    self.attackDodger = true
    self.jumping = true
    self.sprite = im.sprites["Enemies/Skeleton/jump"]
    snd.play(self.jumpSound)
  end,

  grounded = function (self)
    self.harmless = false
    self.undamageable = false
    self.attackDodger = false
    self.jumping = false
    self.sprite = im.sprites["Enemies/Skeleton/skeleton"]
  end,

  hitBySword = function (self, other, myF, otherF)
    if love.math.random() < self.jumpChance then
      self:jump()
      if self.target then
        local jumpSpeed = 10 + love.math.random() * 50
        local newVx, newVy = u.normalize2d(self.x - self.target.x, self.y - self.target.y)
        newVx, newVy = newVx * jumpSpeed, newVy * jumpSpeed
        self.body:setLinearVelocity(newVx, newVy)
      end
    else
      ebh.damagedByHit(self, other, myF, otherF)
      ebh.propelledByHit(self, other, myF, otherF)
    end
  end,

  enemyBeginContact = function (self, other, myF, otherF, coll)

    -- Get vector perpendicular to collision
    local nx, ny = coll:getNormal()

    -- make sure it points AWAY from obstacle if applied to object
    if not other.x then return end
    local dx, dy = self.x - other.x, self.y - other.y
    if nx * dx < 0 or ny * dy < 0 then -- checks if they have different signs
      nx, ny = -nx, -ny
    end
    self._, self.direction = u.cartesianToPolar(u.reflect(self.vx, self.vy, nx, ny))
  end,
}


function Skeleton:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Skeleton, instance, init) -- add own functions and fields
  return instance
end

return Skeleton
