local inv = require "inventory"
local td = require "movement"; td = td.top_down
local im = require "image"
local ps = require "physics_settings"

local o = require "GameObjects.objects"
local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"

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
    instance.sprite = im.sprites["Witch/hold_" .. side]
  else
    instance.sprite = im.sprites["Witch/hold_left"]
    instance.x_scale = -1
  end
end

player_states.end_fall = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
end

return player_states
