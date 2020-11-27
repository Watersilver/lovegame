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
local sm = require "state_machine"


local function restrictMovement(instance)
  -- Restrict movement according to facing
  if instance.facing == "up" or instance.facing == "down" then
    instance.body:setPosition(instance.xstart, instance.y)
    instance.body:setLinearVelocity(0, instance.vy)
  else
    instance.body:setPosition(instance.x, instance.ystart)
    instance.body:setLinearVelocity(instance.vx, 0)
  end
end


local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  still = {
    run_state = function(instance, dt)
      -- Get random direction index
      instance.facing = u.chooseKeyFromTable(instance.directions)
    end,
    start_state = function(instance, dt)
      instance.body:setPosition(instance.xstart, instance.ystart)
      instance.body:setType("static")
    end,
    check_state = function(instance, dt)
      if instance:lookFor(instance.target) then
        instance.state:change_state(instance, dt, "charging")
      end
    end,
    end_state = function(instance, dt)
      instance.body:setType("dynamic")
    end
  },

  charging = {
    run_state = function(instance, dt)
      -- Restrict movement according to facing
      restrictMovement(instance)
    end,
    start_state = function(instance, dt)
      snd.play(instance.moveSound)
      -- Determine velocity using facing
      local newVx, newVy
      if instance.facing == "up" then
        newVx, newVy = 0, -instance.chargeSpeed
      elseif instance.facing == "down" then
        newVx, newVy = 0, instance.chargeSpeed
      elseif instance.facing == "left" then
        newVx, newVy = -instance.chargeSpeed, 0
      else
        newVx, newVy = instance.chargeSpeed, 0
      end
      instance.body:setLinearVelocity(newVx, newVy)
      -- overwrite vx, vy values because of the restrict movement function that would stop movement
      instance.vx, instance.vy = newVx, newVy
    end,
    check_state = function(instance, dt)
      if (math.abs(instance.vx) < 5 and math.abs(instance.vy) < 5) or instance.collided then
        instance.state:change_state(instance, dt, "returning")
      end
    end,
    end_state = function(instance, dt)
      snd.play(instance.collideSound)
    end
  },

  returning = {
    run_state = function(instance, dt)
      -- Restrict movement according to facing
      restrictMovement(instance)
    end,
    start_state = function(instance, dt)
      instance.body:setType("kinematic")
      -- Determine velocity using position
      local newVx, newVy
      if math.abs(instance.x - instance.xstart) > math.abs(instance.y - instance.ystart) then
        newVx, newVy = -u.sign(instance.x - instance.xstart) * instance.returnSpeed, 0
      else
        newVx, newVy = 0, -u.sign(instance.y - instance.ystart) * instance.returnSpeed
      end
      instance.body:setLinearVelocity(newVx, newVy)
      -- overwrite vx, vy values because of the restrict movement function that would stop movement
      instance.vx, instance.vy = newVx, newVy
    end,
    check_state = function(instance, dt)
      if math.abs(instance.x - instance.xstart) < 1 and math.abs(instance.y - instance.ystart) < 1 then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
      instance.body:setType("dynamic")
    end
  },
}

local BladeTrap = {}

function BladeTrap.initialize(instance)
  instance.sprite_info = im.spriteSettings.bladeTrap
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.physical_properties.density = 4000
  instance.hp = 40
  instance.sightDistance = 112
  instance.sightWidth = 12
  instance.universalForceMod = 0
  instance.image_speed = 0
  instance.shieldWall = true
  instance.shielded = true
  instance.pushback = true
  instance.mediumShield = true
  instance.attackDmg = 1.5
  instance.chargeSpeed = 150
  instance.returnSpeed = 50
  -- Directions I am keeping an eye on
  instance.directions = {up = 0, down = 1, left = 2, right = 3}
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.canBeBullrushed = false
  instance.moveSound = snd.load_sound({"Effects/Oracle_Sword_Slash2"})
  instance.collideSound = snd.load_sound({"Effects/Oracle_Sword_Tap"})
end

BladeTrap.functions = {
  enemyLoad = function (self)
    -- self.directions.down = nil
    -- self.directions.up = nil
    -- self.directions.left = nil
    -- self.directions.right = nil
    self.mass = self.body:getMass()
  end,

  enemyUpdate = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    -- Check state
    state.states[state.state].check_state(self, dt)
    -- Run state
    state.states[state.state].run_state(self, dt)

    self.image_index = self.directions[self.facing] or 0

    self.collided = false
  end,

  enemyBeginContact = function (self, other, myF, otherF)
    if not otherF:isSensor() and (other.body:getType() == "static" or other.body:getType() == "kinematic") then
      self.collided = true
    end
  end,
}

function BladeTrap:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(BladeTrap, instance, init) -- add own functions and fields
  return instance
end

return BladeTrap
