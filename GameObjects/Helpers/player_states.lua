local inv = require "inventory"
local td = require "movement"; td = td.top_down
local im = require "image"
local inp = require "input"
local snd = require "sound"
local ps = require "physics_settings"
local dlg = require "dialogue"
local u = require "utilities"
local explode = require "GameObjects.explode"

local o = require "GameObjects.objects"
local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"
local msl = require "GameObjects.Items.missile"
local lft = require "GameObjects.Items.lifted"
local mdu = require "GameObjects.Items.mdust"
local pddp = require "GameObjects.Helpers.triggerCheck"; pddp = pddp.playerDieDrownPlummet

-- TODO: Fix carry and other animations when hitting wall
-- TODO?: Idle animations

local floor = math.floor
local random = math.random

local emptyFunc = function() end

local player_states = {}

local should_play_footstep_sound = function (instance)
  local frames = instance.sprite.frames
  if frames == 10 then
    if
      (
        instance.image_speed > 0 and
        (
          (instance.image_index >= 4 and instance.image_index_prev < 4)
          or (instance.image_index >= 9 and instance.image_index_prev < 9)
        )
      ) or (
        instance.image_speed < 0 and
        (
          (instance.image_index <= 4 and instance.image_index_prev > 4)
          or (instance.image_index <= 9 and instance.image_index_prev > 9)
        )
        and instance.animationFramesPassed > 1
      )
    then
      return true
    end
  elseif frames == 8 then
    if instance.immasprint then
      if
        (
          instance.image_speed > 0 and
          (
            (instance.image_index >= 1 and instance.image_index_prev < 1)
            or (instance.image_index >= 5 and instance.image_index_prev < 5)
          )
        ) or (
          instance.image_speed < 0 and
          (
            (instance.image_index <= 1 and instance.image_index_prev > 1)
            or (instance.image_index <= 5 and instance.image_index_prev > 5)
          )
          and instance.animationFramesPassed > 1
        )
      then
        return true
      end
    else
      if
        (
          instance.image_speed > 0 and
          (
            (instance.image_index >= 2 and instance.image_index_prev < 2)
            or (instance.image_index >= 6 and instance.image_index_prev < 6)
          )
        ) or (
          instance.image_speed < 0 and
          (
            (instance.image_index <= 2 and instance.image_index_prev > 2)
            or (instance.image_index <= 6 and instance.image_index_prev > 6)
          )
          and instance.animationFramesPassed > 1
        )
      then
        return true
      end
    end
  end
  return false
end

player_states.img_speed_and_footstep_sound = function(instance, dt)
  td.image_speed(instance, dt)
  local f = instance:getFacing()
  local vx, vy = instance.body:getLinearVelocity()

  -- if
  --   (f == 'up' and vy > 0)
  --   or (f == 'down' and vy < 0)
  --   or (f == 'left' and vx > 0)
  --   or (f == 'right' and vx < 0)
  -- then
  --   instance.image_speed = -instance.image_speed
  -- end

  if
    (f == 'up' and vy > -0.01)
    or (f == 'down' and vy < 0.01)
    or (f == 'left' and vx > -0.01)
    or (f == 'right' and vx < 0.01)
  then
    instance.image_speed = -instance.image_speed
  end

  -- print(vy < 0, math.abs(vy) < 0.01)

  if should_play_footstep_sound(instance) then
    snd.playFootstepSound(instance.closestTile, instance.inShallowWater)
  end
end

local img_speed_and_footstep_sound = player_states.img_speed_and_footstep_sound

player_states.run_walk = function(instance, dt, side)
  img_speed_and_footstep_sound(instance, dt)
  if math.floor(instance.image_index + 1) % 5 ~= 0 then
    local fii = math.floor(instance.image_index)
    if fii % 5 == 0 then
      instance.fake_zo = -1
    elseif (fii + 2) % 5 == 0 then
      instance.fake_zo = -2
    elseif (fii + 3) % 5 == 0 or (fii + 4) % 5 == 0 then
      instance.fake_zo = -3
    end
  else
    instance.fake_zo = 0
  end
end

player_states.check_walk = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif not instance:grounded() then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side, dt) then
  elseif td.check_walk_while_walking(instance, trig, side, dt) then
  elseif td.check_halt_a(instance, trig, side, dt) then
  elseif trig.restish then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_walk = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = -1
    side = 'left'
  end

  instance.sprite = im.sprites["Witch/walk_" .. side]
end

player_states.end_walk = function(instance, dt, side)
  instance.fake_zo = 0
  if side == "right" then
    instance.x_scale = 1
  end
end

player_states.run_halt = function(instance, dt, side)
  if instance.triggers.animation_end then
    instance.stillhalt = nil
    instance.image_speed = 0
    instance.image_index = instance.sprite.frames - 1
  end
