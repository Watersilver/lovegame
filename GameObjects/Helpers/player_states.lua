local inv = require "inventory"
local td = require "movement"; td = td.top_down
local im = require "image"
local ps = require "physics_settings"

local o = require "GameObjects.objects"
local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"
local msl = require "GameObjects.Items.missile"

local floor = math.floor

local player_states = {}

player_states.check_walk = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if inv.check_use(instance, trig, side) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side) then
  elseif td.check_walk_while_walking(instance, trig, side) then
  elseif td.check_halt_a(instance, trig, side) then
  elseif trig.restish then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.check_halt = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if inv.check_use(instance, trig, side) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side) then
  elseif td.check_walk_a(instance, trig, side) then
  elseif trig.restish then
    instance.animation_state:change_state(instance, dt, side .. "still")
  elseif td.check_halt_notme(instance, trig, side) then
  end
end

player_states.check_still = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if inv.check_use(instance, trig, side) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side) then
  elseif td.check_walk_a(instance, trig, side) then
  elseif td.check_halt_a(instance, trig, side) then
  end
end

player_states.check_push = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if inv.check_use(instance, trig, side) then
  elseif not trig["push_" .. side] then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.run_swing = function(instance, dt, side)
  local trig = instance.triggers

  -- Manage position offset and image speed
  if trig.animation_end then
    instance.image_speed = 0
    instance.image_index = 1.99
  else
    inv.sword.image_offset(instance, dt, side)
  end
end

player_states.check_swing = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
  elseif otherstate == "normal" then
    if trig.hold_sword then
      instance.animation_state:change_state(instance, dt, side .. "hold")
    else
      instance.animation_state:change_state(instance, dt, side .. "still")
    end
  end
end

player_states.start_swing = function(instance, dt, side)
  instance.image_index = 0
  instance.image_speed = 0.20
  instance.triggers.animation_end = false
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/swing_" .. side]
  else
    instance.sprite = im.sprites["Witch/swing_left"]
    instance.x_scale = -1
  end
  -- Create sword
  instance.sword = sw:new{
    creator = instance,
    side = side,
    layer = instance.layer
  }
  o.addToWorld(instance.sword)
end

player_states.end_swing = function(instance, dt, side)
  instance.ioy, instance.iox = 0, 0
  instance.image_index = 0
  instance.image_speed = 0
  if instance.floorFriction > 0.9 and instance.sword.hitWall then
    instance.body:setLinearVelocity(0, 0)
  end
  -- Delete sword
  o.removeFromWorld(instance.sword)
  instance.sword = nil

  if side == "right" then
    instance.x_scale = 1
  end
end

player_states.run_stab = function(instance, dt, side)
  -- Manage position offset and image speed
  instance.stab_offset = instance.stab_offset + instance.stab_offset_speed * dt * 60
  if instance.stab_offset > 1.99 then
    instance.stab_offset_speed = 0
    instance.stab_offset = 1.99
  else
    local image_index_store = instance.image_index
    instance.image_index = instance.stab_offset
    inv.sword.image_offset(instance, dt, side)
    instance.image_index = image_index_store
  end
end

player_states.check_stab = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if otherstate == "normal" then
    if trig.hold_sword then
      instance.animation_state:change_state(instance, dt, side .. "hold")
    else
      instance.animation_state:change_state(instance, dt, side .. "still")
    end
  end
end

player_states.start_stab = function(instance, dt, side)
  instance.image_index = 1
  instance.image_speed = 0
  instance.stab_offset_speed = 0.20
  instance.stab_offset = 0
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/swing_" .. side]
  else
    instance.sprite = im.sprites["Witch/swing_left"]
    instance.x_scale = -1
  end
  -- Create sword
  instance.sword = sw:new{
    creator = instance,
    side = side,
    stab = true,
    layer = instance.layer
  }
  o.addToWorld(instance.sword)
end

player_states.end_stab = player_states.end_swing

player_states.check_hold = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if trig.stab then
    instance.animation_state:change_state(instance, dt, side .. "stab")
  elseif not trig.hold_sword then
    instance.animation_state:change_state(instance, dt, side .. "walk")
  end
end

