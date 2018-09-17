local ps = require "physics_settings"
local im = require "image"
local inp = require "input"
local inv = require "inventory"
local p = require "GameObjects.prototype"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"
local trans = require "transitions"

local hps = require "GameObjects.Helpers.player_states"
local dc = require "GameObjects.Helpers.determine_colliders"
local ec = require "GameObjects.Helpers.edge_collisions"

local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"
local mark = require "GameObjects.Items.mark"

local sh = require "GameObjects.shadow"

local sqrt = math.sqrt
local floor = math.floor
local choose = u.choose
local insert = table.insert
local remove = table.remove
local max = math.max
local abs = math.abs

local check_walk = hps.check_walk
local check_halt = hps.check_halt
local check_still = hps.check_still
local check_push = hps.check_push
local run_swing = hps.run_swing
local check_swing = hps.check_swing
local start_swing = hps.start_swing
local end_swing = hps.end_swing
local run_stab = hps.run_stab
local check_stab = hps.check_stab
local start_stab = hps.start_stab
local end_stab = hps.end_stab
local check_hold = hps.check_hold
local start_hold = hps.start_hold
local start_jump = hps.start_jump
local run_fall = hps.run_fall
local check_fall = hps.check_fall
local start_fall = hps.start_fall
local end_fall = hps.end_fall
local run_missile = hps.run_missile
local check_missile = hps.check_missile
local start_missile = hps.start_missile
local end_missile = hps.end_missile
local run_gripping = hps.run_gripping
local check_gripping = hps.check_gripping
local start_gripping = hps.start_gripping
local end_gripping = hps.end_gripping
local run_lifting = hps.run_lifting
local check_lifting = hps.check_lifting
local start_lifting = hps.start_lifting
local end_lifting = hps.end_lifting
local run_lifted = hps.run_lifted
local check_lifted = hps.check_lifted
local start_lifted = hps.start_lifted
local end_lifted = hps.end_lifted

local Playa = {}