end

player_states.check_halt = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif not instance:grounded() then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side, dt) then
  elseif td.check_walk_a(instance, trig, side, dt) then
  elseif trig.restish and not instance.stillhalt then
    instance.animation_state:change_state(instance, dt, side .. "still")
  elseif td.check_halt_notme(instance, trig, side, dt) then
  end
end

player_states.start_halt = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = -1
    side = 'left'
  end
  instance.triggers.animation_end = false

  instance.image_index = 0
  instance.image_speed = 0.25

  instance.sprite = im.sprites["Witch/skid_" .. side]
  if instance.speed > 95 and instance.sprite.frames > 1 then
    instance.stillhalt = true
  else
    instance.image_speed = 0
    instance.image_index = instance.sprite.frames - 1
  end
end

player_states.end_halt = function(instance, dt, side)
  instance.stillhalt = nil
  if side == "right" then
    instance.x_scale = 1
  end
end

-- TODO: breath fast after running for long, take deep breath exhale
-- and stay without air for a while and afterwards calm breathing
player_states.run_still = function(instance, dt, side)
  -- local wasLanding = instance.is_landing
  -- if instance.is_landing then
  --   print(instance.image_index)
  -- end
  if string.gmatch(instance.sprite.name, "idle_landing_") then
    -- if instance.is_landing then
    --   print(instance.image_index)
    -- end
    if instance.state_start_frame < math.floor(instance.image_index) - 1 then
      instance.short_landing = nil
    end
    if instance.triggers.animation_end then
      instance.is_landing = nil
      instance.short_landing = nil
      if side ~= "right" then
        instance.sprite = im.sprites["Witch/idle_" .. side]
      else
        instance.sprite = im.sprites["Witch/idle_left"]
        instance.x_scale = -1
      end
    end
    -- if instance.is_landing then
    --   print(instance.image_index)
    -- end
  end
  -- if instance.is_landing then
  --   print('animation end', instance.triggers.animation_end)
  --   print(instance.sprite.name)
  -- end
  -- if wasLanding and not instance.is_landing then
  --   print('end =================')
  -- end
end

player_states.check_still = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state

  local jump_side = side

  if instance.speed > 5 and instance:holdingDirectionalKey() then
    if math.abs(instance.vx) > math.abs(instance.vy) then
      if instance.vx > 0 then
        jump_side = "right"
      else
        jump_side = "left"
      end
    else
      if instance.vy > 0 then
        jump_side = "down"
      else
        jump_side = "up"
      end
    end
  end

  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt, jump_side) then
  elseif not instance:grounded() then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif not instance.short_landing and td.check_push_a(instance, trig, side, dt) then
  elseif not instance.short_landing and td.check_walk_a(instance, trig, side, dt) then
  elseif not instance.no_halt and td.check_halt_a(instance, trig, side, dt) then
  end

end

player_states.start_still = function(instance, dt, side)
  instance.image_index = 0
  instance.state_start_frame = instance.image_index
  instance.triggers.animation_end = nil
  if instance.just_landed then
    instance.no_halt = true
    instance.just_landed = nil
    instance.is_landing = true
    instance.short_landing = true
    instance.image_speed = 0.3
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/idle_landing_" .. side]
    else
      instance.sprite = im.sprites["Witch/idle_landing_left"]
      instance.x_scale = -1
    end
    if instance.soft_landing then
      instance.image_index = instance.sprite.frames - 2
      instance.state_start_frame = instance.image_index
    end
  else
    instance.image_speed = 0.07
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/idle_" .. side]
    else
      instance.sprite = im.sprites["Witch/idle_left"]
      instance.x_scale = -1
    end
  end
end

player_states.end_still = function(instance, dt, side)
  instance.is_landing = nil
  instance.short_landing = nil
  instance.soft_landing = nil
  instance.no_halt = nil
  if side == "right" then
    instance.x_scale = 1
  end
end


player_states.run_push = function(instance, dt, side)
  img_speed_and_footstep_sound(instance, dt)
  instance.image_speed = math.max(0.05, instance.image_speed)
end

player_states.check_push = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif not trig["push_" .. side] then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_push = function(instance, dt, side)
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/push_" .. side]
  else
    instance.sprite = im.sprites["Witch/push_left"]
    instance.x_scale = -1
  end
end

player_states.end_push = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
end


player_states.run_swing = function(instance, dt, side)
  local trig = instance.triggers

  -- Manage position offset and image speed
  if trig.animation_end then
    instance.image_speed = 0
    instance.image_index = instance.sprite.frames - 0.01
  else
    inv.sword.image_offset(instance, dt, side)
  end
end

