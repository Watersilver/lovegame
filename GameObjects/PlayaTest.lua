local ps = require "physics_settings"
local im = require "image"
local inp = require "input"
local inv = require "inventory"
local p = require "GameObjects.prototype"
local sw = require "GameObjects.Items.sword"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"

local sqrt = math.sqrt
local floor = math.floor
local choose = u.choose
local max = math.max

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
      if trig.swing_sword then
        instance.movement_state:change_state(instance, dt, "using_item")
      end
    end,

    start_state = function(instance, dt)
    end,

    end_state = function(instance, dt)
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
        instance.movement_state:change_state(instance, dt, "using_item")
      elseif instance.item_use_counter > 0.5 then
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "down") then
      elseif td.check_push_a(instance, trig, "down") then
      elseif td.check_walk_while_walking(instance, trig, "down") then
      elseif td.check_halt_a(instance, trig, "down") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "downstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "right") then
      elseif td.check_push_a(instance, trig, "right") then
      elseif td.check_walk_while_walking(instance, trig, "right") then
      elseif td.check_halt_a(instance, trig, "right") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "rightstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "left") then
      elseif td.check_push_a(instance, trig, "left") then
      elseif td.check_walk_while_walking(instance, trig, "left") then
      elseif td.check_halt_a(instance, trig, "left") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "leftstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "up") then
      elseif td.check_push_a(instance, trig, "up") then
      elseif td.check_walk_while_walking(instance, trig, "up") then
      elseif td.check_halt_a(instance, trig, "up") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "upstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "down") then
      elseif td.check_push_a(instance, trig, "down") then
      elseif td.check_walk_a(instance, trig, "down") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "downstill")
      elseif td.check_halt_notme(instance, trig, "down") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "right") then
      elseif td.check_push_a(instance, trig, "right") then
      elseif td.check_walk_a(instance, trig, "right") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "rightstill")
      elseif td.check_halt_notme(instance, trig, "right") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "left") then
      elseif td.check_push_a(instance, trig, "left") then
      elseif td.check_walk_a(instance, trig, "left") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "leftstill")
      elseif td.check_halt_notme(instance, trig, "left") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "up") then
      elseif td.check_push_a(instance, trig, "up") then
      elseif td.check_walk_a(instance, trig, "up") then
      elseif trig.restish then
        instance.animation_state:change_state(instance, dt, "upstill")
      elseif td.check_halt_notme(instance, trig, "up") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "down") then
      elseif td.check_push_a(instance, trig, "down") then
      elseif td.check_walk_a(instance, trig, "down") then
      elseif td.check_halt_a(instance, trig, "down") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "right") then
      elseif td.check_push_a(instance, trig, "right") then
      elseif td.check_walk_a(instance, trig, "right") then
      elseif td.check_halt_a(instance, trig, "right") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "left") then
      elseif td.check_push_a(instance, trig, "left") then
      elseif td.check_walk_a(instance, trig, "left") then
      elseif td.check_halt_a(instance, trig, "left") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "up") then
      elseif td.check_push_a(instance, trig, "up") then
      elseif td.check_walk_a(instance, trig, "up") then
      elseif td.check_halt_a(instance, trig, "up") then
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "down") then
      elseif not trig.push_down then
        instance.animation_state:change_state(instance, dt, "downstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "right") then
      elseif not trig.push_right then
        instance.animation_state:change_state(instance, dt, "rightstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "left") then
      elseif not trig.push_left then
        instance.animation_state:change_state(instance, dt, "leftstill")
      end
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
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if inv.check_use(instance, trig, "up") then
      elseif not trig.push_up then
        instance.animation_state:change_state(instance, dt, "upstill")
      end
    end,

    start_state = function(instance, dt)
      instance.sprite = im.sprites["Witch/push_up"]
    end,

    end_state = function(instance, dt)
    end
    },


    downswing = {
    run_state = function(instance, dt)
      local trig = instance.triggers

      -- Manage position offset and image speed
      if trig.animation_end then
        instance.image_speed = 0
        instance.image_index = 1.99
      else
        inv.sword.image_offset(instance, dt, "down")
      end
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
        instance.animation_state:change_state(instance, dt, "downswing")
      elseif otherstate == "normal" then
        instance.animation_state:change_state(instance, dt, "downstill")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.20
      instance.triggers.animation_end = false
      instance.sprite = im.sprites["Witch/swing_down"]
      -- Create sword
      instance.sword = sw:new{creator = instance, side = "down", layer = instance.layer}
      o.addToWorld(instance.sword)
    end,

    end_state = function(instance, dt)
      instance.ioy, instance.iox = 0, 0
      instance.image_index = 0
      instance.image_speed = 0
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
    end
    },


    rightswing = {
    run_state = function(instance, dt)
      local trig = instance.triggers

      -- Manage position offset and image speed
      if trig.animation_end then
        instance.image_speed = 0
        instance.image_index = 1.99
      else
        inv.sword.image_offset(instance, dt, "right")
      end
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
        instance.animation_state:change_state(instance, dt, "rightswing")
      elseif otherstate == "normal" then
        instance.animation_state:change_state(instance, dt, "rightstill")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.20
      instance.triggers.animation_end = false
      instance.sprite = im.sprites["Witch/swing_left"]
      -- Create sword
      instance.sword = sw:new{creator = instance, side = "right", layer = instance.layer}
      o.addToWorld(instance.sword)

      instance.x_scale = -1
    end,

    end_state = function(instance, dt)
      instance.ioy, instance.iox = 0, 0
      instance.image_index = 0
      instance.image_speed = 0
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil

      instance.x_scale = 1
    end
    },


    leftswing = {
    run_state = function(instance, dt)
      local trig = instance.triggers

      -- Manage position offset and image speed
      if trig.animation_end then
        instance.image_speed = 0
        instance.image_index = 1.99
      else
        inv.sword.image_offset(instance, dt, "left")
      end
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
        instance.animation_state:change_state(instance, dt, "leftswing")
      elseif otherstate == "normal" then
        instance.animation_state:change_state(instance, dt, "leftstill")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.20
      instance.triggers.animation_end = false
      instance.sprite = im.sprites["Witch/swing_left"]
      -- Create sword
      instance.sword = sw:new{creator = instance, side = "left", layer = instance.layer}
      o.addToWorld(instance.sword)
    end,

    end_state = function(instance, dt)
      instance.ioy, instance.iox = 0, 0
      instance.image_index = 0
      instance.image_speed = 0
      -- Delete sword
      o.removeFromWorld(instance.sword)
      instance.sword = nil
    end
    },


    upswing = {
    run_state = function(instance, dt)
      local trig = instance.triggers

      -- Manage position offset and image speed
      if trig.animation_end then
        instance.image_speed = 0
        instance.image_index = 1.99
      else
        inv.sword.image_offset(instance, dt, "up")
      end
    end,

    check_state = function(instance, dt)
      local trig, state, otherstate = instance.triggers, instance.animation_state.state, instance.movement_state.state
      if trig.swing_sword then
        instance.animation_state:change_state(instance, dt, "upswing")
      elseif otherstate == "normal" then
        instance.animation_state:change_state(instance, dt, "upstill")
      end
    end,

    start_state = function(instance, dt)
      instance.image_index = 0
      instance.image_speed = 0.20
      instance.triggers.animation_end = false
      instance.sprite = im.sprites["Witch/swing_up"]
      -- Create sword
      instance.sword = sw:new{creator = instance, side = "up", layer = instance.layer}
      o.addToWorld(instance.sword)
    end,

    end_state = function(instance, dt)
      instance.ioy, instance.iox = 0, 0
      instance.image_index = 0
      instance.image_speed = 0
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
