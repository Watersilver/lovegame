local gs = require "game_settings"
local ps = require "physics_settings"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local inp = require "input"
local inv = require "inventory"
local p = require "GameObjects.prototype"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"
local trans = require "transitions"
local dlg = require "dialogue"
local gsh = require "gamera_shake"
local items = require "items"
local lighting = require "ScreenEffects.lighting.lighting"
local explode  = require "GameObjects.explode"

local hps = require "GameObjects.Helpers.player_states"
local ors = require "GameObjects.Helpers.object_read_save"
local dc = require "GameObjects.Helpers.determine_colliders"
local ec = require "GameObjects.Helpers.edge_collisions"
local sg = require "GameObjects.Helpers.set_ghost"
local asp = require "GameObjects.Helpers.add_spell"
local pddp = require "GameObjects.Helpers.triggerCheck"; pddp = pddp.playerDieDrownPlummet

local sw = require "GameObjects.Items.sword"
local mark = require "GameObjects.Items.mark"
local windSlice = require "GameObjects.Items.windSlice"

local sh = require "GameObjects.shadow"

local go = require "GameObjects.gameOver"

local hitShader = shdrs.playerHitShader

local sqrt = math.sqrt
local floor = math.floor
local distanceSqared2d = u.distanceSqared2d
local insert = table.insert
local remove = table.remove
local max = math.max
local abs = math.abs

local pi = math.pi
local huge = math.huge