player_states.check_swing = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif trig.swing_sword and session.save.swordLvl > 2 then
    instance.animation_state:change_state(instance, dt, side .. "swing")
  elseif otherstate == "normal" then
    if trig.hold_sword and instance.sword then
      instance.animation_state:change_state(instance, dt, side .. "hold")
    else
      instance.animation_state:change_state(instance, dt, side .. "still")
    end
  end
end

player_states.start_swing = function(instance, dt, side)
  instance.swingingSword = true
  -- random swing sound
  local randomizeSwing = random()
  snd.play(glsounds.lasersword)
  -- if randomizeSwing < 0.34 then
  --   snd.play(instance.sounds.swordSlash1)
  -- elseif randomizeSwing < 0.67 then
  --   snd.play(instance.sounds.swordSlash2)
  -- else
  --   snd.play(instance.sounds.swordSlash3)
  -- end
  instance.image_index = 0
  instance.triggers.animation_end = false

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/swing_" .. side]
  else
    instance.sprite = im.sprites["Witch/swing_left"]
    instance.x_scale = -1
  end

  instance.image_speed = instance.sprite.frames * 0.0667
  -- Create sword
  instance.sword = sw:new{
    creator = instance,
    side = side,
    layer = instance.layer
  }
  o.addToWorld(instance.sword)
end

player_states.end_swing = function(instance, dt, side)
  instance.swingingSword = false
  instance.ioy, instance.iox = 0, 0
  instance.image_index = 0
  instance.image_speed = 0
  if instance.floorFriction > 0.9 and instance.sword and instance.sword.hitWall then
    instance.body:setLinearVelocity(0, 0)
  end
  -- Delete sword
  if instance.sword then
    o.removeFromWorld(instance.sword)
    instance.sword = nil
  end

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
  if pddp(instance, trig, side, dt) then
  elseif otherstate == "normal" then
    if trig.hold_sword and instance.sword then
      instance.animation_state:change_state(instance, dt, side .. "hold")
    else
      instance.animation_state:change_state(instance, dt, side .. "still")
    end
  end
end

player_states.start_stab = function(instance, dt, side)
  instance.image_speed = 0
  instance.stab_offset_speed = 0.20
  instance.stab_offset = 0

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/swing_" .. side]
  else
    instance.sprite = im.sprites["Witch/swing_left"]
    instance.x_scale = -1
  end
  instance.image_index = instance.sprite.frames - 1

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

player_states.run_hold = function(instance, dt, side)
  local idling = false

  -- Update spin attack counter
  instance.spinAttackCounter = instance.spinAttackCounter + dt
  if session.save.faroresCourage and instance.spinCharged == false and instance.spinAttackCounter > session.getSwordSpeed() * 2.5 then
    instance.spinCharged = true
    snd.play(instance.sounds.swordCharge)
  end

  img_speed_and_footstep_sound(instance, dt)

  local idleFrame = math.floor(instance.image_index + 1) % 5 == 0

  if instance.speed < 5 then
    idling = true
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/idle_hold_" .. side]
    else
      instance.sprite = im.sprites["Witch/idle_hold_left"]
      instance.x_scale = -1
    end
  else
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/hold_" .. side]
    else
      instance.sprite = im.sprites["Witch/hold_left"]
      instance.x_scale = -1
    end
  end

  if not idleFrame and not idling then
    local fii = math.floor(instance.image_index)
    if fii % 5 == 0 then
      instance.fake_zo = -1
    elseif (fii + 2) % 5 == 0 then
      instance.fake_zo = -2
    elseif (fii + 3) % 5 == 0 or (fii + 4) % 5 == 0 then
      instance.fake_zo = -3
    end
  else
    instance.fake_zo = 0
  end
end

player_states.check_hold = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif trig.stab then
    instance.animation_state:change_state(instance, dt, side .. "stab")
  elseif not trig.hold_sword or not instance.sword then
    if instance.spinCharged then -- spin attack
      instance.animation_state:change_state(instance, dt, "spinattack")
    else
      if trig.restish then
        instance.animation_state:change_state(instance, dt, side .. "still")
      else
        instance.animation_state:change_state(instance, dt, side .. "walk")
      end
    end
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

  -- Start spin attack counter
  instance.spinAttackCounter = 0
  instance.spinCharged = false
  -- Create sword
  instance.sword = hsw:new{creator = instance, side = side, layer = instance.layer}
  o.addToWorld(instance.sword)
end

player_states.end_hold = function(instance, dt, side)
  -- Delete sword
  if instance.sword then
    o.removeFromWorld(instance.sword)
    instance.sword = nil
  end
  if side == "right" then instance.x_scale = 1 end
end

