local inv = require "inventory"
local td = require "movement"; td = td.top_down
local im = require "image"
local inp = require "input"
local snd = require "sound"
local ps = require "physics_settings"
local dlg = require "dialogue"
local u = require "utilities"

local o = require "GameObjects.objects"
local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"
local msl = require "GameObjects.Items.missile"
local lft = require "GameObjects.Items.lifted"
local mdu = require "GameObjects.Items.mdust"
local pddp = require "GameObjects.Helpers.triggerCheck"; pddp = pddp.playerDieDrownPlummet

local floor = math.floor
local random = math.random

local emptyFunc = function() end

local player_states = {}

player_states.img_speed_and_footstep_sound = function(instance, dt)
  td.image_speed(instance, dt)
  if instance.inShallowWater and instance.image_index % 2 >= 1 and instance.image_index_prev % 2 < 1 then
    snd.play(instance.sounds.water)
  end
end

local img_speed_and_footstep_sound = player_states.img_speed_and_footstep_sound

player_states.check_walk = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side, dt) then
  elseif td.check_walk_while_walking(instance, trig, side, dt) then
  elseif td.check_halt_a(instance, trig, side, dt) then
  elseif trig.restish then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.check_halt = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side, dt) then
  elseif td.check_walk_a(instance, trig, side, dt) then
  elseif trig.restish then
    instance.animation_state:change_state(instance, dt, side .. "still")
  elseif td.check_halt_notme(instance, trig, side, dt) then
  end
end

player_states.check_still = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif inv.check_use(instance, trig, side, dt) then
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
  elseif td.check_push_a(instance, trig, side, dt) then
  elseif td.check_walk_a(instance, trig, side, dt) then
  elseif td.check_halt_a(instance, trig, side, dt) then
  end
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
  if randomizeSwing < 0.34 then
    snd.play(instance.sounds.swordSlash1)
  elseif randomizeSwing < 0.67 then
    snd.play(instance.sounds.swordSlash2)
  else
    snd.play(instance.sounds.swordSlash3)
  end
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
  instance.swingingSword = false
  instance.ioy, instance.iox = 0, 0
  instance.image_index = 0
  instance.image_speed = 0
  if instance.floorFriction > 0.9 and instance.sword and instance.sword.hitWall then
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

player_states.run_hold = function(instance, dt, side)
  img_speed_and_footstep_sound(instance, dt)
  -- Update spin attack counter
  instance.spinAttackCounter = instance.spinAttackCounter + dt
  if session.save.faroresCourage and instance.spinCharged == false and instance.spinAttackCounter > session.getSwordSpeed() * 2.5 then
    instance.spinCharged = true
    snd.play(instance.sounds.swordCharge)
  end

  if instance.speed < 5 then instance.image_index = 0 end
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
      instance.animation_state:change_state(instance, dt, side .. "walk")
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
  o.removeFromWorld(instance.sword)
  instance.sword = nil
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
    snd.play(instance.sounds.jump)
  end
  instance.animation_state:change_state(instance, dt, side .. "fall")
end

player_states.run_fall = function(instance, dt, side)
  -- Witch fall
  if instance.sprite.frames == 3 and session.save.equippedRing == "ringMage" then
    if instance.zvel > 13 then -- 40 H 10
      instance.image_index = 0
    elseif instance.zvel < -13 then -- -40 H -10
      instance.image_index = 2
    else
      instance.image_index = 1
    end

    -- Link fall
  else
    if instance.triggers.animation_end then
      instance.image_speed = 0
      instance.image_index = instance.sprite.frames - 1
    end
  end
end

player_states.check_fall = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
  elseif trig.hold_jump and session.jumpL2 and not instance.double_jumping and instance.zvel < 0 and instance.zo > -7 and instance.zo < 0 then
    instance.animation_state:change_state(instance, dt, side .. "jump")
  elseif instance.zo == 0 then
    instance.animation_state:change_state(instance, dt, side .. "still")
  end
end

player_states.start_fall = function(instance, dt, side)
  instance.triggers.animation_end = false
  instance.image_index = 0
  instance.image_speed = 0.11
  if instance.triggers.hold_jump and instance.double_jumping then
    if side ~= "right" then
      instance.sprite = im.sprites["Witch/cape_" .. side]
    else
      instance.sprite = im.sprites["Witch/cape_left"]
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
end

player_states.run_missile = function(instance, dt, side)
  instance.missile_cooldown = instance.missile_cooldown + dt
  img_speed_and_footstep_sound(instance, dt)
  if instance.speed < 5 then
    if floor(instance.image_index) ~= 3 then
      instance.image_index = 1
    end
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
      instance.animation_state:change_state(instance, dt, side .. "walk")
    end
  end
end

player_states.start_missile = function(instance, dt, side)
  instance.missile_cooldown = 0
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
  snd.play(instance.sounds.magicMissile)
end

player_states.end_missile = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  if instance.missile_cooldown < session.getMagicCooldown() then
    instance.missile.broken = true
    instance.missile.fired = true
    instance.missile_cooldown = nil
    return
  end
  instance.missile_cooldown = nil

  if instance.missile then
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

player_states.run_gripping = function(instance, dt, side)
  img_speed_and_footstep_sound(instance, dt)
  if instance.speed < 5 then
    instance.image_index = 0
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
    instance.animation_state:change_state(instance, dt, side .. "walk")
  end
end