player_states.start_hold = function(instance, dt, side)
  instance.image_index = 0
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/hold_" .. side]
  else
    instance.sprite = im.sprites["Witch/hold_left"]
    instance.x_scale = -1
  end
  -- Create sword
  instance.sword = hsw:new{creator = instance, side = side, layer = instance.layer}
  o.addToWorld(instance.sword)
end

player_states.start_jump = function(instance, dt, side)
  instance.zvel = 110
  instance.animation_state:change_state(instance, dt, side .. "fall")
end

player_states.run_fall = function(instance, dt, side)
  if instance.zvel > 40 then -- H 10
    instance.image_index = 0
  elseif instance.zvel < -40 then -- H -10
    instance.image_index = 2
  else
    instance.image_index = 1
  end
end

player_states.check_fall = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
  elseif instance.zo == 0 then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_fall = function(instance, dt, side)
  instance.image_index = 0
  instance.image_speed = 0
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/jump_" .. side]
  else
    instance.sprite = im.sprites["Witch/jump_left"]
    instance.x_scale = -1
  end
end

player_states.end_fall = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
end

player_states.run_missile = function(instance, dt, side)
  instance.missile_cooldown = instance.missile_cooldown + dt
  td.image_speed(instance, dt)
  if instance.speed < 5 then
    if floor(instance.image_index) ~= 3 then
      instance.image_index = 1
    end
  end
end

player_states.check_missile = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if instance.missile_cooldown > instance.missile_cooldown_limit then
    if trig.fire_missile then
      instance.animation_state:change_state(instance, dt, side .. "missile")
    else
      instance.animation_state:change_state(instance, dt, side .. "walk")
    end
  end
end

player_states.start_missile = function(instance, dt, side)
  instance.missile_cooldown = 0
  instance.missile_cooldown_limit = instance.missile_cooldown_limit
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/shoot_" .. side]
  else
    instance.sprite = im.sprites["Witch/shoot_left"]
    instance.x_scale = -1
  end
  -- Create missile
  local misslayer = instance.layer
  if side == "up" then misslayer = misslayer - 1 end
  instance.missile = msl:new{
    creator = instance,
    side = side,
    layer = misslayer
  }
  o.addToWorld(instance.missile)
end

player_states.end_missile = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  if instance.missile_cooldown < instance.missile_cooldown_limit then
    o.removeFromWorld(instance.missile)
    return
  end
  instance.missile_cooldown = nil

  if instance.missile then
    instance.missile.fired = true

    if not instance.missile.body:isDestroyed() then
      local mslvx, mslvy = instance.missile.body:getLinearVelocity()
      local firevelx, firevely = 0, 0

      -- If I add spritebody to missile, the speed I add will get cut in half
      if side == "up" then
        firevely = - instance.maxspeed
      elseif side == "down" then
        firevely = instance.maxspeed
      elseif side == "left" then
        firevelx = - instance.maxspeed
      else
        firevelx = instance.maxspeed
      end
      instance.missile.image_index = instance.missile.sprite.frames - 1
      instance.missile.body:setLinearVelocity(mslvx+firevelx, mslvy+firevely)
    end

  end -- instance.missile

end

player_states.run_gripping = function(instance, dt, side)
  td.image_speed(instance, dt)
  if instance.speed < 5 then
    instance.image_index = 0
  end
end

player_states.check_gripping = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if not trig.grip then
    instance.animation_state:change_state(instance, dt, side .. "walk")
  end
end

player_states.start_gripping = function(instance, dt, side)
  instance.image_index = 0
  instance.image_speed = 0
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/grip_" .. side]
  else
    instance.sprite = im.sprites["Witch/grip_left"]
    instance.x_scale = -1
  end
  local other
  local touchedObTable = instance.sensors[side .. "TouchedObs"]
  for _, touchedOb in ipairs(touchedObTable) do
    other = touchedOb
  end
  if other and other.body then
    instance.grippedOb = other
    instance.grip = love.physics.newWeldJoint(
      other.body, instance.body, instance.x, instance.y, true
    )
  end
end

player_states.end_gripping = function(instance, dt, side)
  instance.grippedOb = nil
  if instance.grip then instance.grip:destroy(); instance.grip = nil end
end

return player_states