player_states.start_jump = function(instance, dt, side)
  if instance.triggers.hold_jump then
    instance.zvel = 33
    snd.play(instance.sounds.throw)
    instance.gravity = 100
    instance.double_jumping = true
  else
    instance.zvel = 110
    snd.playFootstepSound(instance.closestTile, instance.inShallowWater)
  end
  instance.animation_state:change_state(instance, dt, side .. "fall")
end

player_states.run_fall = function(instance, dt, side)
  if instance.double_jumping then
    if instance.triggers.animation_end then
      instance.image_index = instance.sprite.frames - 1
    end
    instance.broom_image_index = instance.image_index
  else
    local vel = instance.zvel

    if instance.sideScroll then
      local _, vy = instance.body:getLinearVelocity()
      vel = -vy
    end

    if vel > 13 then -- 40 H 10
      instance.image_index = 0
    elseif vel < -13 then -- -40 H -10
      instance.image_index = 2
    else
      instance.image_index = 1
    end
  end
end

player_states.check_fall = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
  elseif trig.hold_jump and instance:canDoubleJump() then
    -- local vx, vy = instance.body:getLinearVelocity()
    -- if math.abs(vx) > math.abs(vy) then
    --   if vx > 0 then
    --     instance.animation_state:change_state(instance, dt, "rightjump")
    --   elseif vx < 0 then
    --     instance.animation_state:change_state(instance, dt, "leftjump")
    --   else
    --     instance.animation_state:change_state(instance, dt, side .. "jump")
    --   end
    -- else
    --   if vy > 0 then
    --     instance.animation_state:change_state(instance, dt, "downjump")
    --   elseif vy < 0 then
    --     instance.animation_state:change_state(instance, dt, "upjump")
    --   else
        instance.animation_state:change_state(instance, dt, side .. "jump")
    --   end
    -- end
  elseif instance:grounded() then
    instance.just_landed = true
    if instance.double_jumping then
      instance.soft_landing = true
    end
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_fall = function(instance, dt, side)
  instance.triggers.animation_end = false
  instance.image_index = 0
  if instance.triggers.hold_jump and instance.double_jumping then
    instance.broom_exists = true
    instance.broom_image_index = 0
    instance.image_speed = 0.2

    if side ~= "right" then
      instance.sprite = im.sprites["Witch/riding_start_" .. side]
    else
      instance.sprite = im.sprites["Witch/riding_start_left"]
      instance.x_scale = -1
    end
  else

    if side ~= "right" then
      instance.sprite = im.sprites["Witch/jump_" .. side]
    else
      instance.sprite = im.sprites["Witch/jump_left"]
      instance.x_scale = -1
    end
  end
end

player_states.end_fall = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  instance.gravity = instance.defaultGravity
  instance.double_jumping = nil
  instance.broom_exists = nil
end

player_states.run_missile = function(instance, dt, side)
  local idling = false

  instance.missile_cooldown = instance.missile_cooldown + dt
  instance.missile_start_counter = instance.missile_start_counter + dt
  img_speed_and_footstep_sound(instance, dt)

  if instance.missile and not instance.missile.charged and instance.triggers.mystery then
    if session.save.dust > 0 then
      session.addDust(-1)
      snd.play(instance.sounds.magicMissileCharge)
      instance.missile.charged = true
    end
  end

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/shoot_" .. side]
  else
    instance.sprite = im.sprites["Witch/shoot_left"]
    instance.x_scale = -1
  end

  if instance.speed < 5 then
    idling = true
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/idle_shoot_" .. side]
    else
      instance.sprite = im.sprites["Witch/idle_shoot_left"]
      instance.x_scale = -1
    end
  end

  local idleFrame = math.floor(instance.image_index + 1) % 5 == 0

  if not idleFrame and not idling then
    local fii = math.floor(instance.image_index)
    if fii % 5 == 0 then
      instance.fake_zo = -1
    elseif (fii + 2) % 5 == 0 then
      instance.fake_zo = -2
    elseif (fii + 3) % 5 == 0 or (fii + 4) % 5 == 0 then
      instance.fake_zo = -3
    end
  else
    instance.fake_zo = 0
  end

  if instance.missile_start_counter >= instance.missile_start_duration then
    if instance.missile and not instance.missile.fired then
      instance.missile.fired = true

      if not instance.missile.body:isDestroyed() then

        instance.missile.image_index = instance.missile.sprite.frames - 1

        local mslvx, mslvy = instance.missile.body:getLinearVelocity()
        local firevelx, firevely = 0, 0

        -- WARNING If I add spritebody to missile, the speed I add will get cut in half

        -- missile velocity function of (base) maxspeed
        if side == "up" then
          firevely = - session.save.playerMaxSpeed
        elseif side == "down" then
          firevely = session.save.playerMaxSpeed
        elseif side == "left" then
          firevelx = - session.save.playerMaxSpeed
        else
          firevelx = session.save.playerMaxSpeed
        end
        instance.missile.body:setLinearVelocity(mslvx+firevelx, mslvy+firevely)
      end

    end -- instance.missile
  end