player_states.start_gripping = function(instance, dt, side)
  -- Determine whether I will grip or lift
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
      o.removeFromWorld(other)
      other.destroy = other.on_replaced_by_lifted
      instance.liftedOb = lft:new{
        creator = instance,
        side = side,
        layer = side == "up" and instance.layer - 1 or instance.layer + 1,
        sprite_info = other.sprite_info or {im.spriteSettings.testlift},
        image_index = floor(other.image_index),
        lift_info = other.lift_info,
        lift_update = other.lift_update,
        throw_update = other.throw_update,
        explosionNumber = other.explosionNumber,
        explosionSprite = other.explosionSprite,
        explosionSpeed = other.explosionSpeed,
        explosionSound = other.explosionSound,
        lifterSpeedMod = other.lifterSpeedMod or 0.5,
        throw_collision = other.throw_collision or emptyFunc,
        inheritedShader = other.myShader
      }
      o.addToWorld(instance.liftedOb)
      return
    end
  end

  instance.image_index = 0
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
  if instance.grip and not instance.grip:isDestroyed() then instance.grip:destroy(); instance.grip = nil end
end

player_states.run_lifting = function(instance, dt, side)
  -- instance.liftingStage = instance.liftingStage + dt * 12
  instance.liftingStage = 1 + 3 * instance.item_use_counter * instance.invGripTime

  if instance.liftingStage >= 4 then instance.liftingStage = 4 end
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
  instance.image_speed = 0
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
  img_speed_and_footstep_sound(instance, dt)
  if instance.speed < 5 then
    instance.image_index = 0
  end
  if instance.liftedOb then
    instance.liftedOb.side = side
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
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/lifted_" .. side]
  else
    instance.sprite = im.sprites["Witch/lifted_left"]
    instance.x_scale = -1
  end
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
  instance.damCounter = instance.damCounter - dt
  if instance.triggers.land then
    instance.sprite = im.sprites["Witch/die"]
    instance.image_speed = 0
    instance.image_index = 5
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
    (instance.sprite == im.sprites["Witch/die"] and "down" or side) .. "still")
  end
end

player_states.start_damaged = function(instance, dt, side)
  if side ~= "right" then
    instance.sprite = im.sprites["Witch/hurt_" .. side]
  else
    instance.sprite = im.sprites["Witch/hurt_left"]
    instance.x_scale = -1
  end
  instance.image_index = 0
  instance.image_speed = 0
  if instance.body:getType() ~= "static" and not (dlg.enable or dlg.enabled) then
    instance:addHealth(-(instance.triggers.damaged or 1))
  end
  if instance.triggers.damaged == 0 then instance.noInvShader = true end
  inp.disable_controller(instance.player)
  instance.invulnerable = 1
  instance.damCounter = instance.triggers.damCounter or 0.5
  instance.damKeepMoving = instance.triggers.damKeepMoving
  snd.play(instance.triggers.altHurtSound or instance.sounds.hurt)
end

player_states.end_damaged = function(instance, dt, side)
  if side == "right" then
    instance.x_scale = 1
  end
  inp.enable_controller(instance.player)
  if instance.floorFriction > 0.9 and not instance.damKeepMoving then
    instance.body:setLinearVelocity(0, 0)
  end
end

player_states.run_sprintcharge = function(instance, dt, side)
  instance.sprintCharge = instance.sprintCharge - dt

  -- make footstep sounds
  if instance.image_index % 2 >= 1 and instance.image_index_prev % 2 < 1 then
    snd.play(instance.sounds[instance.landedTileSound])
  end
end

player_states.check_sprintcharge = function(instance, dt, side)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, side, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, side .. "fall")
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
  instance.image_speed = 0.3
  instance.sprintCharge = 0.5
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
  local moveType = session.save.faroresCourage and "roll" or "walk"
  if instance.sprintSide ~= "right" then
    instance.sprite = im.sprites["Witch/".. moveType .."_" .. instance.sprintSide]
    instance.x_scale = 1
  else
    instance.sprite = im.sprites["Witch/".. moveType .."_left"]
    instance.x_scale = -1
  end

  instance.rollSoundTimer = instance.rollSoundTimer + dt
  instance.rollFxTimer = instance.rollFxTimer + dt
  -- make footstep sounds
  if session.save.faroresCourage then
    if instance.rollSoundTimer > 0.23 then
      instance.rollSoundTimer = 0
      snd.play(instance.sounds.roll)
    end
    if instance.rollFxTimer > 0.0766 then
      instance.rollFxTimer = 0
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
  else
    if instance.image_index % 2 >= 1 and instance.image_index_prev % 2 < 1 then
      snd.play(instance.sounds[instance.landedTileSound])
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
end

player_states.check_sprint = function(instance, dt)
  local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
  if pddp(instance, trig, instance.sprintSide, dt) then
  elseif instance.climbing then
    instance.animation_state:change_state(instance, dt, "upclimbing")
  elseif instance.zo ~= 0 then
    instance.animation_state:change_state(instance, dt, instance.sprintSide .. "fall")
  elseif not trig.speed then
    instance.animation_state:change_state(instance, dt, instance.sprintSide .. "still")
  end
end

player_states.start_sprint = function(instance, dt)
  if instance.sprintSide ~= "right" then
    instance.sprite = im.sprites["Witch/walk_" .. instance.sprintSide]
  else
    instance.sprite = im.sprites["Witch/walk_left"]
    instance.x_scale = -1
  end
  instance.image_speed = 0.3
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
  if instance.image_index >= 1 and instance.image_index_prev < 1 then

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
  td.image_speed(instance, dt, 1)
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