function Playa.initialize(instance)

  -- Debug
  instance.db = {downcol = 255, upcol = 255, leftcol = 255, rightcol = 255}
  instance.floorFriction = 1 -- For testing. This info will normaly ba aquired through floor collisions
  instance.floorViscosity = nil-- For testing. This info will normaly ba aquired through floor collisions

  instance.persistent = true

  instance.ids[#instance.ids+1] = "PlayaTest"
  instance.angle = 0
  instance.angvel = 0 -- angular velocity
  instance.width = ps.shapes.plshapeWidth
  instance.height = ps.shapes.plshapeHeight
  instance.x_scale = 1
  instance.y_scale = 1
  instance.iox = 0 -- drawing offsets due to item use (eg sword swing)
  instance.ioy = 0
  instance.zo = 0 -- drawing offsets due to z axis
  instance.fo = 0 -- drawing offsets due to falling
  instance.jo = 0 -- drawing offsets due to jumping
  instance.zvel = 0 -- z axis velocity
  instance.gravity = 350
  instance.image_speed = 0
  instance.mobility = 300 -- 600
  instance.brakes = 3 -- 6
  instance.maxspeed = 100
  instance.triggers = {}
  instance.sensors = {downTouchedObs={}, rightTouchedObs={}, leftTouchedObs={}, upTouchedObs={}}
  instance.missile_cooldown_limit = 0.3
  instance.item_use_counter = 0 -- Counts how long you're still while using item
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
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.sprite_info = im.spriteSettings.playerSprites
  -- instance.sprite_info.spritefixture_properties = {shape = ps.shapes.rect1x1}

  instance.player = "player1"
  instance.layer = 10
  instance.movement_state = sm.new_state_machine{
    state = "start",
    start = {
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
      -- Apply movement table
      td.walk(instance, dt)
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.movement_state.state, instance.animation_state.state
      if not instance.missile_cooldown then
        if trig.stab then
          instance.movement_state:change_state(instance, dt, "using_sword")
        elseif trig.swing_sword then
          instance.movement_state:change_state(instance, dt, "using_sword")
        elseif instance.liftingStage then
          instance.movement_state:change_state(instance, dt, "using_lift")
        elseif instance.zo == 0 then
          if trig.mark then
            instance.movement_state:change_state(instance, dt, "using_mark")
          elseif trig.recall then
            instance.movement_state:change_state(instance, dt, "using_recall")
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
      instance.item_use_duration = 0.5
    end
    },


    using_mark = {
    start_state = function(instance, dt)
      instance.movement_state:change_state(instance, dt, "using_item")
    end,

    end_state = function(instance, dt)
      instance.item_use_duration = inv.mark.time
    end
    },


    using_recall = {
    start_state = function(instance, dt)
      instance.movement_state:change_state(instance, dt, "using_item")
    end,

    end_state = function(instance, dt)
      instance.item_use_duration = inv.recall.time
    end
    },


    using_lift = {
    start_state = function(instance, dt)
      instance.movement_state:change_state(instance, dt, "using_item")
    end,

    end_state = function(instance, dt)
      instance.item_use_duration = inv.grip.time
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
      if trig.swing_sword and not otherstate:find("stab") then
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
    }
  }
  instance.animation_state = sm.new_state_machine{
    state = "start",
    start = {
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
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_walk(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/walk_down"]
    end,

    end_state = function(instance, dt)
    end
    },


    rightwalk = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_walk(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/walk_left"]
      instance.x_scale = -1
    end,

    end_state = function(instance, dt)
      instance.x_scale = 1
    end
    },


    leftwalk = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_walk(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/walk_left"]
    end,

    end_state = function(instance, dt)
    end
    },


    upwalk = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_walk(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/walk_up"]
    end,

    end_state = function(instance, dt)
    end
    },


    downhalt = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_halt(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/halt_down"]
    end,

    end_state = function(instance, dt)
    end
    },


    righthalt = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_halt(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/halt_left"]
      instance.x_scale = -1
    end,

    end_state = function(instance, dt)
      instance.x_scale = 1
    end
    },


    lefthalt = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_halt(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/halt_left"]
    end,

    end_state = function(instance, dt)
    end
    },


    uphalt = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_halt(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/halt_up"]
    end,

    end_state = function(instance, dt)
    end
    },


    downstill = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_still(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/still_down"]
    end,

    end_state = function(instance, dt)
    end
    },


    rightstill = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_still(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/still_left"]
      instance.x_scale = -1
    end,

    end_state = function(instance, dt)
      instance.x_scale = 1
    end
    },


    leftstill = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_still(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/still_left"]
    end,

    end_state = function(instance, dt)
    end
    },


    upstill = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
    end,

    check_state = function(instance, dt)
      check_still(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/still_up"]
    end,

    end_state = function(instance, dt)
    end
    },


    downpush = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      instance.image_speed = max(0.02, instance.image_speed)
    end,

    check_state = function(instance, dt)
      check_push(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/push_down"]
    end,

    end_state = function(instance, dt)
    end
    },


    rightpush = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      instance.image_speed = max(0.01, instance.image_speed)
    end,

    check_state = function(instance, dt)
      check_push(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/push_left"]
      instance.x_scale = -1
    end,

    end_state = function(instance, dt)
      instance.x_scale = 1
    end
    },


    leftpush = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      instance.image_speed = max(0.01, instance.image_speed)
    end,

    check_state = function(instance, dt)
      check_push(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/push_left"]
    end,

    end_state = function(instance, dt)
    end
    },


    uppush = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      instance.image_speed = max(0.01, instance.image_speed)
    end,

    check_state = function(instance, dt)
      check_push(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/push_up"]
    end,

    end_state = function(instance, dt)
    end
    },


    downswing = {
    run_state = function(instance, dt)
      run_swing(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_swing(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_swing(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_swing(instance, dt, "down")
    end
    },


    rightswing = {
    run_state = function(instance, dt)
      run_swing(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_swing(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_swing(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_swing(instance, dt, "right")
    end
    },


    leftswing = {
    run_state = function(instance, dt)
      run_swing(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_swing(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_swing(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_swing(instance, dt, "left")
    end
    },


    upswing = {
    run_state = function(instance, dt)
      run_swing(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_swing(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_swing(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_swing(instance, dt, "up")
    end
    },


    downstab = {
    run_state = function(instance, dt)
      run_stab(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_stab(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_stab(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_stab(instance, dt, "down")
    end
    },


    rightstab = {
    run_state = function(instance, dt)
      run_stab(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_stab(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_stab(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_stab(instance, dt, "right")
    end
    },


    leftstab = {
    run_state = function(instance, dt)
      run_stab(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_stab(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_stab(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_stab(instance, dt, "left")
    end
    },


    upstab = {
    run_state = function(instance, dt)
      run_stab(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_stab(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_stab(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_stab(instance, dt, "up")
    end
    },


    downhold = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      if instance.speed < 5 then instance.image_index = 0 end
    end,

    check_state = function(instance, dt)
      check_hold(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_hold(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
    end
    },


    righthold = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      if instance.speed < 5 then instance.image_index = 0 end
    end,

    check_state = function(instance, dt)
      check_hold(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_hold(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
      instance.x_scale = 1
    end
    },


    lefthold = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      if instance.speed < 5 then instance.image_index = 0 end
    end,

    check_state = function(instance, dt)
      check_hold(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_hold(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
    end
    },


    uphold = {
    run_state = function(instance, dt)
      td.image_speed(instance, dt)
      if instance.speed < 5 then instance.image_index = 0 end
    end,

    check_state = function(instance, dt)
      check_hold(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_hold(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
    end
    },


    downjump = {
    run_state = function(instance, dt)
    end,

    check_state = function(instance, dt)
    end,

    start_state = function(instance, dt)
      start_jump(instance, dt, "down")
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
      start_jump(instance, dt, "right")
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
      start_jump(instance, dt, "left")
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
      start_jump(instance, dt, "up")
    end,

    end_state = function(instance, dt)
    end
    },


    downfall = {
    run_state = function(instance, dt)
      run_fall(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_fall(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_fall(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_fall(instance, dt, "down")
    end
    },


    rightfall = {
    run_state = function(instance, dt)
      run_fall(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_fall(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_fall(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_fall(instance, dt, "right")
    end
    },


    leftfall = {
    run_state = function(instance, dt)
      run_fall(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_fall(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_fall(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_fall(instance, dt, "left")
    end
    },


    upfall = {
    run_state = function(instance, dt)
      run_fall(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_fall(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_fall(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_fall(instance, dt, "up")
    end
    },


    downmissile = {
    run_state = function(instance, dt)
      run_missile(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_missile(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_missile(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_missile(instance, dt, "down")
    end
    },


    rightmissile = {
    run_state = function(instance, dt)
      run_missile(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_missile(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_missile(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_missile(instance, dt, "right")
    end
    },


    leftmissile = {
    run_state = function(instance, dt)
      run_missile(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_missile(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_missile(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_missile(instance, dt, "left")
    end
    },


    upmissile = {
    run_state = function(instance, dt)
      run_missile(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_missile(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_missile(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_missile(instance, dt, "up")
    end
    },


    downgripping = {
    run_state = function(instance, dt)
      run_gripping(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_gripping(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_gripping(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_gripping(instance, dt, "down")
    end
    },


    rightgripping = {
    run_state = function(instance, dt)
      run_gripping(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_gripping(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_gripping(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_gripping(instance, dt, "right")
    end
    },


    leftgripping = {
    run_state = function(instance, dt)
      run_gripping(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_gripping(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_gripping(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_gripping(instance, dt, "left")
    end
    },


    upgripping = {
    run_state = function(instance, dt)
      run_gripping(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_gripping(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_gripping(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_gripping(instance, dt, "up")
    end
    },


    downlifting = {
    run_state = function(instance, dt)
      run_lifting(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_lifting(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_lifting(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_lifting(instance, dt, "down")
    end
    },


    rightlifting = {
    run_state = function(instance, dt)
      run_lifting(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_lifting(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_lifting(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_lifting(instance, dt, "right")
    end
    },


    leftlifting = {
    run_state = function(instance, dt)
      run_lifting(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_lifting(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_lifting(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_lifting(instance, dt, "left")
    end
    },


    uplifting = {
    run_state = function(instance, dt)
      run_lifting(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_lifting(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_lifting(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_lifting(instance, dt, "up")
    end
    },


    downlifted = {
    run_state = function(instance, dt)
      run_lifted(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_lifted(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_lifted(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_lifted(instance, dt, "down")
    end
    },


    rightlifted = {
    run_state = function(instance, dt)
      run_lifted(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_lifted(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_lifted(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_lifted(instance, dt, "right")
    end
    },


    leftlifted = {
    run_state = function(instance, dt)
      run_lifted(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_lifted(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_lifted(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_lifted(instance, dt, "left")
    end
    },


    uplifted = {
    run_state = function(instance, dt)
      run_lifted(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_lifted(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_lifted(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_lifted(instance, dt, "up")
    end
    },


    downmark = {
    run_state = function(instance, dt)
      instance.markanim = instance.markanim - dt
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
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
      instance.markanim = inv.mark.time
      instance.sprite = im.sprites["Witch/mark_down"]
    end,

    end_state = function(instance, dt)
      if instance.markanim <= 0 and not instance.onEdge then
        -- make mark
        if instance.mark then o.removeFromWorld(instance.mark) end
        instance.mark = mark:new{xstart = instance.x, ystart = instance.y, creator = instance}
        o.addToWorld(instance.mark)
      end
    end
    },


    downrecall = {
    run_state = function(instance, dt)
      instance.recallanim = instance.recallanim - dt
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
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
      instance.recallanim = inv.recall.time
      instance.sprite = im.sprites["Witch/recall_down"]
    end,

    end_state = function(instance, dt)
      if instance.recallanim <= 0 and not instance.onEdge then
        if instance.mark then
          instance.body:setPosition(instance.mark.xstart, instance.mark.ystart)
        else
        end
      else
        -- fail
      end
    end
    }
  }
end

Playa.functions = {
  update = function(self, dt)

    -- Return movement table based on the long term action you want to take (Npcs)
    -- Return movement table based on the given input (Players)
    self.input = inp.current[self.player]
    self.previnput = inp.previous[self.player]
    if self.input.start == 1 and self.previnput.start == 0 then
      game.pause(self)
    end

    -- Store usefull stuff
    local vx, vy = self.body:getLinearVelocity()
    local x, y = self.body:getPosition()
    self.speed = sqrt(vx*vx + vy*vy)
    self.vx, self.vy = vx, vy
    self.x, self.y = x, y

    -- Check if falling off edge
    if self.edgeFall then
      if self.edgeFall.step2 then
        self.fo = self.fo - self.edgeFall.height
        self.edgeFall = nil
      else
        self.body:setPosition(self.x, self.y + self.edgeFall.height)
        -- for sensorID, _ in pairs(self.sensors) do
        --   self.sensors[sensorID] = nil
        -- end
        self.edgeFall.step2 = true
      end
    end

    -- Determine triggers
    local trig = self.triggers
    self.angle = self.angle + dt*self.angvel
    while self.angle >= math.pi do
      self.angle = self.angle - math.pi
      trig.full_rotation = true
    end
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
      if frames > 1 then trig.animation_end = true end
    end
    td.determine_animation_triggers(self, dt)
    inv.determine_equipment_triggers(self, dt)
    self.jo = self.jo - self.zvel * dt
    if self.jo >= 0 then
      self.jo = 0
      self.fo = self.fo - self.zvel * dt
      if self.fo >= 0 then
        self.fo = 0
        self.zvel = 0
      else
        self.zvel = self.zvel - self.gravity * dt
      end
    else
      self.zvel = self.zvel - self.gravity * dt
    end
    self.zo = self.jo + self.fo
    if self.zo < 0 then
      if not self.shadow then
        self.shadow = sh:new{
          caster = self, layer = self.layer-1,
          xstart = x, ystart = y, playershadow = true
        }
        o.addToWorld(self.shadow)
      end
    else
      if self.shadow then o.removeFromWorld(self.shadow) end
      self.shadow = nil
    end

    local ms = self.movement_state
    -- Check movement state
    ms[ms.state].check_state(self, dt)
    -- Run movement state
    ms[ms.state].run_state(self, dt)

    local as = self.animation_state
    -- Check animation state
    as[as.state].check_state(self, dt)
    -- Run animation state
    as[as.state].run_state(self, dt)

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

    -- Turn off triggers
    triggersdebug = {}
    for trigger, _ in pairs(self.triggers) do
      if self.triggers[trigger] then triggersdebug[trigger] = true end
      self.triggers[trigger] = false
    end

  end,

  draw = function(self)
    local x, y = self.x, self.y
    local xtotal, ytotal = x + self.iox, y + self.ioy + self.zo

    if self.spritejoint then self.spritejoint:destroy() end
    self.spritebody:setPosition(xtotal, ytotal)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    -- if self.zo ~= 0 then
    --   local shaspri = self.shadownSprite
    --   love.graphics.draw(
    --   shaspri.img, shaspri[0], x, y, 0,
    --   shaspri.res_x_scale, shaspri.res_y_scale,
    --   shaspri.cx, shaspri.cy)
    -- end

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    --
    -- love.graphics.setColor(COLORCONST, self.db.downcol, self.db.downcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.upcol, self.db.upcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.leftcol, self.db.leftcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.rightcol, self.db.rightcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  end,

  trans_draw = function(self)

    local x, y = self.x, self.y

    -- x, y modifications because of transition
    x = x + trans.xtransform - game.transitioning.progress * trans.xadjust
    y = y + trans.ytransform - game.transitioning.progress * trans.yadjust

    local xtotal, ytotal = x + self.iox, y + self.ioy + self.zo

    -- destroy joint to avoid funkyness during transition
    if self.spritejoint then
      self.spritejoint:destroy();
      self.spritejoint = nil
    end

    -- if self.zo ~= 0 then
    --   local shaspri = self.shadownSprite
    --   love.graphics.draw(
    --   shaspri.img, shaspri[0], x, y, 0,
    --   shaspri.res_x_scale, shaspri.res_y_scale,
    --   shaspri.cx, shaspri.cy)
    -- end

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    --
    -- love.graphics.setColor(COLORCONST, self.db.downcol, self.db.downcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.upcol, self.db.upcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.leftcol, self.db.leftcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, self.db.rightcol, self.db.rightcol, COLORCONST)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
    -- love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
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
      local sensorID = myF:getUserData() -- string

      if sensorID then
        if not other.unpushable == true then
          local onEdge
          if other.edge then
            other.onEdge = ec.isOnEdge(other, self)
          end
          if not other.onEdge then
            local sensors = self.sensors
            sensors[sensorID] = sensors[sensorID] or 0
            sensors[sensorID] = sensors[sensorID] + 1
            insert(sensors[sensorID .. "edObs"], other)
          end
        end
      end

    else
      -- Remember if I'm on an edge
      if other.edge then self.onEdge = true end
    end

  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      local sensorID = myF:getUserData()

      if sensorID then
        if not other.unpushable == true then
          local sensors = self.sensors

          for i, touchedOb in ipairs(sensors[sensorID .. "edObs"]) do
            if touchedOb == other then remove(sensors[sensorID .. "edObs"], i) end
          end

          if not other.onEdge then
            if sensors[sensorID] then
              sensors[sensorID] = sensors[sensorID] - 1
              if sensors[sensorID] == 0 then sensors[sensorID] = nil end
            end
          end

        end
      end

    else
      -- Remember if I'm on an edge
      if other.edge then self.onEdge = false end
    end

  end,

  preSolve = function(self, a, b, coll)
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