end

player_states.check_missile = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif instance.missile_cooldown > session.getMagicCooldown() then
    if trig.fire_missile then
      instance.animation_state:change_state(instance, dt, side .. "missile")
    else
      if trig.restish then
        instance.animation_state:change_state(instance, dt, side .. "still")
      else
        instance.animation_state:change_state(instance, dt, side .. "walk")
      end
    end
  end
end

player_states.start_missile = function(instance, dt, side)
  instance.missile_cooldown = 0
  instance.missile_start_counter = 0
  instance.missile_start_duration = math.min(0.1, session.getMagicCooldown())

  -- Create missile
  instance.missile = msl:new{
    creator = instance,
    side = side,
    layer = instance.layer
  }
  o.addToWorld(instance.missile)
  snd.play(instance.sounds.magicMissile)

  instance.missile:compute_offset()
  local fy = 0
  if instance.edgeFall and instance.edgeFall.step2 then
    fy = - instance.edgeFall.height
  end
  local y_scale = 1
  local angle = 0
  local facing = instance:getFacing()
  if facing == "down" then
    y_scale = -1
  elseif facing == "left" then
    angle = -math.pi / 2
  elseif facing == "right" then
    angle = math.pi / 2
  end
  o.addToWorld(explode:new{
    nosound = true,
    explosion_sprite = im.spriteSettings.smallExplosion1,
    xstart = instance.x + instance.missile.sox,
    ystart = instance.y + instance.missile.soy + instance.zo + fy,
    x = instance.x + instance.missile.sox,
    y = instance.y + instance.missile.soy + instance.zo + fy,
    layer = facing == "up" and instance.layer - 1 or instance.layer,
    image_speed = 0.3,
    velocity = {x = instance.vx, y = instance.vy},
    lights = {
      {
        type = 'dynamic',
        rgba = {r = 1, g = 1, b = 1, a = 1},
        radius_table = {[0] = 0, [1] = 1},
        dynamic_options = {radius = 8}
      },
      {
        type = 'dynamic',
        rgba = {r = 1, g = 1, b = 1, a = 0.5},
        radius_table = {[0] = 0, [1] = 1},
        dynamic_options = {radius = 16}
      }
    },
    y_scale = y_scale,
    angle = angle
  })
end

player_states.end_missile = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  if instance.missile_cooldown < session.getMagicCooldown() then
    if instance.missile then
      instance.missile.broken = true
      instance.missile.fired = true
    end
    instance.missile_cooldown = nil
    return
  end
  instance.missile_cooldown = nil

end

player_states.run_gripping = function(instance, dt, side)
  img_speed_and_footstep_sound(instance, dt)
  if instance.speed < 5 then
    instance.image_index = 0.5
  end

  -- Check if object cannot be gripped any longer
  if instance.grippedOb.untouchable or instance.grippedOb.unpushable or
  instance.grippedOb.goThroughPlayer or instance.grippedOb.onEdge then
    instance.grippedOb = nil
  end
end

player_states.check_gripping = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif not trig.grip or not instance.grippedOb or not instance.grippedOb.exists then
    instance.animation_state:change_state(instance, dt, side .. "push")
  end
end

player_states.start_gripping = function(instance, dt, side)
  -- Determine whether I will grip or lift
  -- using the same method to find "other" in inventory
  -- Dont change one without the other
  local other
  local touchedObTable = instance.sensors[side .. "TouchedObs"]
  for _, touchedOb in ipairs(touchedObTable) do
    other = touchedOb
  end
  if other and other.body then
    if not other.liftable then
      instance.grippedOb = other
      instance.grip = love.physics.newWeldJoint(
        other.body, instance.body, instance.x, instance.y, true
      )
    else
      instance.animation_state:change_state(instance, dt, side .. "lifting")
      instance.liftedOb = lft:new{
        creator = instance,
        side = side,
        layer = side == "up" and instance.layer - 1 or instance.layer + 1,
        sprite_info = other.sprite_info or {im.spriteSettings.testlift},
        image_index = floor(other.image_index),
        image_speed = other.image_speed,
        lift_info = other.lift_info,
        persistentData = other.persistentData,
        iAmBomb = other.iAmBomb,
        timer = other.timer,
        vibrPhase = other.vibrPhase,
        startingTimer = other.startingTimer,
        lift_update = other.lift_update,
        myDrops = other.myDrops,
        dustBomb = other.dustBomb,
        throw_update = other.throw_update,
        explosionNumber = other.explosionNumber,
        explosionSprite = other.explosionSprite,
        explosionSpeed = other.explosionSpeed,
        explosionSound = other.explosionSound,
        lifterSpeedMod = other.lifterSpeedMod or 0.5,
        throw_collision = other.throw_collision or emptyFunc,
        inheritedShader = other.myShader or other.inheritedShader
      }
      o.removeFromWorld(other)
      -- other.destroy = other.on_replaced_by_lifted
      other.destroy = nil
      if other.on_replaced_by_lifted then
        other:on_replaced_by_lifted()
      end
      o.addToWorld(instance.liftedOb)
      return
    end
  end

  local p = instance.animation_state.prev_state
  if not p:match("push") then
    instance.image_index = 0
  end
  instance.image_speed = 0

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/grip_" .. side]
  else
    instance.sprite = im.sprites["Witch/grip_left"]
    instance.x_scale = -1
  end
