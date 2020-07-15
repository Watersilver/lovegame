local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"

local Ghost = {}

function Ghost.initialize(instance)
  instance.sprite_info = im.spriteSettings.ghost
  instance.zStart = - 4
  instance.zo = instance.zStart
  instance.zTimer = 0
  instance.flying = true -- can go through walls
  instance.grounded = false
  instance.controlledFlight = true
  instance.untouchable = true
  instance.lowFlight = true
  instance.ballbreakerEvenIfHigh = true
  instance.hp = 7 --love.math.random(3)
  instance.image_speed = 0.15
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  instance.maxspeed = 100
  instance.mfm = 2 -- Movement force mod, (how fast I circle around spot)
  instance.mfmah = 2 -- Movement force mod after getting hit
  instance.targetYDistance = 25
  instance.xImpulse = 55
  instance.attackDmg = 3
end

Ghost.functions = {
  enemyLoad = function (self)
    self.tx = self.x
    self.ty = self.y + self.targetYDistance
    self.mass = self.body:getMass()
    self.body:applyLinearImpulse(self.mass * self.mfm * self.xImpulse, 0)
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1

    -- If I get attacked once, follow (what I think is) player
    if self.attacked then
      self.chasePlayer = true
      self.mfm = self.mfmah
    end

    if self.chasePlayer and self.target then
      self.tx, self.ty = self.target.x, self.target.y
    end

    -- Caculate z
    self.zTimer = self.zTimer + dt * (self.chasePlayer and 10 or 3)
    self.zo = self.zStart + math.sin(self.zTimer) * 2

    -- Movement
    local fx, fy = self.tx - self.x, self.ty - self.y
    self.body:applyForce(fx * self.mass * self.mfm, fy * self.mass * self.mfm)

    -- Limit speed
    local vx, vy = self.body:getLinearVelocity()
    local speed = u.magnitude2d(vx, vy)
    if speed > self.maxspeed then
      local _, dir = u.cartesianToPolar(vx, vy)
      self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, dir))
    end

    -- Determine scale
    if vx > 0 then
      self.x_scale = -1
    else
      self.x_scale = 1
    end

    sh.handleShadow(self)
  end,
}

function Ghost:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Ghost, instance, init) -- add own functions and fields
  return instance
end

return Ghost
