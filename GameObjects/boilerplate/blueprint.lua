local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local sm = require "state_machine"
local u = require "utilities"
local o = require "GameObjects.objects"

-- objects I might want to inherit
-- local et = require "GameObjects.enemyTest"

-- local states = {
--   -- WARNING STARTING STATE IN INITIALIZE!!!
--   start = {
--     run_state = function(instance, dt)
--     end,
--     start_state = function(instance, dt)
--     end,
--     check_state = function(instance, dt)
--       if true then
--         instance.state:change_state(instance, dt, "next")
--       end
--     end,
--     end_state = function(instance, dt)
--     end
--   },
--   next = {
--     run_state = function(instance, dt)
--     end,
--     start_state = function(instance, dt)
--     end,
--     check_state = function(instance, dt)
--     end,
--     end_state = function(instance, dt)
--     end
--   },
-- }

local obj = {}

function obj.initialize(instance)
  -- If I want it to have some sprite
  -- instance.sprite_info = im.spriteSettings.blob
  -- instance.layer = 20
  -- instance.zo = 0
  -- instance.x_scale = 1
  -- instance.y_scale = 1
  -- instance.image_speed = 0
  -- instance.image_index = 0

  -- instance.state = sm.new_state_machine(states)
  -- instance.state.state = "start"

  -- instance.impact = 20 -- how far I throw the player
  -- instance.damager = 1 -- how much damage I cause
  -- instance.grounded = true -- can be jumped over
  -- instance.flying = false -- can go through walls
  -- instance.goThroughPlayer = false -- can go through player
  -- instance.jumping = false -- can go over player and other non solids
  -- instance.levitating = false -- can go through over hazardous floor
  -- instance.actAszo0 = false -- move in regards to floor friction etc as if grounded
  -- instance.controlledFlight = false -- Floor doesn't affect me at all, but I still have breaks on air
  -- instance.lowFlight = false -- can be affected by attacks that only target grounded targets
  -- instance.canSeeThroughWalls = false -- what it says on the tin
  -- instance.shielded = false -- can be damaged
  -- instance.shieldDown = false -- shield temporarily disabled
  -- instance.shieldWall = false -- can be propelled by force
  -- instance.weakShield = false -- shield can be broken with empowered sword and bombs
  -- instance.mediumShield = false -- shield can be broken with empowered sword and empowered bombs
  -- instance.hardShield = false -- shield can be broken with empowered bombs
  -- instance.attackDodger = false -- weapon that hit me doesn't react
  -- instance.ballbreaker = true -- breaks magic missiles
  -- instance.bombGoesThrough = true -- thrown bomb doesn't collide with this
  -- instance.canBeBullrushed = true -- can be damaged by bullrush
  -- instance.canBeRolledThrough = true -- doesn't cause recoil when colliding while rolling
  -- instance.pushback = true -- Recoil for player hitting it with sword
  -- instance.forceSwordSound = true -- sword sounds like hitting solid

  -- instance.ignoreFloorMovementModifiers = true
  -- instance.maxspeed = 20
end

obj.functions = {
  -- load = function (self)
  -- end,

  -- remember to use enemyUpdate if inheriting from enemy
  -- update = function (self)
    -- -- Get tricked by decoy
    -- self.target = session.decoy or pl1

    -- -- do stuff depending on state
    -- local state = self.state
    -- state.states[state.state].check_state(self, dt)
    -- state.states[state.state].run_state(self, dt)
  -- end,

  -- draw = function (self)
  -- end,

  -- trans_draw = function (self)
  -- end,

  -- beginContact = function (self, a, b, coll)
  -- end,

  -- endContact = function (self, a, b, coll)
  -- end,

  -- preSolve = function (self, a, b, coll)
  -- end,
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