end

player_states.end_gripping = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  instance.grippedOb = nil
  if instance.grip and not instance.grip:isDestroyed() then
    instance.grip:destroy();
    instance.grip = nil
  end
end


local function chargeLifted(lifted, lifter)
  if not lifted.undustable and not lifted.persistentData.charged and lifter.triggers.mystery then
    if session.save.dust > 0 then
      -- Check if lifted.iAmBomb if I want to change anything when interacting with bombs

      session.addDust(-1)
      snd.play(lifter.sounds.magicMissileCharge)
      lifted.persistentData.charged = true
      lifted.persistentData.focus = session.save.focus
    end
  end
end

player_states.run_lifting = function(instance, dt, side)
  if instance.liftedOb then
    chargeLifted(instance.liftedOb, instance)
  end

  instance.liftingStage = 1 + 3 * instance.item_use_counter * instance.invGripTime

  if instance.liftingStage >= 4 then instance.liftingStage = 4 end

  if instance.triggers.animation_end then
    instance.image_index = instance.sprite.frames - 1
  end
end

player_states.check_lifting = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.liftingStage == 4 then
    instance.dontThrow = true
    instance.animation_state:change_state(instance, dt, side .. "lifted")
  end
  instance.dontThrow = false
end

player_states.start_lifting = function(instance, dt, side)
  snd.play(instance.sounds.pickUp)
  instance.liftingStage = 1
  local gripTime
  if session.save.dinsPower then
    gripTime = inv.grip.time
  else
    gripTime = inv.grip.time * 1.5
  end
  instance.invGripTime = 1 / gripTime
  instance.image_index = 0
  instance.image_speed = instance.invGripTime / 10

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/lifting_" .. side]
  else
    instance.sprite = im.sprites["Witch/lifting_left"]
    instance.x_scale = -1
  end

  instance.liftState = true
end

player_states.end_lifting = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  if instance.liftedOb and not instance.dontThrow then
    instance.liftedOb:get_thrown()
    o.removeFromWorld(instance.liftedOb)
    instance.liftedOb = nil
    snd.play(instance.sounds.throw)
  end
  instance.liftingStage = nil
  instance.liftState = false
end

player_states.run_lifted = function(instance, dt, side)
  local idling = false
  img_speed_and_footstep_sound(instance, dt)
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/carry_" .. side]
  else
    instance.sprite = im.sprites["Witch/carry_left"]
    instance.x_scale = -1
  end
  if instance.speed < 5 then
    idling = true
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/idle_carry_" .. side]
    else
      instance.sprite = im.sprites["Witch/idle_carry_left"]
      instance.x_scale = -1
    end
  end
  if instance.liftedOb then
    instance.liftedOb.side = side
    chargeLifted(instance.liftedOb, instance)
  end

  if not idling and math.floor(instance.image_index + 1) % 5 ~= 0 then
    local fii = math.floor(instance.image_index)
    if fii % 5 == 0 then
      instance.fake_zo = -1
    elseif (fii + 2) % 5 == 0 then
      instance.fake_zo = -2
    elseif (fii + 3) % 5 == 0 or (fii + 4) % 5 == 0 then
      instance.fake_zo = -3
    end
  else
    instance.fake_zo = 0
  end
end

player_states.check_lifted = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif trig.gripping or trig.bomb then
    instance.animation_state:change_state(instance, dt, side .. "walk")
  elseif td.check_carry_while_carrying(instance, trig, side, dt) then
  end
  -- Variable to ensure lifted object won't be thrown when changing direction
  -- Set at check_carry_while_carrying function in movement.top_down
  instance.dontThrow = false
end

player_states.start_lifted = function(instance, dt, side)
  instance.liftState = true
end

