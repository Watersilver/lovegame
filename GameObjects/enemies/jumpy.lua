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

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "jump")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  jump = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.zvel = 100
      instance.image_index = 1
      local _, dir
      local x, y = instance.body:getPosition()
      if instance.canSeePlayer and love.math.random() <= instance.jumpTowardsPlayerChance then
        _, dir = u.cartesianToPolar(instance.target.x - x, instance.target.y - y)
      else
        dir = (love.math.random() * 2 - 1) * math.pi
      end
      local mass = instance.body:getMass()
      local imx, imy = u.polarToCartesian(love.math.random(10, 100) * mass, dir)
      instance.body:applyLinearImpulse(imx, imy)

      -- Make jump sound
      if not u.isOutsideGamera(self, mainCamera) then
        snd.play(glsounds.enemyJump)
      end
    end,
    check_state = function(instance, dt)
      if instance.zo >= 0 then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  grounded = {
    run_state = function(instance, dt)
      td.stand_still(instance)
      instance.groundTimer = instance.groundTimer - dt
    end,
    start_state = function(instance, dt)
      instance.groundTimer = 1
      instance.image_index = 0
    end,
    check_state = function(instance, dt)
      if instance.groundTimer < 0 then
        instance.state:change_state(instance, dt, "jump")
      end
    end,
    end_state = function(instance, dt)
    end
  },
}

local Jumpy = {}

function Jumpy.initialize(instance)
  instance.sprite_info = im.spriteSettings.jumpy
  instance.hp = 6 --love.math.random(3)
  -- instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.jumpTowardsPlayerChance = 0
  instance.attackDmg = 2
  instance.zo = 0
  instance.gravity = 250
  instance.unpushable = true
  instance.layer = 25
  instance.spritefixture_properties = false
  instance.sightDistance = 160
end

Jumpy.functions = {
  enemyLoad = function (self)
    self.startingLayer = self.layer
  end,

  enemyUpdate = function (self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(self.target) end

    -- do stuff depending on state
    local state = self.state
    -- Check state
    state[state.state].check_state(self, dt)
    -- Run state
    state[state.state].run_state(self, dt)

    -- check if on player level
    if pl1 then
      if (self.zo > -ps.shapes.plshapeHeight) and self.hp > 0 then
        self.harmless = false
        self.attackDodger = false
        self.undamageable = false
        self.jumping = false
        o.change_layer(self, 19)
      else
        self.harmless = true
        self.attackDodger = true
        self.undamageable = true
        self.jumping = true
        o.change_layer(self, self.startingLayer)
      end
    end

    td.zAxis(self, dt)

    sh.handleShadow(self)

    self.bounced = false
  end,

  hitStatic = function (self, other, myF, otherF, coll)

    -- only bounce once per frame
    if self.bounced then return end

    -- Get vector perpendicular to collision
    local nx, ny = coll:getNormal()

    -- Make sure it points AWAY from obstacle if applied to jumpy
    local dx, dy = self.x - other.x, self.y - other.y
    if nx * dx < 0 or ny * dy < 0 then -- checks if they have different signs
      nx, ny = -nx, -ny
    end

    -- My velocity coords
    local vx, vy = self.body:getLinearVelocity()
    local rx, ry = u.reflect(vx, vy, nx, ny)
    self.body:setLinearVelocity(rx, ry)

    self.bounced = true
  end
}

function Jumpy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Jumpy, instance, init) -- add own functions and fields
  return instance
end

return Jumpy
