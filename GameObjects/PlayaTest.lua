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

local hps = require "GameObjects.Helpers.player_states"
local ors = require "GameObjects.Helpers.object_read_save"
local dc = require "GameObjects.Helpers.determine_colliders"
local ec = require "GameObjects.Helpers.edge_collisions"
local sg = require "GameObjects.Helpers.set_ghost"
local asp = require "GameObjects.Helpers.add_spell"
local pddp = require "GameObjects.Helpers.triggerCheck"; pddp = pddp.playerDieDrownPlummet

local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"
local mark = require "GameObjects.Items.mark"

local sh = require "GameObjects.shadow"

local go = require "GameObjects.gameOver"

local hitShader = shdrs.playerHitShader

local sqrt = math.sqrt
local floor = math.floor
local choose = u.choose
local push = u.push
local distanceSqared2d = u.distanceSqared2d
local insert = table.insert
local remove = table.remove
local max = math.max
local min = math.min
local abs = math.abs

local pi = math.pi
local huge = math.huge

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
local run_damaged = hps.run_damaged
local check_damaged = hps.check_damaged
local start_damaged = hps.start_damaged
local end_damaged = hps.end_damaged
local run_climbing = hps.run_climbing
local check_climbing = hps.check_climbing
local start_climbing = hps.start_climbing
local end_climbing = hps.end_climbing
local img_speed_and_footstep_sound = hps.img_speed_and_footstep_sound

local Playa = {}