player_states.end_lifted = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  if instance.liftedOb and not instance.dontThrow then
    instance.liftedOb:get_thrown()
    o.removeFromWorld(instance.liftedOb)
    instance.liftedOb = nil
    snd.play(instance.sounds.throw)
  end
  instance.liftState = false
end

player_states.run_damaged = function(instance, dt, side)
  if instance.takingDamage then
    instance.takingDamage = instance.takingDamage - 1
    if instance.takingDamage == 0 then instance.takingDamage = nil end
  end
  instance.damCounter = instance.damCounter - dt
  if instance.triggers.land then

    instance.hurt_from_height = true

    instance.sprite = im.sprites["Witch/fallen_down"]
    instance.image_index = 0

    instance.image_speed = 0
  end
end

player_states.check_damaged = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if instance.overGap then
    instance.animation_state:change_state(instance, dt, "plummet")
  elseif instance.inDeepWater then
    instance.animation_state:change_state(instance, dt, "downdrown")
  elseif instance.damCounter < 0 then
    instance.animation_state:change_state(instance, dt,
    (instance.hurt_from_height and "down" or side) .. "still")
  elseif not instance.takingDamage and trig.damaged then
    instance.animation_state:change_state(instance, dt, side .. "damaged")
  end
end

player_states.start_damaged = function(instance, dt, side)

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/hurt_" .. side]
  else
    instance.sprite = im.sprites["Witch/hurt_left"]
    instance.x_scale = -1
  end

  instance.takingDamage = 3 -- Cannot take more damage for three frames
  instance.image_index = 0
  instance.image_speed = 0.2
  if instance.body:getType() ~= "static" and not (dlg.enable or dlg.enabled) then
    instance:addHealth(-(instance.triggers.damaged or 1))
  end
  if instance.triggers.damaged == 0 then instance.noInvShader = true end
  inp.disable_controller(instance.player)
  instance.damCounter = instance.triggers.damCounter or 0.5
  instance.invulnerable = (pl1.triggers.noInvFrames and 0 or (instance.damCounter + 1))
  instance.damKeepMoving = instance.triggers.damKeepMoving
  snd.play(instance.triggers.altHurtSound or instance.sounds.hurt)
end

player_states.end_damaged = function(instance, dt, side)
  instance.takingDamage = false
  instance.hurt_from_height = nil
  instance.x_scale = 1
  inp.enable_controller(instance.player)
  if instance.floorFriction > 0.9 and not instance.damKeepMoving then
    instance.body:setLinearVelocity(0, 0)
  end
end

player_states.run_sprintcharge = function(instance, dt, side)
  instance.sprintCharge = instance.sprintCharge - dt

  -- make footstep sounds
  if should_play_footstep_sound(instance) then
    snd.playFootstepSound(instance.closestTile, instance.inShallowWater)
  end

  if math.floor(instance.image_index + 1) % 5 ~= 0 then
    local fii = math.floor(instance.image_index)
    if fii % 5 == 0 then
      instance.fake_zo = -1
    elseif (fii + 2) % 5 == 0 then
      instance.fake_zo = -2
    elseif (fii + 3) % 5 == 0 or (fii + 4) % 5 == 0 then
      instance.fake_zo = -3
    end
  else
    instance.fake_zo = 0
  end
end

player_states.check_sprintcharge = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif not instance:grounded() then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif trig.jump and instance:grounded() then
    instance.animation_state:change_state(instance, dt, side .. "jump")
  elseif not trig.speed then
    instance.animation_state:change_state(instance, dt, side .. "still")
  elseif instance.sprintCharge < 0 then
    instance.animation_state:change_state(instance, dt, "sprint")
  end
end

player_states.start_sprintcharge = function(instance, dt, side)

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/walk_" .. side]
  else
    instance.sprite = im.sprites["Witch/walk_left"]
    instance.x_scale = -1
  end
  instance.image_speed = 0.5

  instance.sprintCharge = 0.5

  if instance.speed > 110 then
    instance.sprintCharge = -1
  end
end

player_states.end_sprintcharge = function(instance, dt, side)
  instance.sprintCharge = nil
  if side == "up" then
    instance.sprintDir = - math.pi * 0.5
  elseif side == "left" then
    instance.sprintDir = math.pi
  elseif side == "right" then
    instance.sprintDir = 0
  elseif side == "down" then
    instance.sprintDir = math.pi * 0.5
  end
  instance.sprintSide = side
  if side == "right" then
    instance.x_scale = 1
  end
end


