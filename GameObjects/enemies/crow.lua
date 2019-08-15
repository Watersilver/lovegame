local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"

local cos = math.cos
local abs = math.abs
local pi = math.pi

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  grounded = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.sightDistance = 64
      instance.image_speed = 0
      instance.image_index = 0
      instance.image_index_prev = 0
      instance.zo = 0
      instance.body:setLinearVelocity(0, 0)
    end,
    check_state = function(instance, dt)
      if (instance.lookFor and instance:lookFor(pl1)) or instance.attacked then
        instance.state:change_state(instance, dt, "rising")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  rising = {
    run_state = function(instance, dt)
      instance.zo = instance.maxHeight * instance.risePrecentage
      instance.risePrecentage = instance.risePrecentage + dt * 2
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0.1
      instance.risePrecentage = 0
      instance.body:setLinearVelocity(0, 0)
    end,
    check_state = function(instance, dt)
      if instance.zo <= instance.maxHeight then
        instance.state:change_state(instance, dt, "chase")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  chase = {
    run_state = function(instance, dt)
      instance.chargeTimer = instance.chargeTimer + dt
      if pl1 and not pl1.deathState then
        -- if just done getting damaged, reset speed
        if not instance.invulnerableEnd then
          -- get vector perpendicular to velocity
          local perpx, perpy = u.perpendicularRightTurn2d(instance.body:getLinearVelocity())
          local nprojx, nprojy = u.normalize2d(u.projection2d(pl1.x - instance.x, pl1.y - instance.y, perpx, perpy))
          local mass = instance.body:getMass()
          instance.body:applyForce(nprojx * mass * 222, nprojy * mass * 222)
        else
          local nvcx, nvcy = u.normalize2d(pl1.x - instance.x, pl1.y - instance.y)
          instance.body:setLinearVelocity(nvcx * instance.maxSpeed, nvcy * instance.maxSpeed)
        end
      end
    end,
    start_state = function(instance, dt)
      instance.zo = instance.maxHeight
      instance.sightDistance = 112
      instance.image_speed = 0.12
      instance.chargeTimer = 0
      instance.chargeDuration = 3
      if pl1 then
        -- normal vector components
        local nvcx, nvcy = u.normalize2d(pl1.x - instance.x, pl1.y - instance.y)
        instance.body:setLinearVelocity(nvcx * instance.maxSpeed, nvcy * instance.maxSpeed)
      end
    end,
    check_state = function(instance, dt)
      if instance.chargeTimer > instance.chargeDuration then
        instance.state:change_state(instance, dt, "fly_away")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  fly_away = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(instance.uvx * instance.maxSpeed, instance.uvy * instance.maxSpeed)
    end,
    start_state = function(instance, dt)
      instance.zo = instance.maxHeight
      instance.uvx, instance.uvy = u.normalize2d(instance.body:getLinearVelocity())
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },
}

local Crow = {}

function Crow.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.crow
  instance.maxHeight = -5
  instance.zo = 0
  instance.ballbreakerEvenIfHigh = true
  instance.actAszo0 = true
  instance.grounded = false
  instance.unpushable = true
  instance.canLeaveRoom = true
  instance.canSeeThroughWalls = true -- what it says on the tin
  instance.hp = 2 --love.math.random(3)
  instance.maxSpeed = 111
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

Crow.functions = {
  enemyUpdate = function (self, dt)
    if not self.outOfBounds then
      if self.x + 8 < 0 or self.x - 8 > game.room.width then
        o.removeFromWorld(self)
      elseif self.y < -8 or self.y > game.room.height + (8 + abs(self.maxHeight)) then
        o.removeFromWorld(self)
      end
    end

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state[state.state].check_state(self, dt)
    -- Run animation state
    state[state.state].run_state(self, dt)

    -- Check when to make wing sound
    if self.image_index_prev < 1 and self.image_index > 1 then
      local l,t,w,h = mainCamera:getVisible()
      local isOutsideGamera =
        (self.x + 8 < l) or (self.x - 8 > l + w)
        or (self.y + 8 < t) or (self.y - (8 + abs(self.maxHeight)) > t + h)
      if not isOutsideGamera then
        snd.play(glsounds.wingFlap)
      end
    end
    self.image_index_prev = self.image_index

    sh.handleShadow(self)
  end,
}

function Crow:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Crow, instance, init) -- add own functions and fields
  return instance
end

return Crow