function Playa.initialize(instance)

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
  instance.zoPrev = instance.zo
  instance.fo = 0 -- drawing offsets due to falling
  instance.jo = 0 -- drawing offsets due to jumping
  instance.zvel = 0 -- z axis velocity
  instance.gravity = 350
  instance.image_speed = 0
  instance.image_index = 0
  instance.image_index_prev = 0
  instance.brakesLim = 10
  instance.health = instance.maxHealth or 3
  instance.input = {}
  instance.previnput = {}
  instance.triggers = {}
  instance.sensors = {downTouchedObs={}, rightTouchedObs={}, leftTouchedObs={}, upTouchedObs={}}
  instance.missile_cooldown_limit = 0.3
  instance.item_use_counter = 0 -- Counts how long you're still while using item
  instance.currentMasks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
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
  instance.sounds = snd.load_sounds({
    swordSlash1 = {"Effects/Oracle_Sword_Slash1"},
    swordSlash2 = {"Effects/Oracle_Sword_Slash2"},
    swordSlash3 = {"Effects/Oracle_Sword_Slash3"},
    swordTap1 = {"Effects/Oracle_Sword_Tap"},
    swordTap2 = {"Effects/Oracle_Shield_Deflect"},
    jump = {"Effects/Oracle_Link_Jump"},
    land = {"Effects/Oracle_Link_LandRun"},
    magicMissile = {"Effects/Magic_Missile"},
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
  })
  instance.floorTiles = {role = "playerFloorTilesIndex"} -- Tracks what kind of floortiles I'm on
  instance.player = "player1"
  inp.controllers[instance.player].disabled = nil
  instance.layer = 20
  instance.movement_state = sm.new_state_machine{
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
      -- Apply movement table
      td.walk(instance, dt)
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.movement_state.state, instance.animation_state.state
      if not instance.missile_cooldown then
        if not instance.liftState then
          if not instance.climbing then

            if trig.stab then
              instance.movement_state:change_state(instance, dt, "using_sword")
            elseif trig.swing_sword then
              instance.movement_state:change_state(instance, dt, "using_sword")
            elseif instance.zo == 0 then
              if trig.mark then
                instance.movement_state:change_state(instance, dt, "using_mark")
              elseif trig.recall then
                instance.movement_state:change_state(instance, dt, "using_recall")
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
      if trig.swing_sword and not otherstate:find("stab") and not instance.liftState then
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      if instance.inShallowWater then snd.play(instance.sounds.water) end
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
      if instance.inShallowWater then snd.play(instance.sounds.water) end
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
      if instance.inShallowWater then snd.play(instance.sounds.water) end
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
      if instance.inShallowWater then snd.play(instance.sounds.water) end
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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
      img_speed_and_footstep_sound(instance, dt)
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


    downdamaged = {
    run_state = function(instance, dt)
      run_damaged(instance, dt, "down")
    end,

    check_state = function(instance, dt)
      check_damaged(instance, dt, "down")
    end,

    start_state = function(instance, dt)
      start_damaged(instance, dt, "down")
    end,

    end_state = function(instance, dt)
      end_damaged(instance, dt, "down")
    end
    },


    rightdamaged = {
    run_state = function(instance, dt)
      run_damaged(instance, dt, "right")
    end,

    check_state = function(instance, dt)
      check_damaged(instance, dt, "right")
    end,

    start_state = function(instance, dt)
      start_damaged(instance, dt, "right")
    end,

    end_state = function(instance, dt)
      end_damaged(instance, dt, "right")
    end
    },


    leftdamaged = {
    run_state = function(instance, dt)
      run_damaged(instance, dt, "left")
    end,

    check_state = function(instance, dt)
      check_damaged(instance, dt, "left")
    end,

    start_state = function(instance, dt)
      start_damaged(instance, dt, "left")
    end,

    end_state = function(instance, dt)
      end_damaged(instance, dt, "left")
    end
    },


    updamaged = {
    run_state = function(instance, dt)
      run_damaged(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_damaged(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_damaged(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_damaged(instance, dt, "up")
    end
    },


    downmark = {
    run_state = function(instance, dt)
      instance.markanim = instance.markanim - dt
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if pddp(instance, trig, side) then
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
      instance.markanim = inv.mark.time
      instance.sprite = im.sprites["Witch/mark_down"]
      snd.play(instance.sounds.markStart)
    end,

    end_state = function(instance, dt)
      if instance.markanim <= 0 and not instance.onEdge then
        -- make mark
        if instance.mark then o.removeFromWorld(instance.mark) end
        instance.sounds.markStart:stop()
        snd.play(instance.sounds.mark)
        instance.mark = mark:new{xstart = instance.x, ystart = instance.y, creator = instance, layer = instance.layer - 1}
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
      if pddp(instance, trig, side) then
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
      instance.recallanim = inv.recall.time
      instance.sprite = im.sprites["Witch/recall_down"]
      snd.play(instance.sounds.recallStart)
    end,

    end_state = function(instance, dt)
      if instance.recallanim <= 0 and not instance.onEdge then
        if instance.mark then
          instance.sounds.recallStart:stop()
          snd.play(instance.sounds.recall)
          instance.body:setPosition(instance.mark.xstart, instance.mark.ystart)
        else
          -- fail
        end
      else
        -- fail
      end
    end
    },


    upclimbing = {
    run_state = function(instance, dt)
      run_climbing(instance, dt, "up")
    end,

    check_state = function(instance, dt)
      check_climbing(instance, dt, "up")
    end,

    start_state = function(instance, dt)
      start_climbing(instance, dt, "up")
    end,

    end_state = function(instance, dt)
      end_climbing(instance, dt, "up")
    end
    },


    downdrown = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.animation_end then
        instance.animation_state:change_state(instance, dt, "respawn")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.1
      instance.xUnsteppable = instance.x
      instance.yUnsteppable = instance.y
      -- Ensure you're not jumping while drowning
      instance.jo = 0
      instance.fo = 0
      instance.zvel = 0
      instance.sprite = im.sprites["Witch/drown_down"]
      inp.controllers[instance.player].disabled = true
      snd.play(instance.sounds.water)
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0
      inp.controllers[instance.player].disabled = nil
      instance:setGhost(false)
      instance.health = instance.health - 1
    end
    },


    plummet = {
    run_state = function(instance, dt)
      local pmod = instance.image_index
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
      instance.xPlummetStart = instance.x
      instance.yPlummetStart = instance.y
      instance.plummetFrames = instance.sprite.frames
      instance.image_index = 0
      instance.image_speed = 0.1
      inp.controllers[instance.player].disabled = true
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
      instance.xUnsteppable = instance.x
      instance.yUnsteppable = instance.y
      inp.controllers[instance.player].disabled = nil
      instance:setGhost(false)
      instance.health = instance.health - 1
    end
    },


    respawn = {
    run_state = function(instance, dt)
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
      instance.respawnCounter = 0
      instance.respawnCounterMax = 0.4
      instance.invisible = true
      inp.controllers[instance.player].disabled = true
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
      instance.body:setPosition(instance.xLastSteppable, instance.yLastSteppable)
      instance.invisible = false
      inp.controllers[instance.player].disabled = nil
      instance:setGhost(false)
      instance.invulnerable = 1
    end
    },


    downdie = {
    run_state = function(instance, dt)
      if instance.deathPhase == 1 then
        if instance.image_index >= 3 then
          instance.image_index = 2
          instance.image_speed = - instance.image_speed
          instance.deathDizzinesCounter = instance.deathDizzinesCounter + 1
        elseif instance.image_index <= 0 then
          instance.image_index = 1
          instance.image_speed = - instance.image_speed
          instance.deathDizzinesCounter = instance.deathDizzinesCounter + 1
          instance.x_scale = - instance.x_scale
          if instance.deathDizzinesCounter >= instance.deathDizzinesRepeats then
            instance.deathPhase = 2
            instance.image_speed = 0.1
            instance.image_index = 1
            instance.deathDizzinesCounter = 0
          end
        end
      elseif instance.deathPhase == 2 then
        if instance.image_index >= 2 then
          instance.image_index = 1
          instance.image_speed = - instance.image_speed
          instance.deathDizzinesCounter = instance.deathDizzinesCounter + 1
        elseif instance.image_index <= 0 then
          instance.image_index = 1
          instance.image_speed = - instance.image_speed
          instance.deathDizzinesCounter = instance.deathDizzinesCounter + 1
          instance.x_scale = - instance.x_scale
          if instance.deathDizzinesCounter >= instance.deathDizzinesFastRepeats then
            instance.deathPhase = 3
            instance.image_speed = 0
            instance.image_index = 0
            instance.x_scale = 1
            snd.play(instance.sounds.die)
          end
        end
      elseif instance.deathPhase == 3 then
        instance.deathFallCounter = instance.deathFallCounter + dt
        if instance.deathFallCounter > 0 then
          instance.deathFallCounter = 0
          instance.image_index = 6
          instance.deathPhase = 4
        end
      elseif instance.deathPhase == 4 then
        instance.deathFallCounter = instance.deathFallCounter + dt
        if instance.deathFallCounter > 0.4 then
          instance.deathFallCounter = 0
          instance.deathPhase = 5
          o.addToWorld(go:new{player = instance})
        end
        instance.ioy = instance.ioyDeathStart + math.sin(instance.deathFallCounter * 10)
      end
    end,

    check_state = function(instance, dt)
    end,

    start_state = function(instance, dt)
      snd.bgm:setFadeState("fadeout")
      snd.play(instance.sounds.dying)
      instance.sprite = im.sprites["Witch/die"]
      inp.controllers[instance.player].disabled = true
      instance.deathPhase = 1
      instance.image_index = 0
      instance.image_speed = 0.1
      instance.deathDizzinesCounter = 0
      instance.deathDizzinesRepeats = 6
      instance.deathDizzinesFastRepeats = 4
      instance.deathFallCounter = 0
      instance.ioyDeathStart = instance.ioy
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
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
      inp.controllers[instance.player].disabled = true
      instance:setGhost(true)
    end,

    end_state = function(instance, dt)
      if instance.dontdrawEnd then instance:dontdrawEnd(dt) end
      dontdrawRun = nil
      dontdrawCheck = nil
      dontdrawStart = nil
      dontdrawEnd = nil
      instance.invisible = false
      inp.controllers[instance.player].disabled = nil
      instance:setGhost(false)
    end
    }
  }
end

Playa.functions = {
  update = function(self, dt)
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
      local previousClosestDistance
      for _, floorTile in ipairs(self.floorTiles) do
        previousClosestDistance = closestDistance
        -- Magic number to account for player height
        closestDistance = min(distanceSqared2d(x, y+6, floorTile.xstart, floorTile.ystart), closestDistance)
        if closestDistance < previousClosestDistance then
          closestTile = floorTile
        end
      end

      self.xClosestTile = closestTile.xstart
      self.yClosestTile = closestTile.ystart

      self.floorFriction = closestTile.floorFriction
      self.floorViscosity = closestTile.floorViscosity
      if closestTile.grass then
        if self.zo == 0 then
          self.ongrass = im.sprites[closestTile.grass]
        end
      elseif closestTile.shallowWater then
        if self.zo == 0 then
          self.inShallowWater = im.sprites[closestTile.shallowWater]
          self.landedTileSound = "water"
        end
      elseif closestTile.water then
        if self.zo == 0 then
          if self.walkOnWater then
            self.inShallowWater = im.sprites[closestTile.water]
            self.landedTileSound = "water"
          else
            self.inDeepWater = true
            self.landedTileSound = "none"
          end
        end
      elseif closestTile.gap then
        if self.zo == 0 then
          self.overGap = true
          self.landedTileSound = "none"
        end
      end
      if closestTile.climbable and self.zo == 0 then self.climbing = true else self.climbing = nil end
      -- Where to respawn if I fall in a gap or drown
      if not closestTile.unsteppable then
        self.xLastSteppable = closestTile.xstart
        self.yLastSteppable = closestTile.ystart - 2
      end
      self.closestTile = closestTile
    else
      self.floorFriction = 1
      self.floorViscosity = nil
      self.climbing = nil
    end

    if self.zo == 0 and self.inShallowWater and not self.inShallowWaterPrev then
      snd.play(self.sounds.water)
    end

    -- Return movement table based on the long term action you want to take (Npcs)
    -- Return movement table based on the given input (Players)
    self.input = inp.current[self.player]
    self.previnput = inp.previous[self.player]
    if self.input.start == 1 and self.previnput.start == 0 then
      game.pause(self)
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
          if other.activate and not other.unactivatable then
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
    if self.health <= 0 then
      trig.noHealth = true
    else
      -- Decrease invulnerablity counter
      -- It's here because it's only relevant if I'm alive
      if self.invulnerable then
        self.invulnerable = self.invulnerable - dt
        if floor(7 * self.invulnerable % 2) == 1 then
          trig.enableHitShader = true
        end
        if self.invulnerable < 0 then
          self.invulnerable = nil
        end
      end
    end
    trig.land = (self.zo ~= self.zoPrev) and (self.zo == 0)
    self.zoPrev = self.zo
    td.determine_animation_triggers(self, dt)
    inv.determine_equipment_triggers(self, dt)

    -- Determine z axis offset
    td.zAxisPlayer(self, dt)

    sh.handleShadow(self, true)

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

    -- Check if landing sound should be played
    if trig.land and self.landedTileSound ~= "none" then
      snd.play(self.sounds[self.landedTileSound])
    end

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

    -- set Shader
    if trig.enableHitShader then
      self.playerShader = hitShader
    else
      self.playerShader = nil
    end

    -- Turn off triggers
    triggersdebug = {}
    for trigger, _ in pairs(self.triggers) do
      if self.triggers[trigger] then triggersdebug[trigger] = true end
      self.triggers[trigger] = false
    end

  end,

  draw = function(self)
    if self.invisible then return end

    local x, y = self.x, self.y
    local xtotal, ytotal = x + self.iox, y + self.ioy + self.zo

    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
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
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.playerShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)

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
    if self.animation_state.state == "dontdraw" then return end

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
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.playerShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)

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
        local sensors = self.sensors
        if not other.unpushable then
          local onEdge
          if other.edge then
            other.onEdge = ec.isOnEdge(other, self)
          end
          if not other.onEdge then
            -- local sensors = self.sensors
            sensors[sensorID] = sensors[sensorID] or 0
            sensors[sensorID] = sensors[sensorID] + 1
            -- insert(sensors[sensorID .. "edObs"], other)
          end
        end
        insert(sensors[sensorID .. "edObs"], other)
      end

    else
      -- Remember if I'm on an edge
      if other.edge then self.onEdge = true end

      -- Remember Floor tiles
      if other.floor then
        other.playerFloorTilesIndex = push(self.floorTiles, other)
      end
    end

  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      local sensorID = myF:getUserData()

      if sensorID then
        local sensors = self.sensors
        if not other.unpushable == true then
          -- local sensors = self.sensors

          -- for i, touchedOb in ipairs(sensors[sensorID .. "edObs"]) do
          --   if touchedOb == other then remove(sensors[sensorID .. "edObs"], i) end
          -- end

          if not other.onEdge then
            if sensors[sensorID] then
              sensors[sensorID] = sensors[sensorID] - 1
              if sensors[sensorID] == 0 then sensors[sensorID] = nil end
            end
          end

        end
        for i, touchedOb in ipairs(sensors[sensorID .. "edObs"]) do
          if touchedOb == other then remove(sensors[sensorID .. "edObs"], i) end
        end
      end

    else
      -- Remember if I'm on an edge
      if other.edge then self.onEdge = false end

      -- Forget Floor tiles
      if other.floor then
        u.free(self.floorTiles, other.playerFloorTilesIndex)
        other.playerFloorTilesIndex = nil
      end
    end

  end,

  preSolve = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if other.floor then coll:setEnabled(false) return end
    if not myF:isSensor() then
      -- jump over stuff on ground
      if other.grounded then
        if self.zo < 0 then coll:setEnabled(false); return end
      end
      if other.damager and not self.invulnerable and not other.harmless then
        self.triggers.damaged = true
        local mybod = self.body
        local mymass = mybod:getMass()
        local lvx, lvy = mybod:getLinearVelocity()
        mybod:applyLinearImpulse(-lvx * mymass, -lvy * mymass)
        local impdirx, impdiry =
          u.normalize2d(self.x - other.x or self.x, self.y - other.y or self.y)
        local clbrakes = u.clamp(0, self.brakes, self.brakesLim)
        local ipct = other.impact or 10
        mybod:applyLinearImpulse(impdirx*ipct*clbrakes*mymass, impdiry*ipct*clbrakes*mymass)
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