local movement_states = {
  state = "start",
  start = {
  run_state = function(instance, dt)
  end,
  start_state = function(instance, dt)
  end,
  check_state = function(instance, dt)
    if true then
      instance.movement_state:change_state(instance, dt, "normal")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  normal = {
  run_state = function(instance, dt)
    local otherstate = instance.animation_state.state

    -- Apply movement table
    if otherstate:find("sprintcharge") and instance.triggers.speed then
      td.stand_still(instance, dt)
    elseif otherstate == "sprint" and instance.triggers.speed then
      local myinput = instance.input
      -- local horin, verin = myinput.right - myinput.left, myinput.down - myinput.up
      local _, targetDir = u.cartesianToPolar(myinput.right - myinput.left, myinput.down - myinput.up)
      local turnSpeed = dt + dt * session.save.athleticsLvl + dt * (session.save.faroresCourage and 3 or 0)
      turnSpeed = turnSpeed * (instance.floorFriction or 1)
      if myinput.right - myinput.left == 0 and myinput.up - myinput.down == 0 then
        instance.sprintDir = instance.sprintDir
      elseif math.abs(instance.sprintDir - targetDir) < turnSpeed then
        instance.sprintDir = targetDir
      else
        instance.sprintDir = instance.sprintDir + turnSpeed * u.findSmallestArc(instance.sprintDir, targetDir)
      end
      while instance.sprintDir > math.pi do
        instance.sprintDir = instance.sprintDir - math.pi * 2
      end
      while instance.sprintDir <= -math.pi do
        instance.sprintDir = instance.sprintDir + math.pi * 2
      end

      td.sprint(instance, dt)
    else
      td.walk(instance, dt)
    end
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.movement_state.state, instance.animation_state.state
    if not instance.missile_cooldown then
      if not instance.liftState then
        if not instance.climbing then

          local swhp = otherstate:find("still") or
            otherstate:find("walk") or
            otherstate:find("halt") or
            otherstate:find("push")

          local fs = otherstate:find("fall") or otherstate:find("swing")

          if trig.stab then
            instance.movement_state:change_state(instance, dt, "using_sword")
          -- elseif trig.swing_sword and otherstate ~= "spinattack" then
          elseif trig.swing_sword and (swhp or fs) then
            instance.movement_state:change_state(instance, dt, "using_sword")
          elseif instance:grounded() and swhp then
            -- trigger these only grounded and during certain animations
            if trig.mark then
              instance.movement_state:change_state(instance, dt, "using_mark")
            elseif trig.recall then
              instance.movement_state:change_state(instance, dt, "using_recall")
            elseif trig.mystery then
              if session.save.dust <= 0 then return end
              session.addDust(-1)
              -- Animation state gets checked after this
              -- so mark a new trigger here to also change animation
              -- because I can't removeItem again to check removeResult
              -- for animation state...
              trig.usingMdust = true
              instance.movement_state:change_state(instance, dt, "using_mdust")
            end
          end

        end
      else
        if instance.liftingStage then
          instance.movement_state:change_state(instance, dt, "using_lift")
        end
      end
    end
  end,

  start_state = function(instance, dt)
  end,

  end_state = function(instance, dt)
  end
  },


  using_sword = {
  start_state = function(instance, dt)
    instance.movement_state:change_state(instance, dt, "using_item")
  end,

  end_state = function(instance, dt)
    instance.item_use_duration = session.getSwordSpeed()
  end
  },


  using_mark = {
  start_state = function(instance, dt)
    instance.movement_state:change_state(instance, dt, "using_item")
  end,

  end_state = function(instance, dt)
    if session.save.faroresCourage then
      instance.item_use_duration = inv.mark.time
    else
      instance.item_use_duration = inv.mark.time * 2
    end
  end
  },


  using_recall = {
  start_state = function(instance, dt)
    instance.movement_state:change_state(instance, dt, "using_item")
  end,

  end_state = function(instance, dt)
    if session.save.faroresCourage then
      instance.item_use_duration = inv.recall.time
    else
      instance.item_use_duration = inv.recall.time * 2
    end
  end
  },


  using_mdust = {
  start_state = function(instance, dt)
    instance.movement_state:change_state(instance, dt, "using_item")
  end,

  end_state = function(instance, dt)
    instance.item_use_duration = inv.mystery.time
  end
  },


  using_lift = {
  start_state = function(instance, dt)
    instance.movement_state:change_state(instance, dt, "using_item")
  end,

  end_state = function(instance, dt)
    local gripTime
    if session.save.dinsPower then
      gripTime = inv.grip.time
    else
      gripTime = inv.grip.time * 1.5
    end
    instance.item_use_duration = gripTime
  end
  },


  using_item = {
  run_state = function(instance, dt)
    -- Apply movement table
    td.stand_still(instance, dt)
    instance.item_use_counter = instance.item_use_counter + dt
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.movement_state.state, instance.animation_state.state
    if trig.swing_sword and not otherstate:find("stab") and (not otherstate:find("swing") or session.save.swordLvl > 2) and not instance.liftState then
      instance.movement_state:change_state(instance, dt, "using_sword")
    elseif instance.item_use_counter > instance.item_use_duration then
      instance.movement_state:change_state(instance, dt, "normal")
    end
  end,

  start_state = function(instance, dt)

  end,

  end_state = function(instance, dt)
    instance.item_use_counter = 0
  end
  },


  stand_still = {
  run_state = function(instance, dt)
    -- Apply movement table
    td.stand_still(instance, dt)
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
  end,

  end_state = function(instance, dt)
  end
  }
}

local animation_states = {
  state = "start",
  start = {
  run_state = function(instance, dt)
  end,
  start_state = function(instance, dt)
  end,
  check_state = function(instance, dt)
    if true then
      instance.animation_state:change_state(instance, dt, "downwalk")
    end
  end,
  end_state = function(instance, dt)
  end
  },


  downwalk = {
  run_state = function(instance, dt)
    hps.run_walk(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_walk(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_walk(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_walk(instance, dt, "down")
  end
  },


  rightwalk = {
  run_state = function(instance, dt)
    hps.run_walk(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_walk(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_walk(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_walk(instance, dt, "right")
  end
  },


  leftwalk = {
  run_state = function(instance, dt)
    hps.run_walk(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_walk(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_walk(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_walk(instance, dt, "left")
  end
  },


  upwalk = {
  run_state = function(instance, dt)
    hps.run_walk(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_walk(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_walk(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_walk(instance, dt, "up")
  end
  },


  downhalt = {
  run_state = function(instance, dt)
    hps.run_halt(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_halt(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_halt(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_halt(instance, dt, "down")
  end
  },


  righthalt = {
  run_state = function(instance, dt)
    hps.run_halt(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_halt(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_halt(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_halt(instance, dt, "right")
  end
  },


  lefthalt = {
  run_state = function(instance, dt)
    hps.run_halt(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_halt(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_halt(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_halt(instance, dt, "left")
  end
  },


  uphalt = {
  run_state = function(instance, dt)
    hps.run_halt(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_halt(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_halt(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_halt(instance, dt, "up")
  end
  },


  downstill = {
  run_state = function(instance, dt)
    hps.run_still(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_still(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_still(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_still(instance, dt, "down")
  end
  },


  rightstill = {
  run_state = function(instance, dt)
    hps.run_still(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_still(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_still(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_still(instance, dt, "right")
  end
  },


  leftstill = {
  run_state = function(instance, dt)
    hps.run_still(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_still(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_still(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_still(instance, dt, "left")
  end
  },


  upstill = {
  run_state = function(instance, dt)
    hps.run_still(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_still(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_still(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_still(instance, dt, "up")
  end
  },


  downpush = {
  run_state = function(instance, dt)
    hps.run_push(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_push(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_push(instance, dt, 'down')
  end,

  end_state = function(instance, dt)
    hps.end_push(instance, dt, 'down')
  end
  },


  rightpush = {
  run_state = function(instance, dt)
    hps.run_push(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_push(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_push(instance, dt, 'right')
  end,

  end_state = function(instance, dt)
    hps.end_push(instance, dt, 'right')
  end
  },


  leftpush = {
  run_state = function(instance, dt)
    hps.run_push(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_push(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_push(instance, dt, 'left')
  end,

  end_state = function(instance, dt)
    hps.end_push(instance, dt, 'left')
  end
  },


  uppush = {
  run_state = function(instance, dt)
    hps.run_push(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_push(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_push(instance, dt, 'up')
  end,

  end_state = function(instance, dt)
    hps.end_push(instance, dt, 'up')
  end
  },


  downswing = {
  run_state = function(instance, dt)
    hps.run_swing(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_swing(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_swing(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_swing(instance, dt, "down")
  end
  },


  rightswing = {
  run_state = function(instance, dt)
    hps.run_swing(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_swing(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_swing(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_swing(instance, dt, "right")
  end
  },


  leftswing = {
  run_state = function(instance, dt)
    hps.run_swing(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_swing(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_swing(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_swing(instance, dt, "left")
  end
  },


  upswing = {
  run_state = function(instance, dt)
    hps.run_swing(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_swing(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_swing(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_swing(instance, dt, "up")
  end
  },


  downstab = {
  run_state = function(instance, dt)
    hps.run_stab(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_stab(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_stab(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_stab(instance, dt, "down")
  end
  },


  rightstab = {
  run_state = function(instance, dt)
    hps.run_stab(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_stab(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_stab(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_stab(instance, dt, "right")
  end
  },


  leftstab = {
  run_state = function(instance, dt)
    hps.run_stab(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_stab(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_stab(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_stab(instance, dt, "left")
  end
  },


  upstab = {
  run_state = function(instance, dt)
    hps.run_stab(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_stab(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_stab(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_stab(instance, dt, "up")
  end
  },


  downhold = {
  run_state = function(instance, dt)
    hps.run_hold(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_hold(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_hold(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_hold(instance, dt, "down")
  end
  },


  righthold = {
  run_state = function(instance, dt)
    hps.run_hold(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_hold(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_hold(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_hold(instance, dt, "right")
  end
  },


  lefthold = {
  run_state = function(instance, dt)
    hps.run_hold(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_hold(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_hold(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_hold(instance, dt, "left")
  end
  },


  uphold = {
  run_state = function(instance, dt)
    hps.run_hold(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_hold(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_hold(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_hold(instance, dt, "up")
  end
  },

  spinattack = {
  run_state = function(instance, dt)
    instance.spinAttackCounter = instance.spinAttackCounter + dt
    instance.playerSpinPhase = instance.playerSpinPhase + dt
    if instance.playerSpinPhase > instance.playerSpinFreq then
      instance.playerSpinPhase = instance.playerSpinPhase - instance.playerSpinFreq
      if instance.spinKey then
        instance.spinKey = u.chooseKeyFromTable(instance.sideTable, instance.spinKey)
      else
        instance.spinKey = u.chooseKeyFromTable(instance.sideTable)
      end
      -- instance.spinSide = instance.sideTable[love.math.random(1,4)]
      local a = instance.spanSideKeys
      local spindex = u.chooseKeyFromTable(
        instance.sideTable,
        -- inelegant but I can't unpack
        a[1], a[2], a[3], a[4]
      )
      if #a == #instance.sideTable - 1 then
        for i, v in ipairs(a) do
          a[i] = nil
        end
      end
      table.insert(a, spindex)
      instance.spinSide = instance.sideTable[spindex]

      if instance.spinSide == "right" then
        instance.sprite = im.sprites["Witch/swing_left"]
        instance.x_scale = -1
      else
        instance.sprite = im.sprites["Witch/swing_" .. instance.spinSide]
        instance.x_scale = 1
      end

      instance.image_index = instance.sprite.frames - 1
    end
  end,

  check_state = function(instance, dt)
    if pddp(instance, instance.triggers, instance.spinSide) then
    elseif instance.spinAttackCounter > 0.6 then
      instance.animation_state:change_state(instance, dt, instance.spinSide .. "still")
    end
  end,

  start_state = function(instance, dt)
    snd.play(instance.sounds.swordSpin)
    instance.sounds.swordCharge:stop()
    instance.image_speed = 0
    instance.spinAttackCounter = 0
    instance.playerSpinFreq = 1 / 30
    instance.playerSpinPhase = instance.playerSpinFreq
    instance.spinKey = nil
    instance.spanSideKeys = {}
    -- Create sword
    instance.sword = sw:new{
      creator = instance,
      spin = true,
      layer = instance.layer
    }
    instance.spinattacking = true
    o.addToWorld(instance.sword)
  end,

  end_state = function(instance, dt)
    if instance.spinSide == "right" then instance.x_scale = 1 end
    instance.image_index = 0
    instance.image_speed = 0
    -- Delete sword
    o.removeFromWorld(instance.sword)
    instance.sword = nil
    instance.spinattacking = nil
  end
  },


  downjump = {
  run_state = function(instance, dt)
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
    hps.start_jump(instance, dt, "down")
  end,

  end_state = function(instance, dt)
  end
  },


  rightjump = {
  run_state = function(instance, dt)
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
    hps.start_jump(instance, dt, "right")
    instance.x_scale = -1
  end,

  end_state = function(instance, dt)
    instance.x_scale = 1
  end
  },


  leftjump = {
  run_state = function(instance, dt)
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
    hps.start_jump(instance, dt, "left")
  end,

  end_state = function(instance, dt)
  end
  },


  upjump = {
  run_state = function(instance, dt)
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
    hps.start_jump(instance, dt, "up")
  end,

  end_state = function(instance, dt)
  end
  },


  downfall = {
  run_state = function(instance, dt)
    hps.run_fall(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_fall(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_fall(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_fall(instance, dt, "down")
  end
  },


  rightfall = {
  run_state = function(instance, dt)
    hps.run_fall(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_fall(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_fall(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_fall(instance, dt, "right")
  end
  },


  leftfall = {
  run_state = function(instance, dt)
    hps.run_fall(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_fall(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_fall(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_fall(instance, dt, "left")
  end
  },


  upfall = {
  run_state = function(instance, dt)
    hps.run_fall(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_fall(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_fall(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_fall(instance, dt, "up")
  end
  },


  downmissile = {
  run_state = function(instance, dt)
    hps.run_missile(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_missile(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_missile(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_missile(instance, dt, "down")
  end
  },


  rightmissile = {
  run_state = function(instance, dt)
    hps.run_missile(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_missile(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_missile(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_missile(instance, dt, "right")
  end
  },


  leftmissile = {
  run_state = function(instance, dt)
    hps.run_missile(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_missile(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_missile(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_missile(instance, dt, "left")
  end
  },


  upmissile = {
  run_state = function(instance, dt)
    hps.run_missile(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_missile(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_missile(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_missile(instance, dt, "up")
  end
  },


  downgripping = {
  run_state = function(instance, dt)
    hps.run_gripping(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_gripping(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    instance.isDownGripping = true
    hps.start_gripping(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    instance.isDownGripping = nil
    hps.end_gripping(instance, dt, "down")
  end
  },


  rightgripping = {
  run_state = function(instance, dt)
    hps.run_gripping(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_gripping(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_gripping(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_gripping(instance, dt, "right")
  end
  },


  leftgripping = {
  run_state = function(instance, dt)
    hps.run_gripping(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_gripping(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_gripping(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_gripping(instance, dt, "left")
  end
  },


  upgripping = {
  run_state = function(instance, dt)
    hps.run_gripping(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_gripping(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_gripping(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_gripping(instance, dt, "up")
  end
  },


  downlifting = {
  run_state = function(instance, dt)
    hps.run_lifting(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_lifting(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_lifting(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_lifting(instance, dt, "down")
  end
  },


  rightlifting = {
  run_state = function(instance, dt)
    hps.run_lifting(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_lifting(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_lifting(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_lifting(instance, dt, "right")
  end
  },


  leftlifting = {
  run_state = function(instance, dt)
    hps.run_lifting(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_lifting(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_lifting(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_lifting(instance, dt, "left")
  end
  },


  uplifting = {
  run_state = function(instance, dt)
    hps.run_lifting(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_lifting(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_lifting(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_lifting(instance, dt, "up")
  end
  },


  downlifted = {
  run_state = function(instance, dt)
    hps.run_lifted(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_lifted(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_lifted(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_lifted(instance, dt, "down")
  end
  },


  rightlifted = {
  run_state = function(instance, dt)
    hps.run_lifted(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_lifted(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_lifted(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_lifted(instance, dt, "right")
  end
  },


  leftlifted = {
  run_state = function(instance, dt)
    hps.run_lifted(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_lifted(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_lifted(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_lifted(instance, dt, "left")
  end
  },


  uplifted = {
  run_state = function(instance, dt)
    hps.run_lifted(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_lifted(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_lifted(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_lifted(instance, dt, "up")
  end
  },


  downdamaged = {
  run_state = function(instance, dt)
    hps.run_damaged(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_damaged(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_damaged(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_damaged(instance, dt, "down")
  end
  },


  rightdamaged = {
  run_state = function(instance, dt)
    hps.run_damaged(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_damaged(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_damaged(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_damaged(instance, dt, "right")
  end
  },


  leftdamaged = {
  run_state = function(instance, dt)
    hps.run_damaged(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_damaged(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_damaged(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_damaged(instance, dt, "left")
  end
  },


  updamaged = {
  run_state = function(instance, dt)
    hps.run_damaged(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_damaged(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_damaged(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_damaged(instance, dt, "up")
  end
  },


  downmdust = {
  run_state = function(instance, dt)
    hps.run_mdust(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_mdust(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_mdust(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_mdust(instance, dt, "down")
  end
  },


  rightmdust = {
  run_state = function(instance, dt)
    hps.run_mdust(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_mdust(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_mdust(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_mdust(instance, dt, "right")
  end
  },


  leftmdust = {
  run_state = function(instance, dt)
    hps.run_mdust(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_mdust(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_mdust(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_mdust(instance, dt, "left")
  end
  },


  upmdust = {
  run_state = function(instance, dt)
    hps.run_mdust(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_mdust(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_mdust(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_mdust(instance, dt, "up")
  end
  },


  downsprintcharge = {
  run_state = function(instance, dt)
    hps.run_sprintcharge(instance, dt, "down")
  end,

  check_state = function(instance, dt)
    hps.check_sprintcharge(instance, dt, "down")
  end,

  start_state = function(instance, dt)
    hps.start_sprintcharge(instance, dt, "down")
  end,

  end_state = function(instance, dt)
    hps.end_sprintcharge(instance, dt, "down")
  end
  },


  rightsprintcharge = {
  run_state = function(instance, dt)
    hps.run_sprintcharge(instance, dt, "right")
  end,

  check_state = function(instance, dt)
    hps.check_sprintcharge(instance, dt, "right")
  end,

  start_state = function(instance, dt)
    hps.start_sprintcharge(instance, dt, "right")
  end,

  end_state = function(instance, dt)
    hps.end_sprintcharge(instance, dt, "right")
  end
  },


  leftsprintcharge = {
  run_state = function(instance, dt)
    hps.run_sprintcharge(instance, dt, "left")
  end,

  check_state = function(instance, dt)
    hps.check_sprintcharge(instance, dt, "left")
  end,

  start_state = function(instance, dt)
    hps.start_sprintcharge(instance, dt, "left")
  end,

  end_state = function(instance, dt)
    hps.end_sprintcharge(instance, dt, "left")
  end
  },


  upsprintcharge = {
  run_state = function(instance, dt)
    hps.run_sprintcharge(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_sprintcharge(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_sprintcharge(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_sprintcharge(instance, dt, "up")
  end
  },


  sprint = {
  run_state = function(instance, dt)
    hps.run_sprint(instance, dt)
  end,

  check_state = function(instance, dt)
    hps.check_sprint(instance, dt)
  end,

  start_state = function(instance, dt)
    hps.start_sprint(instance, dt)
  end,

  end_state = function(instance, dt)
    hps.end_sprint(instance, dt)
  end
  },


  sleeping = {
  run_state = function(instance, dt)
    instance.sleep_time = instance.sleep_time - session.delta_hours

    local deathsprite = im.sprites["Witch/die"]

    if instance.sprite ~= deathsprite then
      for k, v in pairs(instance.input) do
        if
          instance.sleep_time < 0
          or (
            v == 1
            and k ~= 'start'
            and k ~= 1
            and k ~= 2
            and k ~= 3
            and k ~= 4
            and k ~= 5
            and k ~= 6
            and k ~= 7
            and k ~= 8
            and k ~= 9
            and k ~= 10
          )
        then
          instance.sprite = deathsprite
          instance.image_speed = 0.1
          instance.image_index = 0
          session.sleeping_danger = false
        end
      end
    end
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state

    local deathsprite = im.sprites["Witch/die"]

    if pddp(instance, trig, 'down', dt) then
      instance.movement_state:change_state(instance, dt, "normal")
    elseif instance.sprite == deathsprite and trig.animation_end then
      instance.animation_state:change_state(instance, dt, "downstill")
      instance.movement_state:change_state(instance, dt, "normal")
    end
  end,

  start_state = function(instance, dt)
    instance.sleep_time = 10
    session.sleeping_danger = true
  end,

  end_state = function(instance, dt)
    session.sleeping_danger = false
    if instance.sleep_time < 0 then
      instance:addHealth(1)
    end
  end
  },


  downmark = {
  run_state = function(instance, dt)
    instance.markanim = instance.markanim - dt
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if pddp(instance, trig, "down") then
    elseif instance.climbing then
      instance.animation_state:change_state(instance, dt, "upclimbing")
    elseif trig.swing_sword then
      if trig.restish then
        instance.animation_state:change_state(instance, dt, "downswing")
      elseif abs(instance.vx) > abs(instance.vy) then
        if instance.vx > 0 then
          instance.animation_state:change_state(instance, dt, "rightswing")
        else
          instance.animation_state:change_state(instance, dt, "leftswing")
        end
      else
        if instance.vy < 0 then
          instance.animation_state:change_state(instance, dt, "upswing")
        else
          instance.animation_state:change_state(instance, dt, "downswing")
        end
      end
    elseif instance.markanim <= 0 then
      instance.animation_state:change_state(instance, dt, "downwalk")
    end
  end,

  start_state = function(instance, dt)
    if session.save.faroresCourage then
      instance.markanim = inv.mark.time
    else
      instance.markanim = inv.mark.time * 2
    end

    instance.sprite = im.sprites["Witch/mark_down"]

    snd.play(instance.sounds.markStart)
  end,

  end_state = function(instance, dt)
    if instance.markanim <= 0 and instance:canMark() then
      instance:newMark()
    end
  end
  },


  downrecall = {
  run_state = function(instance, dt)
    instance.recallanim = instance.recallanim - dt
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if pddp(instance, trig, "down") then
    elseif instance.climbing then
      instance.animation_state:change_state(instance, dt, "upclimbing")
    elseif trig.swing_sword then
      if trig.restish then
        instance.animation_state:change_state(instance, dt, "downswing")
      elseif abs(instance.vx) > abs(instance.vy) then
        if instance.vx > 0 then
          instance.animation_state:change_state(instance, dt, "rightswing")
        else
          instance.animation_state:change_state(instance, dt, "leftswing")
        end
      else
        if instance.vy < 0 then
          instance.animation_state:change_state(instance, dt, "upswing")
        else
          instance.animation_state:change_state(instance, dt, "downswing")
        end
      end
    elseif instance.recallanim <= 0 then
      instance.animation_state:change_state(instance, dt, "downwalk")
    end
  end,

  start_state = function(instance, dt)
    if session.save.faroresCourage then
      instance.recallanim = inv.recall.time
    else
      instance.recallanim = inv.recall.time * 2
    end

    instance.sprite = im.sprites["Witch/recall_down"]

    snd.play(instance.sounds.recallStart)
  end,

  end_state = function(instance, dt)
    if instance.mark and instance.mark.exists and instance.recallanim <= 0 and instance:canMark() then

      local purple = {0.4,0,0.4,1}
      local green = {0.3,1,0.3,1}
      local brightPurple = {0.9,0.3,0.9,1}

      if session.latestVisitedRooms:getLast() ~= instance.mark.roomName then
        if not game.transitioning and session.canRecallOtherRoom() then
          instance.sounds.recallStart:stop()
          snd.play(instance.sounds.recall)
          instance.stateTriggers.poof = true
          game.transition{
            type = "whiteScreen",
            progress = 0.8,
            roomTarget = instance.mark.roomName,
            playa = instance,
            desx = instance.mark.xstart,
            desy = instance.mark.ystart
          }
          explode.teleportEffect(instance.mark, false, session.save.faroresCourage and green or brightPurple)
          instance:newMark(true, session.latestVisitedRooms:getLast(), true)
        end
      else
        instance.sounds.recallStart:stop()
        if instance.mark:canSlice() then
          local ws = windSlice:new{
            x0 = instance.x,
            y0 = instance.y,
            x1 = instance.mark.xstart,
            y1 = instance.mark.ystart,
            cr = instance
          }
          o.addToWorld(ws)
        end
        snd.play(instance.sounds.recall)
        instance.stateTriggers.poof = true
        instance.body:setPosition(instance.mark.xstart, instance.mark.ystart)
        instance:newMark(true, nil, true)

        explode.teleportEffect(instance, false, purple)
        explode.teleportEffect(instance, true, session.save.faroresCourage and green or brightPurple)
      end

    end
  end
  },


  upclimbing = {
  run_state = function(instance, dt)
    hps.run_climbing(instance, dt, "up")
  end,

  check_state = function(instance, dt)
    hps.check_climbing(instance, dt, "up")
  end,

  start_state = function(instance, dt)
    hps.start_climbing(instance, dt, "up")
  end,

  end_state = function(instance, dt)
    hps.end_climbing(instance, dt, "up")
  end
  },


  downdrown = {
  run_state = function(instance, dt)
    instance.body:setLinearVelocity(0, 0)
    instance.respawnCounter = instance.respawnCounter + dt
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if instance.respawnCounter > 1 then
      instance.animation_state:change_state(instance, dt, "respawn")
    end
  end,

  start_state = function(instance, dt)
    instance.image_index = 0
    instance.xUnsteppable = instance.x
    instance.yUnsteppable = instance.y
    -- Ensure you're not jumping while drowning
    instance.jo = 0
    instance.fo = 0
    instance.zvel = 0
    instance.respawnCounter = 0

    instance.sprite = im.sprites["Witch/drown_down"]
    instance.image_speed = 0.3

    inp.disable_controller(instance.player)
    snd.play(glsounds.footsteps.waterjumplight)
    instance:setGhost(true)
  end,

  end_state = function(instance, dt)
    instance.image_index = 0
    instance.image_speed = 0
    inp.enable_controller(instance.player)
    instance:setGhost(false)
    if instance.body:getType() ~= "static" and not (dlg.enable or dlg.enabled) then
      instance:addHealth(-1)
    end
  end
  },


  downrecovery = {
    run_state = function(instance, dt)
      -- inp.disable_controller(instance.player)
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if pddp(instance, trig, "down", dt) then
        instance.movement_state:change_state(instance, dt, "normal")
      elseif trig.damaged then
        instance.animation_state:change_state(instance, dt, "downdamaged")
        instance.movement_state:change_state(instance, dt, "normal")
      elseif otherstate == "normal" then
        if instance.item_health_bonus then
          instance:addHealth(instance.item_health_bonus)
          snd.play(glsounds.getHeart)
        end
        instance.animation_state:change_state(instance, dt, "downstill")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.2
      if not instance.item_recovery_animation then
        instance.sprite = im.sprites["Witch/eating_down"]
      else
        instance.image_index = instance.item_image_index or instance.image_index
        instance.image_speed = instance.item_image_speed or instance.image_speed
        instance.sprite = im.sprites["Witch/" .. instance.item_recovery_animation]
      end
      inp.disable_controller(instance.player)
    end,

    end_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0
      instance.item_health_bonus = nil
      instance.item_recovery_animation = nil
      inp.enable_controller(instance.player)
    end
  },

  downharp = {
  run_state = function(instance, dt)
    inp.disable_controller(instance.player)
    if instance.skipFirstUpdate then instance.skipFirstUpdate = false; return end
    local notesPlayed = 0

    if inp.cancelPressed then
      items.keyLyre.use()
      return
    end

    for key, pressed in pairs(inp.keys.pressed) do
      if pressed then
        snd.play(instance.harpSoundTable[key])
        notesPlayed = notesPlayed + 1
      end
    end

    if notesPlayed > 0 then
      instance.harpTimer = 0.5
      if instance.noteTimer <= 0 then
        instance.noteTimer = 0.25
        local xstart = instance.x
        local ystart = instance.y
        local dir = math.pi * 0.5 * (- 1 - love.math.random())
        local xmod, ymod = u.polarToCartesian(instance.height, dir)
        xstart = xstart + xmod
        ystart = ystart + ymod
        local note = instance.noteObj:new{
          x = xstart, y = ystart,
          xstart = xstart, ystart = ystart,
          layer = instance.layer,
          randomize = true
        }
        o.addToWorld(note)
      end
    end
    if instance.harpTimer > 0 then
      instance.image_speed = 0.05
      if instance.prevHarpTimer == 0 then
        instance.image_index = 1
      end
    else
      instance.image_speed = 0
      instance.image_index = 0
    end
    instance.prevHarpTimer = instance.harpTimer
    instance.harpTimer = instance.harpTimer - dt
    if instance.harpTimer < 0 then instance.harpTimer = 0 end
    instance.noteTimer = instance.noteTimer - dt
    if instance.noteTimer < 0 then instance.noteTimer = 0 end
    if gs.musicOn then
      instance.wasMusicOn = gs.musicOn
      gs.musicOn = false
    end
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if trig.damaged then
      instance.animation_state:change_state(instance, dt, "downdamaged")
    end
  end,

  start_state = function(instance, dt)
    instance.skipFirstUpdate = true
    instance.noteObj = require "GameObjects.note"
    instance.image_index = 0
    instance.image_speed = 0
    instance.harpTimer = 0
    instance.noteTimer = 0
    instance.prevHarpTimer = 0

    instance.sprite = im.sprites["Witch/flute_down"]

    instance.movement_state:change_state(pl1, dt, "stand_still")
    instance.wasMusicOn = gs.musicOn
    gs.musicOn = false
    inp.disable_controller(instance.player)

    if not instance.harpSoundTable then
      instance.harpSoundTable = {
        -- White keys down
        z = glsounds.harpcd,
        x = glsounds.harpdd,
        c = glsounds.harped,
        v = glsounds.harpfd,
        b = glsounds.harpgd,
        n = glsounds.harpad,
        m = glsounds.harpbd,

        -- Black keys down
        s = glsounds.harpddB,
        d = glsounds.harpedB,
        g = glsounds.harpfdS,
        h = glsounds.harpadB,
        j = glsounds.harpbdB,

        -- White keys up
        q = glsounds.harpcm,
        w = glsounds.harpdm,
        e = glsounds.harpem,
        r = glsounds.harpfm,
        t = glsounds.harpgm,
        y = glsounds.harpam,
        u = glsounds.harpbm,

        ["2"] = glsounds.harpdmB,
        ["3"] = glsounds.harpemB,
        ["5"] = glsounds.harpfmS,
        ["6"] = glsounds.harpamB,
        ["7"] = glsounds.harpbmB,

        i = glsounds.harpcu,
        o = glsounds.harpdu,
        ["9"] = glsounds.harpduB
      }
    end
  end,

  end_state = function(instance, dt)
    if instance.wasMusicOn then gs.musicOn = true end
    instance.image_index = 0
    instance.image_speed = 0
    instance.wasMusicOn = nil
    instance.harpTimer = nil
    instance.noteTimer = nil
    instance.prevHarpTimer = nil
    instance.noteObj = nil
    instance.movement_state:change_state(pl1, dt, "normal")
    inp.enable_controller(instance.player)
  end
  },


  plummet = {
  run_state = function(instance, dt)
    local pmod = instance.image_index * (1 / (10 * instance.image_speed))
    if pmod > 1 then pmod = 1 end
    instance.body:setPosition(
      instance.xPlummetStart + pmod * (instance.xClosestTile - instance.xPlummetStart),
      instance.yPlummetStart + pmod * (instance.yClosestTile - instance.yPlummetStart)
    )
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if trig.animation_end then
      instance.animation_state:change_state(instance, dt, "respawn")
    end
  end,

  start_state = function(instance, dt)
    snd.play(instance.sounds.plummet)

    instance.sprite = im.sprites["Witch/plummet"]
    instance.image_speed = 0.15

    instance.xPlummetStart = instance.x
    instance.yPlummetStart = instance.y
    instance.plummetFrames = instance.sprite.frames
    instance.image_index = 0
    inp.disable_controller(instance.player)
    instance:setGhost(true)
  end,

  end_state = function(instance, dt)
    instance.xUnsteppable = instance.x
    instance.yUnsteppable = instance.y
    inp.enable_controller(instance.player)
    instance:setGhost(false)
    if instance.body:getType() ~= "static" and not (dlg.enable or dlg.enabled) then
      instance:addHealth(-1)
    end
  end
  },


  respawn = {
  run_state = function(instance, dt)
    if not instance.noVelTrans and not instance.transed then
      instance.transed = true
      instance.transvx, instance.transvy = instance.body:getLinearVelocity()
      local sd = instance.lastTransSide
      local xsign, ysign
      if sd == "left" then xsign = -1
      elseif sd == "right" then xsign = 1
      elseif sd == "up" then ysign = -1
      elseif sd == "down" then ysign = 1 end
      if xsign then
        if u.sign(xsign) ~= u.sign(instance.transvx) then
          instance.transvx = xsign * math.max(math.abs(instance.transvx), 10)
        end
      end
      if ysign then
        if u.sign(ysign) ~= u.sign(instance.transvy) then
          instance.transvy = ysign * math.max(math.abs(instance.transvy), 10)
        end
      end
    end
    instance.body:setLinearVelocity(0, 0)
    local rmod = instance.respawnCounter / instance.respawnCounterMax
    instance.body:setPosition(
      instance.xUnsteppable + rmod * (instance.xLastSteppable - instance.xUnsteppable),
      instance.yUnsteppable + rmod * (instance.yLastSteppable - instance.yUnsteppable)
    )
    if instance.respawnCounter then
      instance.respawnCounter = instance.respawnCounter + dt
    end
  end,

  check_state = function(instance, dt)
    local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
    if instance.respawnCounter > instance.respawnCounterMax then
      instance.animation_state:change_state(instance, dt, "downstill")
    end
  end,

  start_state = function(instance, dt)
    -- Change threshold to avoid screen transitions that get triggered
    -- prematurely because of noVelTrans
    instance.transvx, instance.transvy = nil, nil
    gvar.screenEdgeThreshold = 2
    instance.noVelTrans = true
    instance.transed = false
    instance.respawnCounter = 0
    instance.respawnCounterMax = 0.4
    instance.invisible = true
    inp.disable_controller(instance.player)
    instance:setGhost(true)
    if not instance.xLastSteppable or not instance.yLastSteppable then
      instance.xLastSteppable = instance.xUnsteppable
      instance.yLastSteppable = instance.yUnsteppable
    end
  end,

  end_state = function(instance, dt)
    gvar.screenEdgeThreshold = GCON.defaultScreenEdgeThreshold
    instance.noVelTrans = false
    instance.transed = nil
    instance.disableTransitions = false
    instance.body:setPosition(instance.xLastSteppable, instance.yLastSteppable)
    instance.invisible = false
    inp.enable_controller(instance.player)
    instance:setGhost(false)
    instance.invulnerable = 1
    if instance.transvx and instance.transvy then
      instance.body:setLinearVelocity(instance.transvx, instance.transvy)
    end
  end
  },


  downdie = {
  run_state = function(instance, dt)
    instance.deathStunCounter = instance.deathStunCounter + dt

    if instance.deathPhase == 1 then
      if instance.deathStunCounter > 1 then
        instance.deathPhase = 2
        instance.image_index = 1
        snd.play(instance.sounds.die)
      end
    elseif instance.deathPhase == 2 then
      instance.deathFallCounter = instance.deathFallCounter + dt
      if instance.deathFallCounter > 0.4 then
        instance.deathFallCounter = 0
        instance.deathPhase = 5
        instance.deathState = "dead"
        o.addToWorld(go:new{player = instance})
      end
      instance.ioy = instance.ioyDeathStart + math.sin(instance.deathFallCounter * 10)
    end
  end,

  check_state = function(instance, dt)
  end,

  start_state = function(instance, dt)
    instance.deathStunCounter = 0

    snd.play(instance.sounds.dying)
    instance.sprite = im.sprites["Witch/die"]
    instance.image_speed = 0

    inp.disable_controller(instance.player)
    instance.deathPhase = 1
    instance.image_index = 0
    instance.deathFallCounter = 0
    instance.ioyDeathStart = instance.ioy
    instance:setGhost(true)
    instance.deathState = "dying"
  end,

  end_state = function(instance, dt)
  end
  },


  cutscene = {
    run_state = function(instance, dt)
      inp.disable_controller(instance.player)
      instance:setGhost(true)
    end,

    check_state = function(instance, dt)
    end,

    start_state = function(instance, dt)
      inp.disable_controller(instance.player)
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
      inp.enable_controller(instance.player)
      instance:setGhost(false)
      instance.x_scale = 1
    end
  },


  dontdraw = {
  run_state = function(instance, dt)
    if instance.dontdrawRun then instance:dontdrawRun(dt) end
  end,

  check_state = function(instance, dt)
    if instance.dontdrawCheck then instance:dontdrawCheck(dt) end
  end,

  start_state = function(instance, dt)
    if instance.dontdrawStart then instance:dontdrawStart(dt) end
    instance.invisible = true
    inp.disable_controller(instance.player)
    instance:setGhost(true)
  end,

  end_state = function(instance, dt)
    if instance.dontdrawEnd then instance:dontdrawEnd(dt) end
    instance.dontdrawRun = nil
    instance.dontdrawCheck = nil
    instance.dontdrawStart = nil
    instance.dontdrawEnd = nil
    instance.invisible = false
    inp.enable_controller(instance.player)
    instance:setGhost(false)
  end
  }
}

local Playa = {}

function Playa.initialize(instance)
  game.transition{
    type = "whiteScreen",
    -- noFade = true,
    progress = 0,
    roomTarget = session.save.room or "Rooms/LakeVillage/startingHouse.lua"
  }

  -- Debug
  instance.db = {downcol = 255, upcol = 255, leftcol = 255, rightcol = 255}
  instance.floorFriction = 1 -- For testing. This info will normaly ba aquired through floor collisions
  instance.floorViscosity = nil -- For testing. This info will normaly ba aquired through floor collisions

  -- instance.persistent = true
  instance.transPersistent = true
  instance.setGhost = sg.setGhost
  instance.insertToSpellSlot = asp.insertToSpellSlot
  instance.readSave = ors.player
  -- Load stuff from save
  asp.emptySpellSlots()
  instance:readSave()

  -- Perceived state of sideScroll.
  -- might appear false even if true state is true,
  -- for example while climbing
  instance.sideScroll = false

  instance.ids[#instance.ids+1] = "PlayaTest"
  instance.timeFlow = 1
  instance.angle = 0
  instance.angvel = 0 -- angular velocity
  instance.width = ps.shapes.plshapeWidth
  instance.height = ps.shapes.plshapeHeight
  instance.x_scale = 1
  instance.y_scale = 1
  instance.iox = 0 -- drawing offsets due to item use (eg sword swing)
  instance.ioy = 0
  instance.shakex = 0 -- drawing offsets due to shaking
  instance.shakey = 0
  instance.zo = 0 -- drawing offsets due to z axis
  instance.zoPrev = instance.zo
  instance.fo = 0 -- drawing offsets due to falling
  instance.jo = 0 -- drawing offsets due to jumping
  instance.fake_zo = 0 -- zo_due to animation
  instance.zvel = 0 -- z axis velocity
  instance.gravity = 350
  instance.defaultGravity = instance.gravity
  instance.image_speed = 0
  instance.image_index = 0
  instance.image_index_prev = 0
  instance.brakesLim = 10
  instance.input = {}
  instance.previnput = {}
  instance.triggers = {}
  instance.stateTriggers = {}
  instance.sideTable = {"down", "right", "left", "up"}
  instance.sensors = {
    downTouchedObs={}, rightTouchedObs={}, leftTouchedObs={}, upTouchedObs={},
    downTouchedObsPush={}, rightTouchedObsPush={}, leftTouchedObsPush={}, upTouchedObsPush={},
  }
  instance.item_use_counter = 0 -- Counts how long you're still while using item
  instance.currentMasks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
  instance.thrownGoesThrough = true
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    density = 160, --160 is 50 kg when combined with plshape dimensions(w 10, h 8)
    shape = ps.shapes.plshape,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0,
    downSensor = ps.shapes.pldsens,
    upSensor = ps.shapes.plusens,
    leftSensor = ps.shapes.pllsens,
    rightSensor = ps.shapes.plrsens,
    categories = {DEFAULTCAT, FLOORCOLLIDECAT, PLAYERCAT},
    masks = instance.currentMasks
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.sprite_info = im.spriteSettings.playerSprites
  instance.lowGlow = {}
  instance.flickerPeriod = 1 / 30 -- in secs
  instance.flickerTick = 0
  instance.doesntForceDir = true
  instance.animationFramesPassed = 0
  instance.sounds = snd.load_sounds({
    swordTap1 = {"Effects/Oracle_Sword_Tap"},
    swordTap2 = {"Effects/Oracle_Shield_Deflect"},
    swordShoot = {"Effects/Oracle_Sword_Shoot"},
    land = {"Effects/Oracle_Link_LandRun"},
    magicMissile = {"Effects/Magic_Missile"},
    magicMissileCharge = {"Effects/MagicMissileCharge"},
    pickUp = {"Effects/Oracle_Link_PickUp"},
    throw = {"Effects/Oracle_Link_Throw"},
    hurt = {"Effects/Oracle_Link_Hurt"},
    mark = {"Effects/Oracle_MysterySeed"},
    recall = {"Effects/OOA_SwitchHook_Switch"},
    markStart = {"Effects/OOA_SeedShooter"},
    recallStart = {"Effects/Oracle_Link_GoronDance1"},
    water = {"Effects/Oracle_Link_Wade"},
    plummet = {"Effects/Oracle_Link_Fall"},
    dying = {"Effects/Oracle_Link_Dying"},
    die = {"Effects/Oracle_ScentSeed"},
    swordCharge = {"Effects/Oracle_Sword_Charge"},
    swordSpin = {"Effects/Oracle_Sword_Spin"},
    roll = {"Effects/WL3_Rolling"}
  })
  instance.floorTiles = {role = "playerFloorTilesIndex"} -- Tracks what kind of floortiles I'm on
  instance.player = "player1"
  inp.enable_controller(instance.player)
  instance.layer = 20
  instance.regen = 0
  instance.movement_state = sm.new_state_machine(movement_states)
  instance.animation_state = sm.new_state_machine(animation_states)

  ---@class PlayerLightSettings
  instance.light = {
    r1 = 16,
    r1Base = 11,
    r1Amp = 3,
    r1AngVel = 3 * 2,
    r1Angle = 0,
    r2 = 32,
    r2Base = 17,
    r2Amp = 2,
    r2AngVel = 3 * math.pi / 2,
    r2Angle = 0,
    r3 = 48,
    r3Base = 48,
    r3Amp = 1,
    r3AngVel = 3,
    r3Angle = 0,
  }
end

Playa.functions = {
  ---@param effect any
  ---@param id? string
  addActiveEffect = function(self, effect, id)
    if not self.activeEffects then self.activeEffects = {} end
    self.activeEffects[id or effect] = effect

    if effect.onAdd then
      effect:onAdd(self)
    end
  end,

  removeActiveEffect = function(self, effectOrID)
    if not self.activeEffects then self.activeEffects = {} end
    local found = self.activeEffects[effectOrID]
    if found then
      self.activeEffects[effectOrID] = nil

      if found.onRemove then
        found:onRemove(self)
      end
    else
      if type(effectOrID) ~= "string" then
        for key, effect in pairs(self.activeEffects) do
          if effect == effectOrID then
            self.activeEffects[key] = nil

            if effect.onRemove then
              effect:onRemove(self)
            end
            break
          end
        end
      end
    end
  end,

  grounded = function(self)
    if game.room.sideScrolling then
      local _, vy = self.body:getLinearVelocity()
      local twitchThreshold = 0.1
      if vy < -twitchThreshold then return false end
      for _, other in ipairs(self.sensors.downTouchedObs) do
        if self:canCollide(other) then return true end
      end
      return false
    end

    return self.zo == 0
  end,

  canDoubleJump = function(self)
    if not session.jumpL2 then return false end
    if self.double_jumping then return false end

    local vel = self.zvel

    if self.sideScroll then
      local _, vy = self.body:getLinearVelocity()
      vel = -vy
    end

    if vel <= -86 and not self:grounded() then return true end

    return false
  end,

  addHealth = function (self, addedHealth)
    self.health = math.min(self.health + addedHealth, self.maxHealth)
  end,

  applyLights = function (self, x, y)
    if session.save.playerGlowAvailable then
      lighting.sendNightVision(not session.save.playerGlow or session.save.playerGlow == "No Glow")
      if not session.save.playerGlow or session.save.playerGlow == "No Night Vision" then
        -- lighting.applyLight({
        --   type = "playerGlow",
        --   -- type = "torch", image_index = 0,
        --   x = x,
        --   y = y,
        --   rgba = {
        --     r = 1,
        --     g = 0.3,
        --     b = 0,
        --     a = 1
        --   },
        --   image_index = self.flickerIndex
        -- });
        ---@type PlayerLightSettings
        local l = self.light
        lighting.applyLight({
          type = "dynamic",
          -- type = "torch", image_index = 0,
          x = x,
          y = y,
          rgba = {
            r = 1,
            g = 0.8,
            b = 0.6,
            a = 0.5
          },
          dynamic_options = {
            radius = l.r1
          }
        });
        lighting.applyLight({
          type = "dynamic",
          -- type = "torch", image_index = 0,
          x = x,
          y = y,
          rgba = {
            r = 1,
            g = 0.8,
            b = 0.6,
            a = 0.3
          },
          dynamic_options = {
            radius = l.r2
          }
        });
        -- lighting.applyLight({
        --   type = "dynamic",
        --   -- type = "torch", image_index = 0,
        --   x = x,
        --   y = y,
        --   rgba = {
        --     r = 1,
        --     g = 0.3,
        --     b = 0,
        --     a = 0.1
        --   },
        --   dynamic_options = {
        --     radius = l.r3
        --   }
        -- });
      end
    end
  end,

  getFacing = function (self)
    local as = self.animation_state.state
    if as == "sprint" then return self.sprintSide
    elseif as:find("up") then return "up"
    elseif as:find("left") then return "left"
    elseif as:find("right") then return "right"
    elseif as:find("down") then return "down"
    else return "down" end
  end,

  getXFacing = function(self)
    local f = self:getFacing()
    if f == "left" then return -1 end
    if f == "right" then return 1 end
    return 0
  end,

  getYFacing = function(self)
    local f = self:getFacing()
    if f == "up" then return -1 end
    if f == "down" then return 1 end
    return 0
  end,

  successfullyBullrushed = function (self, other)
    return self.immasprint and other.canBeBullrushed and (not other.shielded or other.shieldDown)
  end,

  canMark = function (self)
    return not self.onEdge and self:grounded()
  end,

  newMark = function (self, silent, roomName, reuse)
    local used = 0
    if self.mark and self.mark.exists then
      if reuse then used = used + self.mark.used + 1 end
      o.removeFromWorld(self.mark)
    end
    self.sounds.markStart:stop()
    if not silent then snd.play(self.sounds.mark) end
    self.mark = mark:new{xstart = self.x, ystart = self.y, creator = self, layer = self.layer - 1, used = used}
    if roomName then self.mark.roomName = roomName end
    o.addToWorld(self.mark)
  end,

  takeDamage = function (self, other)
    if self.body:getType() ~= "static" and
    not (dlg.enable or dlg.enabled) and
    other.damager and
    not self.invulnerable and
    not other.harmless and
    not self:successfullyBullrushed(other)
    then
      self.triggers.damaged =
        (other.attackDmg or 1) *
        (0.5 + (session.save.nayrusWisdom and 0 or 0.25) +
        (0.25 - session.getArmorDamageReduction() * 0.25))
      self.triggers.altHurtSound = other.altHurtSound
      local mybod = self.body
      local mymass = mybod:getMass()
      local lvx, lvy = mybod:getLinearVelocity()
      mybod:applyLinearImpulse(-lvx * mymass, -lvy * mymass)
      local impdirx, impdiry =
        u.normalize2d(self.x - other.x or self.x, self.y - other.y or self.y)
      local _, myBrakes = session.getAthlectics()
      local clbrakes = u.clamp(0, myBrakes, self.brakesLim)
      local ipct = other.impact or 10
      if not mainCamera.shaking then
        -- Shake camera when taking damage
        -- Change stuff here to customize it more
        -- to amount of damage and enemy causing it
        -- Only works if not already shaking
        gsh.newShake(mainCamera, "displacement", other.attackShakeMagn, nil, other.attackShakeDur)
      end
      if other.immabombsplosion or other.explosive then
        self.zvel = other.blowUpForce or 177
        self.triggers.damCounter = other.damCounter or 1.5
      end
      mybod:applyLinearImpulse(impdirx*ipct*clbrakes*mymass, impdiry*ipct*clbrakes*mymass)
    end
  end,

  update = function(self, dt)

    -- -- float
    -- self.fo = -2
    -- self.zvel = 0
    if session.ringTimeflow then
      self.timeFlow = session.ringTimeflow
    else
      self.timeFlow = 1
    end
    dt = dt * self.timeFlow

    -- Handle cooldowns
    if session.save.bombs < session.save.maxBombs then
      session.save.bombsCooldown = session.save.bombsCooldown - dt * 1.5
      while session.save.bombsCooldown < 0 do
        session.save.bombsCooldown = session.save.bombsCooldown + 1
        session.addBombs(1)
      end
    else
      session.save.bombsCooldown = 1
    end

    if session.save.dust < session.save.maxDust then
      session.save.dustCooldown = session.save.dustCooldown - dt * 1.5
      while session.save.dustCooldown < 0 do
        session.save.dustCooldown = session.save.dustCooldown + 1
        session.addDust(1)
      end
    else
      session.save.dustCooldown = 1
    end

    -- Make see through if there's a decoy
    if session.decoy then
      self.seeThrough = true
    else
      self.seeThrough = nil
    end

    -- Store usefull stuff
    local vx, vy = self.body:getLinearVelocity()
    local x, y = self.body:getPosition()
    self.speed = sqrt(vx*vx + vy*vy)
    self.vx, self.vy = vx, vy
    self.x, self.y = x, y

    -- Track position for debugging
    -- fuck = "x = " .. floor(x) .. ", y = " .. floor(y) .. "\n\z
    --         xSquare = " .. floor(x/16)*16 .. ", ySquare = " .. floor(y/16)*16 .. "\n\z
    --         xCenter = " .. floor(x/16)*16+8 .. ", yCenter = " .. floor(y/16)*16+8
    self.flickerTick = self.flickerTick + dt
    if self.flickerTick > self.flickerPeriod then
      self.flickerTick = self.flickerTick - self.flickerPeriod
      self.flickerIndex = love.math.random(0, 2)
      if self.flickerIndex == 2 then self.flickerIndex = nil end
    end

    -- Determine previous movement modifiers due to floor
    self.inShallowWaterPrev = self.inShallowWater
    -- Determine movement modifiers due to floor
    self.ongrass = nil
    self.inShallowWater = nil
    self.inDeepWater = nil
    self.overGap = nil
    self.closestTile = nil
    self.landedTileSound = "land"
    if self.floorTiles[1] then
      -- I could be stepping on up to four tiles. Find closest to determine mods
      local closestTile
      local closestDistance = huge
      local distance

      for _, floorTile in ipairs(self.floorTiles) do
        -- Magic number to account for player height
        distance = distanceSqared2d(x, y+6, floorTile.xstart, floorTile.ystart)

        if distance <= closestDistance then
          closestDistance = distance
          closestTile = floorTile
        end
      end

      -- Old stupid method of finding closest tile that caused trouble
      -- if new doesn't solve trouble review
      -- local closestTile
      -- local closestDistance = huge
      -- local previousClosestDistance
      --
      -- for _, floorTile in ipairs(self.floorTiles) do
      --   previousClosestDistance = closestDistance
      --   -- Magic number to account for player height
      --   closestDistance = min(distanceSqared2d(x, y+6, floorTile.xstart, floorTile.ystart), closestDistance)
      --
      --   -- If I get weird crashes that have to do with floor tiles
      --   -- check stuff out here.
      --   -- < to <= fixes it but breaks correct tile detection
      --   if closestDistance < previousClosestDistance then
      --     closestTile = floorTile
      --   end
      -- end
      --
      -- if not closestTile then
      --   closestTile = self.floorTiles[1]
      -- end

      self.xClosestTile = closestTile.xstart
      self.yClosestTile = closestTile.ystart

      self.floorFriction = closestTile.floorFriction
      self.floorViscosity = closestTile.floorViscosity

      if self.sideScroll then
        self.floorFriction = 1
        self.floorViscosity = nil
      end

      if closestTile.grass then
        if self:grounded() and not self.sideScroll then
          self.ongrass = im.sprites[closestTile.grass]
        end
      elseif closestTile.shallowWater then
        if self:grounded() and not self.sideScroll then
          self.inShallowWater = im.sprites[closestTile.shallowWater]
          self.landedTileSound = "water"
        end
      elseif closestTile.water then
        if self:grounded() and not self.sideScroll then
          if session.save.walkOnWater then
            self.inShallowWater = im.sprites[closestTile.water]
            self.landedTileSound = "water"
          else
            self.inDeepWater = true
            self.landedTileSound = "none"
          end
        end
      elseif closestTile.gap then
        if self:grounded() and not self.sideScroll then
          self.overGap = true
          self.landedTileSound = "none"
        end
      end
      -- Where to respawn if I fall in a gap or drown
      if not closestTile.unsteppable then
        self.xLastSteppable = closestTile.xstart
        self.yLastSteppable = closestTile.ystart - 2
      end
      self.closestTile = closestTile
    else
      self.floorFriction = 1
      self.floorViscosity = nil
    end

    if self:grounded() then
      -- watersound
      if self.inShallowWater and not self.inShallowWaterPrev and self.groundedPrev then
        local ct = self.closestTile
        if ct then
          if u.anyOf(ct.tileType, {"mud"}) then
            snd.play(glsounds.footsteps.mudrun)
          else
            snd.play(glsounds.footsteps.waterwalk)
          end
        else
          snd.play(glsounds.footsteps.waterwalk)
        end
      end
      -- dungeonJumpingLand
      if self.dungeonJumping and self.zvel == 0 then
        self.dungeonJumping = nil
        inp.enable_controller(self.player)
        self:setGhost(false)
      end
    else
      -- dungeonJumping
      if self.dungeonJumping then
        self:setGhost(true)
        inp.disable_controller(self.player)
        self.body:setLinearVelocity(self.dungeonJumping[1], self.dungeonJumping[2])
      end
    end

    -- Return movement table based on the long term action you want to take (Npcs)
    -- Return movement table based on the given input (Players)
    self.input = inp.current[self.player]
    self.previnput = inp.previous[self.player]
    if (self.input.start == 1 and self.previnput.start == 0)
      or (
        ((not inp.controllers[self.player].disabled)
        and (not inp.controllers[self.player].blocked))
        and
        ((inp.escapePressed and not inp.escapeBlocked)
        or (inp.backspacePressed and not inp.backspaceBlocked))
      )
    then
      game.pause(self)
    end

    -- use hotkeys
    for i=1,10 do
      if self.input[i] == 1 and self.previnput[i] == 0 then
        local itemid = session.save["keybind" .. i]
        local used = items.useItem(itemid)
        local overlay = require "GameObjects.overlayText.overplayer"
        if used and session.usedItemComment and session.usedItemComment ~= "" then overlay.createNew(session.usedItemComment) end
      end
    end

    -- Check if I must try to activate activatable
    if inp.enterPressed then
      local state = self.animation_state.state
      local touchSide
      if state:find("up") then
        touchSide = "upTouchedObs"
      elseif state:find("down") then
        touchSide = "downTouchedObs"
      elseif state:find("left") then
        touchSide = "leftTouchedObs"
      else
        touchSide = "rightTouchedObs"
      end
      -- Cycle through touched obs to see if any are activatables!
      local activatedSomething = false
      for _, other in ipairs(self.sensors[touchSide]) do
        if not activatedSomething then
          -- Check if activatable and if yes activate
          if other.activate and not other.unactivatable and not dlg.enable and not dlg.enabled then
            other.activated = true
            other.unactivatable = true
            other.activator = self
          end
        end
      end
    end

    -- Check if falling off edge
    if self.edgeFall then
      if self.edgeFall.step2 then
        self.fo = self.fo - self.edgeFall.height
        self.edgeFall = nil
      else
        self.body:setPosition(x, y + self.edgeFall.height)
        -- for sensorID, _ in pairs(self.sensors) do
        --   self.sensors[sensorID] = nil
        -- end
        self.edgeFall.step2 = true
      end
    end

    -- Determine triggers
    local trig = self.triggers
    self.angle = self.angle + dt*self.angvel
    while self.angle >= pi do
      self.angle = self.angle - pi
      trig.full_rotation = true
    end
    self.image_index_prev = self.image_index
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
      if frames > 1 then trig.animation_end = true end
    end
    while self.image_index < 0 do
      self.image_index = self.image_index + frames
      if frames > 1 then trig.animation_end = true end
    end
    if self.health <= 0 then
      trig.noHealth = true
    else
      -- Decrease invulnerablity counter
      -- It's here because it's only relevant if I'm alive
      if self.invulnerable then
        self.invulnerable = self.invulnerable - dt
        if not self.noInvShader and floor(7 * self.invulnerable % 2) == 1 then
          trig.enableHitShader = true
        end
        if self.invulnerable < 0 then
          self.invulnerable = nil
          self.noInvShader = nil
        end
      end
    end
    trig.land = self:grounded() and self.groundedPrev == false
    self.zoPrev = self.zo
    self.groundedPrev = self:grounded()
    td.determine_animation_triggers(self, dt)
    inv.determine_equipment_triggers(self, dt)

    if trig.restish and not self.restishPrev then
      self.animationFramesPassed = 0
    else
      if self.spriteNamePrev ~= self.sprite.name then
        self.animationFramesPassed = 0
      end

      if math.floor(self.image_index_prev) ~= math.floor(self.image_index) then
        self.animationFramesPassed = self.animationFramesPassed + 1
      end
    end
    self.spriteNamePrev = self.sprite.name

    local prevCli = self.climbing
    self.climbing = nil
    if self.closestTile and self.closestTile.climbable then
      if game.room.sideScrolling then
        if prevCli then
          self.climbing = true
        else
          local up = self.input.up or 0
          local down = self.input.down or 0
          self.climbing = up - down == 1 or nil
        end
      elseif self.zo == 0 then
        self.climbing = true
      end
    end

    if game.room.sideScrolling and not self.climbing then
      self.sideScroll = true
    else
      self.sideScroll = false
    end

    -- Determine z axis offset
    td.zAxisPlayer(self, dt)

    sh.handleShadow(self, true)

    -- Handle states
    -- Turn off state triggers
    -- (they are triggers enabled in states)
    for trigger, _ in pairs(self.stateTriggers) do
      self.stateTriggers[trigger] = nil
    end

    local ms = self.movement_state
    -- Check movement state
    ms.states[ms.state].check_state(self, dt)
    -- Run movement state
    ms.states[ms.state].run_state(self, dt)

    local as = self.animation_state
    -- Check animation state
    as.states[as.state].check_state(self, dt)
    -- Run animation state
    as.states[as.state].run_state(self, dt)

    -- Check if landing sound should be played
    if trig.land and self.landedTileSound ~= "none" then
      snd.playLandSound(self.closestTile, self.inShallowWater)
    end

    -- Trigger sudden disappearance if decoy disappeared
    if self.decoyPrev and not session.decoy then
      self.stateTriggers.poof = true
    end
    self.decoyPrev = session.decoy

    self.db.downcol = 255
    self.db.upcol = 255
    self.db.leftcol = 255
    self.db.rightcol = 255
    if self.sensors.downTouch then
      self.db.downcol = 0
    end
    if self.sensors.upTouch then
      self.db.upcol = 0
    end
    if self.sensors.leftTouch then
      self.db.leftcol = 0
    end
    if self.sensors.rightTouch then
      self.db.rightcol = 0
    end

    -- fuck = ""
    -- for key, val in pairs(self.sensors) do
    --   if type(val) == "table" then val = #val end
    --   fuck = fuck .. key .. ": " .. val .. '\n'
    -- end

    -- set Shader
    if trig.enableHitShader then
      self.playerShader = hitShader
    else

      if shdrs.customTunic then
        local rgb = {r=0,g=0,b=0}
        if session.save.customTunicAvailable and session.save.customTunicEnabled then
          rgb.r = session.save.tunicR
          rgb.g = session.save.tunicG
          rgb.b = session.save.tunicB
        elseif session.save.armorLvl == 1 then
          rgb.r = 0.282; rgb.g = 0.659; rgb.b = 0.722
        elseif session.save.armorLvl == 2 then
          rgb.r = 0.733; rgb.g = 0.353; rgb.b = 0.380
        elseif session.save.armorLvl == 3 then
          rgb.r = 0.565; rgb.g = 0.439; rgb.b = 0.690
        else
          rgb.r = 0.282; rgb.g = 0.627; rgb.b = 0.471
        end
        shdrs.customTunic:send("rgb", rgb.r, rgb.g, rgb.b,
        1) -- send one extra value to offset bug
        self.playerShader = shdrs.customTunic
      end

    end

    -- Shake if scared, or cold, etc
    if self.triggers.shaking then
      self.shakex, self.shakey = 1 - love.math.random() * 2, 1 - love.math.random() * 2
    else
      self.shakex, self.shakey = 0, 0
    end

    -- Apply active effects
    if self.activeEffects then
      for _, effect in pairs(self.activeEffects) do
        if effect.update then
          effect:update(self, dt)
        end
      end
    end

    local regen = dt * (self.regen or 0)
    self:addHealth(regen)

    self.restishPrev = trig.restish

    -- Turn off triggers
    -- triggersdebug = {}
    for trigger, _ in pairs(self.triggers) do
      -- if self.triggers[trigger] then triggersdebug[trigger] = true end
      -- self.triggers[trigger] = false
      self.triggers[trigger] = nil
    end

    ---@type PlayerLightSettings
    local l = self.light

    l.r1Angle = l.r1Angle + dt * l.r1AngVel
    while l.r1Angle > 2 * math.pi do
      l.r1Angle = l.r1Angle - 2 * math.pi
    end
    l.r1 = l.r1Base + math.sin(l.r1Angle) * l.r1Amp * 0.5

    l.r2Angle = l.r2Angle + dt * l.r2AngVel
    while l.r2Angle > 2 * math.pi do
      l.r2Angle = l.r2Angle - 2 * math.pi
    end
    l.r2 = l.r2Base + math.sin(l.r2Angle) * l.r2Amp * 0.5

    l.r3Angle = l.r3Angle + dt * l.r3AngVel
    while l.r3Angle > 2 * math.pi do
      l.r3Angle = l.r3Angle - 3 * math.pi
    end
    l.r3 = l.r3Base + math.sin(l.r3Angle) * l.r3Amp * 0.5
  end,

  unstoppable_update = function(self)
    if self.animation_state.state == "dontdraw" then return end
    if self.invisible then return end
    if game.transitioning then return end
    local x, y = self.x, self.y
    local xtotal, ytotal = x + self.iox, y + self.ioy + self.zo
    self:applyLights(xtotal, ytotal)
  end,

  customDraw = function(self, transitioning)
    if self.animation_state.state == "dontdraw" then return end
    if self.invisible then return end

    local x, y = self.x, self.y

    local xtotal, ytotal = x + self.iox, y + self.ioy + self.zo

    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end

    if transitioning then
      -- x, y modifications because of transition
      xtotal = xtotal + game.transitioning.xmod + trans.xtransform - game.transitioning.progress * trans.xadjust
      ytotal = ytotal + game.transitioning.ymod + trans.ytransform - game.transitioning.progress * trans.yadjust
    else
      -- Only update spritejoint outside transitions otherwise junkiness ensues
      self.spritebody:setPosition(xtotal, ytotal)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

    if transitioning then self:applyLights(xtotal, ytotal) end

    local f = self:getFacing()
    local hori_facing = f == 'right' or f == 'left'

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.playerShader)

    if self.broom_exists and hori_facing then
      local sprite = im.sprites['Witch/broom_left']
      local frame = sprite[math.floor(self.broom_image_index)]
      love.graphics.draw(
      sprite.img, frame, xtotal + self.shakex, ytotal + self.shakey, self.angle,
      sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
      sprite.cx, sprite.cy)
    end

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    while self.image_index < 0 do
      self.image_index = self.image_index + sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    local prevBm = love.graphics.getBlendMode()
    -- Shader effect if decoy exists
    if session.decoy then
      love.graphics.setBlendMode("subtract")
    end

    local xfinal = xtotal + self.shakex
    local yfinal = ytotal + self.shakey

    love.graphics.draw(
    sprite.img, frame, xfinal, yfinal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)


    if self.broom_exists and not hori_facing then
      local s = im.sprites['Witch/broom_' .. f]
      local fr = s[math.floor(self.broom_image_index)]
      love.graphics.draw(
      s.img, fr, xtotal + self.shakex, ytotal + self.shakey, self.angle,
      s.res_x_scale*self.x_scale, s.res_y_scale*self.y_scale,
      s.cx, s.cy)
    end

    love.graphics.setShader(worldShader)
    love.graphics.setBlendMode(prevBm)

    -- Draw Grass
    if self.ongrass then
      local grassSprite = self.ongrass
      local imgIndexFrameMod = (0.5*self.image_index)%1
      local grassFrame = grassSprite[floor(grassSprite.frames*imgIndexFrameMod)]
      love.graphics.draw(
      grassSprite.img, grassFrame, xtotal, ytotal, self.angle,
      grassSprite.res_x_scale*self.x_scale, grassSprite.res_y_scale*self.y_scale,
      grassSprite.cx, grassSprite.cy)
    end

    -- Draw Water Ripples
    if self.inShallowWater then
      local shwSprite = self.inShallowWater
      local imgIndex = im.globimage_index1234
      local shwFrame = shwSprite[floor(imgIndex)]
      love.graphics.draw(
      shwSprite.img, shwFrame, xtotal, ytotal + 8, self.angle,
      shwSprite.res_x_scale*self.x_scale, shwSprite.res_y_scale*self.y_scale,
      shwSprite.cx, shwSprite.cy)
    end

    -- love.graphics.circle("fill", self.x, self.y, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    --
    -- love.graphics.setColor(1, self.db.downcol, self.db.downcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.upcol, self.db.upcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.leftcol, self.db.leftcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.rightcol, self.db.rightcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, 1, 1, 1)
  end,

  holdingDirectionalKey = function(self)
    if self.input then
      if self.input.down + self.input.up > 0 then return true end
      if self.input.left + self.input.right > 0 then return true end
    end

    return false
  end,

  draw = function(self)
    self:customDraw()
  end,

  trans_draw = function(self)
    self:customDraw(true)
  end,

  load = function(self)
    self.shadownSprite = im.sprites["Witch/shadow"]
    -- self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    if aob == bob then return end

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      if other.untouchable then return end
      local sensorID = myF:getUserData() -- string

      if sensorID then
        local sensors = self.sensors
        -- if (not other.unpushable) and (not other.goThroughPlayer) then
        if not other.unpushable then
          if other.edge then
            other.onEdge = ec.isOnEdge(other, self)
          end
          if not other.onEdge then
            -- local sensors = self.sensors
            sensors[sensorID] = sensors[sensorID] or 0
            sensors[sensorID] = sensors[sensorID] + 1
            insert(sensors[sensorID .. "edObsPush"], other)
          end
        end
        insert(sensors[sensorID .. "edObs"], other)
      end

    else

      if (other.zoSafeZone and (other.zoSafeZone > other.zo)) then
        coll:setEnabled(false)
        return
      end

      -- Remember if I'm on an edge
      if other.edge then self.onEdge = true end

      -- Remember Floor tiles
      u.rememberFloorTile(self, other)

      -- Occupy tile
      if other.floor then
        other.occupied = other.occupied and other.occupied + 1 or 1
      end

      if otherF:isSensor() then
        self:takeDamage(other)
      end
    end

  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      local sensors = self.sensors
      local sensorID = myF:getUserData()
      if (not sensorID) or (not sensors) then return end
      for i, touchedOb in ipairs(sensors[sensorID .. "edObs"]) do
        if touchedOb == other then
          remove(sensors[sensorID .. "edObs"], i)
          break
        end
      end
      for i, touchedOb in ipairs(sensors[sensorID .. "edObsPush"]) do
        if touchedOb == other then
          remove(sensors[sensorID .. "edObsPush"], i)
          sensors[sensorID] = sensors[sensorID] - 1
          if sensors[sensorID] == 0 then sensors[sensorID] = nil end
          break
        end
      end

    else
      -- Remember if I'm on an edge
      if other.edge then self.onEdge = false end

      -- Forget Floor tiles
      u.forgetFloorTile(self, other)

      -- Unoccupy tile
      if other.occupied then
        other.occupied = other.occupied - 1
        if other.occupied < 1 then other.occupied = nil end
      end
    end

  end,

  canCollide = function(self, other)
    if self:endCollision(other) then return false end
    if other.goThroughPlayer then return false end
    return true
  end,

  endCollision = function(self, other)
    if other.floor or other.notSolidStatic then return true end
    return false
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if not self:canCollide(other) then coll:setEnabled(false) end
    if self:endCollision(other) then return end
    if not myF:isSensor() then
      -- jump over stuff on ground
      if other.grounded then
        if self.zo < 0 then coll:setEnabled(false); return end
      end
      -- go under stuff on the air
      if (other.zoSafeZone and (other.zoSafeZone > other.zo)) then
        coll:setEnabled(false)
        return
      end
      self:takeDamage(other)
      if other.fairy then
        other:healPlaya(self, coll)
        return
      end

      -- Handle sprinting collisions
      if self.immasprint then
        -- If not on ground
        if other.zo and other.zo < 0 and not other.lowFlight then return end
        -- If damager that can't be bullrushed, skip this to take damage
        if other.damager and not other.canBeBullrushed then return end

        if other.sprintThrough or (other.canBeBullrushed and other.canBeRolledThrough and session.save.faroresCourage) then
          -- If target is "soft" go through it
          coll:setEnabled(false)
          if other.liftable and (other.pushover or (other.strongPushover and session.save.faroresCourage)) then
            other:throw_collision()
            o.removeFromWorld(other)
            other.beginContact = nil
          end
        -- elseif self.speed > 2 then
        else
          -- else see if you get thrown back

          -- Get vector perpendicular to collision
          local nx, ny = coll:getNormal()

          -- make sure it points AWAY from obstacle if applied to player
          local dx, dy = self.x - other.x, self.y - other.y
          if nx * dx < 0 or ny * dy < 0 then -- checks if they have different signs
            nx, ny = -nx, -ny
          end

          -- make sure it was an (almost) head-on collision
          -- find angle between vectors (th)
          local dot = nx * self.vx + ny * self.vy
          -- costh = 	a*b / |a|*|b|
          local prod = self.speed * 1
          local costh = dot / prod
          local th = math.acos(costh)

          -- Take care of very low speeds
          local speedOverride = nil
          local sprintDirOverride = nil
          if self.speed < 2 then
            -- dot = nx * self:getXFacing() + ny * self:getYFacing()
            -- prod = 1
            if (nx == 0 and ny == -self:getYFacing()) or (ny == 0 and nx == -self:getXFacing()) then
              th = math.pi
              speedOverride = 100
              _, sprintDirOverride = u.cartesianToPolar(nx, ny)
            end
          end

          -- react to collision
          if th > 0.74 * math.pi then
            if other.liftable and (other.pushover or (other.strongPushover and session.save.faroresCourage)) then
              other:throw_collision()
              o.removeFromWorld(other)
              other.beginContact = nil
            end
            if session.bounceRing then
              -- self._, self.sprintDir = u.cartesianToPolar(nx, ny)
              if not self.triggers.rrBounce then
                self.triggers.rrBounce = true
                self._, self.sprintDir = u.cartesianToPolar(u.reflect(self.vx, self.vy, nx, ny))
                self.sprintDir = sprintDirOverride or self.sprintDir
                snd.play(glsounds.bombDrop)
              end
            else
              -- if unsuccesfull bullrush on enemy that can
              -- be bullrushed, take already calculated damage
              self.triggers.damaged = self.triggers.damaged or 0
              self.triggers.damCounter = session.save.faroresCourage and 0 or 1
              self.triggers.damKeepMoving = true
              self.triggers.altHurtSound = self.sounds.die
              gsh.newShake(mainCamera, "displacement")
              self.zvel = 100
              local newSpeed = speedOverride or self.speed * 0.8
              self.body:setLinearVelocity(nx * newSpeed, ny * newSpeed)
            end
          end
        end
      end
    end
  end,

  postSolve = function(self, a, b, coll, normalimpulse, tangentimpulse)
  end
}

function Playa:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Playa, instance, init) -- add own functions and fields
  return instance
end

return Playa