player_states.run_sprint = function(instance, dt)
  -- Determine instance.sprintSide from instance.sprintDir
  if instance.sprintDir < - math.pi * 0.25 and instance.sprintDir > - math.pi * 0.75 then
    instance.sprintSide = "up"
  elseif instance.sprintDir > math.pi * 0.25 and instance.sprintDir < math.pi * 0.75 then
    instance.sprintSide = "down"
  elseif (instance.sprintDir >= 0 and instance.sprintDir < math.pi * 0.25) or (instance.sprintDir < 0 and instance.sprintDir > - math.pi * 0.25) then
    instance.sprintSide = "right"
  elseif (instance.sprintDir >= 0 and instance.sprintDir > math.pi * 0.75) or (instance.sprintDir < 0 and instance.sprintDir < - math.pi * 0.75) then
    instance.sprintSide = "left"
  end

  if instance.sprintSide ~= "right" then
    instance.sprite = im.sprites["Witch/dash_"  .. instance.sprintSide]
    instance.x_scale = 1
  else
    instance.sprite = im.sprites["Witch/dash_left"]
    instance.x_scale = -1
  end

  instance.rollSoundTimer = instance.rollSoundTimer + dt
  instance.rollFxTimer = instance.rollFxTimer + dt
  -- make footstep sounds

  if should_play_footstep_sound(instance) then
    snd.playFootstepSound(instance.closestTile, instance.inShallowWater)
    local explOb = (require "GameObjects.explode"):new{
      x = instance.x, y = instance.y + 4,
      -- layer = self.layer+1,
      layer = instance.layer - 1,
      -- explosionNumber = 1,
      sprite_info = {im.spriteSettings.playerDust},
      image_speed = 0.25,
      nosound = true
    }
    o.addToWorld(explOb)
  end
end

player_states.check_sprint = function(instance, dt)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, instance.sprintSide, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif not instance:grounded() then
    instance.animation_state:change_state(instance, dt, instance.sprintSide .. "fall")
  elseif trig.jump and instance:grounded() then
    instance.animation_state:change_state(instance, dt, instance.sprintSide .. "jump")
  elseif not trig.speed then
    instance.animation_state:change_state(instance, dt, instance.sprintSide .. "still")
  end
end

player_states.start_sprint = function(instance, dt)
  instance.image_speed = 0.4
  instance.sprintDir = instance.sprintDir or 0
  instance.immasprint = true
  instance.rollSoundTimer = 0.23
  instance.rollFxTimer = 0.0766
end

player_states.end_sprint = function(instance, dt)
  if instance.sprintSide == "right" then
    instance.x_scale = 1
  end
  instance.sprintSide = nil
  instance.sprintDir = nil
  instance.immasprint = nil
  instance.rollSoundTimer = nil
end


player_states.run_mdust = function(instance, dt, side)
  if math.floor(instance.image_index) == instance.sprite.frames - 1 and math.floor(instance.image_index_prev) ~= instance.sprite.frames - 1 then

    local xmod, ymod
    local hormod, vermod = 12, 6
    if side == "up" then
      xmod, ymod = 0, -vermod
    elseif side == "left" then
      xmod, ymod = -hormod, 0
    elseif side == "down" then
      xmod, ymod = 0, vermod + ps.shapes.plshapeHeight
    elseif side == "right" then
      xmod, ymod = hormod, 0
    end

    -- Create sprinkle
    local mdust = mdu:new{
      creator = instance,
      side = side,
      layer = side == "up" and instance.layer - 1 or instance.layer + 1,
      xstart = instance.x + xmod, x = instance.x + xmod,
      ystart = instance.y + ymod, y = instance.y + ymod
    }
    o.addToWorld(mdust)
  end
end

player_states.check_mdust = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, instance.sprintSide, dt) then
  elseif trig.animation_end then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_mdust = function(instance, dt, side)
  instance.image_index = 0
  instance.image_speed = 0.1
  instance.triggers.animation_end = false

  if side ~= "right" then
    instance.sprite = im.sprites["Witch/mdust_" .. side]
  else
    instance.sprite = im.sprites["Witch/mdust_left"]
    instance.x_scale = -1
  end

end

player_states.end_mdust = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
end


player_states.run_climbing = function(instance, dt, side)
  local s = instance.speed / (instance.timeFlow or 1)
  local f = instance.sprite.frames

  if instance.vy > 0 then
    s = -s
  end

  instance.image_speed = 0.001 * s * f
end

player_states.check_climbing = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if trig.noHealth then
    instance.animation_state:change_state(instance, dt, "downdie")
  elseif trig.damaged then
    instance.animation_state:change_state(instance, dt, "updamaged")
  elseif not instance.climbing then
    instance.animation_state:change_state(instance, dt, "upstill")
  end
end

player_states.start_climbing = function(instance, dt, side)

  instance.sprite = im.sprites["Witch/climb_up"]

end

player_states.end_climbing = function(instance, dt, side)
end

return player_states
