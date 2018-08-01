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
local hps = require "GameObjects.Helpers.player_states"

local sw = require "GameObjects.Items.sword"
local hsw = require "GameObjects.Items.held_sword"

local sqrt = math.sqrt
local floor = math.floor
local choose = u.choose
local max = math.max

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

local Playa = {}


function Playa.initialize(instance)

  -- Debug
  instance.db = {downcol = 255, upcol = 255, leftcol = 255, rightcol = 255}
  instance.floorFriction = 1 -- For testing. This info will normaly ba aquired through floor collisions
  instance.floorViscosity = nil -- For testing. This info will normaly ba aquired through floor collisions

  instance.ids[#instance.ids+1] = "PlayaTest"
  instance.angle = 0
  instance.angvel = 0 -- angular velocity
  instance.x_scale = 1
  instance.y_scale = 1
  instance.iox = 0 -- drawing offsets dou to item use (eg sword swing)
  instance.ioy = 0
  instance.image_speed = 0
  instance.mobility = 300 -- 600
  instance.breaks = 3 -- 6
  instance.maxspeed = 100
  instance.triggers = {}
  instance.sensors = {}
  instance.item_use_counter = 0 -- Counts how long you're still while using item
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    density = 160, --160 is 50 kg when combined with lowr1x1 dimensions(w 10, h 8)
    shape = ps.shapes.plshape,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0,
    downSensor = ps.shapes.pldsens,
    upSensor = ps.shapes.plusens,
    leftSensor = ps.shapes.pllsens,
    rightSensor = ps.shapes.plrsens,
    masks = {PLAYERATTACKCAT}
  }
  instance.sprite_info = {
    {'Witch/walk_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/walk_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/walk_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/halt_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/halt_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/halt_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/swing_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/swing_left', 2, padding = 2, width = 16, height = 16},
    {'Witch/swing_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/hold_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/hold_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/hold_down', 4, padding = 2, width = 16, height = 16},
    {'GuyWalk', 4, width = 16, height = 16},
    {'Test', 1, padding = 0},
    {'Plrun_strip12', 12, padding = 0, width = 16, height = 16},
    spritefixture_properties = {
      shape = ps.shapes.rect1x1
    }
  }
  instance.player = "player1"
  instance.layer = 3
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
      if trig.stab then
        instance.movement_state:change_state(instance, dt, "using_sword")
      elseif trig.swing_sword then
        instance.movement_state:change_state(instance, dt, "using_sword")
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


    using_item = {
    run_state = function(instance, dt)
      -- Apply movement table
      td.stand_still(instance, dt)
      instance.item_use_counter = instance.item_use_counter + 1*dt
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.movement_state.state, instance.animation_state.state
      if trig.swing_sword then
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
      instance.image_speed = 0
      instance.image_index = 0
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
    self.speed = sqrt(vx*vx + vy*vy)
    self.vx, self.vy = vx, vy

    -- Determine triggers
    self.angle = self.angle + dt*self.angvel
    while self.angle >= math.pi do
      self.angle = self.angle - math.pi
      self.triggers.full_rotation = true
    end
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
      if frames > 1 then self.triggers.animation_end = true end
    end
    td.determine_animation_triggers(self, dt)
    inv.determine_equipment_triggers(self, dt)

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
    local x, y = self.body:getPosition()
    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x + self.iox, y + self.ioy, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.spritefixture:getShape():getPoints()))
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
  end,

  beginContact = function(self, a, b, coll, aob)
    -- Find which fixture belongs to whom
    local myF
    local otherF
    if self == aob then
      myF = a
      otherF = b
    else
      myF = b
      otherF = a
    end

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      local sensor = myF:getUserData()

      if sensor then
        local sensors = self.sensors
        if not otherF:getUserData() ~= "unpushable" then
          sensors[sensor] = sensors[sensor] or 0
          sensors[sensor] = sensors[sensor] + 1
        end
      end

    end
  end,

  endContact = function(self, a, b, coll, aob)
    -- Find which fixture belongs to whom
    local myF
    local otherF
    if self == aob then
      myF = a
      otherF = b
    else
      myF = b
      otherF = a
    end

    -- If my fixture is sensor, add to a sensor named after its user data
    if myF:isSensor() then
      local sensor = myF:getUserData()

      if sensor then
        if not otherF:getUserData() ~= "unpushable" then
          local sensors = self.sensors
          sensors[sensor] = sensors[sensor] - 1
          if sensors[sensor] == 0 then sensors[sensor] = nil end
        end
      end

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
