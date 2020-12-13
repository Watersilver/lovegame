local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local inp = require "input"
local im = require "image"
local snd = require "sound"
local sm = require "state_machine"
local game = require "game"

local Cutscene = {}

local states = {
  state = "start",
  start = {
  run_state = function(instance, dt)
  end,
  start_state = function(instance, dt)
  end,
  check_state = function(instance, dt)
    if true then
      instance.state_machine:change_state(instance, dt, "wakingup")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  wakingup = {
  run_state = function(instance, dt)
    instance.stateTimer = instance.stateTimer - dt
    instance.playa.x = 56
    instance.playa.y = 41
    if instance.stateTimer < 0 then
      instance.playa.image_index = 1
      game.timeScreenEffect = "fullLight"
    end
  end,
  start_state = function(instance, dt)
    instance.playa = o.identified.PlayaTest[1]
    local pl = instance.playa
    pl.animation_state:change_state(pl, "noDt", "cutscene")
    pl.sprite = im.sprites["Witch/sleeping_down"]
    pl.image_index = 0
    pl.image_speed = 0
    pl.x = 56
    pl.y = 41
    instance.rescuer = o.identified.rescuer[1]
    instance.stateTimer = 4
  end,
  check_state = function(instance, dt)
    if instance.stateTimer < 0 then
      instance.state_machine:change_state(instance, dt, "gettingnoticed")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  gettingnoticed = {
  run_state = function(instance, dt)
    instance.stateTimer = instance.stateTimer - dt

    if instance.stateIndex < 1 then
      if instance.stateTimer < 0 then
        instance.stateTimer = 0.6
        instance.stateIndex = 1
        instance.rescuer:turn("left")
        instance.rescuer.zvel = 60
        instance.rescuer.image_speed = 0
        instance.rescuer.image_index = 0
        snd.play(glsounds.enemyJump)
      end
    end
  end,
  start_state = function(instance, dt)
    instance.stateTimer = 1
    instance.stateIndex = 0
  end,
  check_state = function(instance, dt)
    if instance.stateIndex > 0 and instance.stateTimer < 0 then
      instance.state_machine:change_state(instance, dt, "rescuerWalking")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  rescuerWalking = {
  run_state = function(instance, dt)
    if instance.stateIndex == 0 then
      instance.rescuer.x = instance.rescuer.x - dt * 25
      if instance.rescuer.x < 88 then
        instance.rescuer.x = 88
        instance.rescuer:turn("up")
        instance.stateIndex = 1
      end
    elseif instance.stateIndex == 1 then
      instance.rescuer.y = instance.rescuer.y - dt * 25
      if instance.rescuer.y < 48 then
        instance.rescuer.y = 48
        instance.rescuer:turn("left")
        instance.stateIndex = 2
      end
    elseif instance.stateIndex == 2 then
      instance.rescuer.x = instance.rescuer.x - dt * 25
      if instance.rescuer.x < 76 then
        instance.rescuer.x = 76
        instance.stateIndex = 3
        instance.rescuer.image_speed = 0.05
      end
    end
  end,
  start_state = function(instance, dt)
    instance.stateIndex = 0
    instance.rescuer.image_speed = 0.1
    instance.rescuer:turn("left")
  end,
  check_state = function(instance, dt)
    if instance.rescuer.dlgState == "mute" then
      instance.state_machine:change_state(instance, dt, "rescuerMovingAway")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  rescuerMovingAway = {
  run_state = function(instance, dt)
    instance.rescuer.x = instance.rescuer.x + dt * 7
    if instance.rescuer.x > 88 then
      instance.rescuer.x = 88
      instance.timer = instance.timer - dt
    end
  end,
  start_state = function(instance, dt)
    instance.timer = 1
  end,
  check_state = function(instance, dt)
    if instance.timer < 0 then
      instance.state_machine:change_state(instance, dt, "readyToLeave")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  readyToLeave = {
  run_state = function(instance, dt)
  end,
  start_state = function(instance, dt)
    local cc = COLORCONST
    local ctable = {cc * 0.4,cc,cc * 0.6,cc}
    local myText = {
      {{ctable,"Arrow keys to move."},-1, "left"},
      {{ctable,"Spacebar, Escape, and Backspace pause the game and open the in-game menu."},-1, "left"},
      {{ctable,"The hearts top left represent your health. If they run out you die."},-1, "left"},
      {{ctable,"Bottom right is the ".. GCON.money .." counter and the clock."},-1, "left"},
      {{ctable,"When the clock turns blueish, it means time is stopped."},-1, "left"},
      {{ctable,"Now press the right arrow key to jump out of bed."},-1, "left"}
    }
    -- do the funcs
    local activateFuncs = {}
    local textsNum = #myText
    for i = 1,textsNum do
      activateFuncs[i] = function (self, dt, textIndex)
        self.typical_activate(self, dt, textIndex)
        self.next = i + 1
        if self.next > textsNum then self.next = "end" end
      end
    end
    local tutDlg = (require "GameObjects.GlobalNpcs.autoActivatedDlg"):new{
      pauseWhenTalkedTo = true,
      keepControllerDisabled = true,
      myText = myText,
      activateFuncs = activateFuncs
    }
    o.addToWorld(tutDlg)
  end,
  check_state = function(instance, dt)
    if inp.rightPressed then
      instance.state_machine:change_state(instance, dt, "jumping")
    end
  end,
  end_state = function(instance, dt)
  end
  },

  jumping = {
  run_state = function(instance, dt)
    instance.playa.x = instance.playa.x + 50 * dt
  end,
  start_state = function(instance, dt)
    instance.playa.zvel = 60
    snd.play(instance.playa.sounds.jump)
    instance.playa.x_scale = -1
    instance.playa.sprite = im.sprites["Witch/walk_left"]
  end,
  check_state = function(instance, dt)
    if instance.playa.zvel == 0 and instance.playa.zo == 0 then
      instance.state_machine:change_state(instance, dt, "finish")
    end
  end,
  end_state = function(instance, dt)
    session.save.startCutsceneDone = true
    instance.playa.animation_state:change_state(instance.playa, dt, "rightstill")
    session.startQuest("mainQuest1")
  end
  },

  finish = {
  run_state = function(instance, dt)
  end,
  start_state = function(instance, dt)
    o.removeFromWorld(self)
  end,
  check_state = function(instance, dt)
  end,
  end_state = function(instance, dt)
  end
  },
}

function Cutscene.initialize(instance)
  instance.state_machine = sm.new_state_machine(states)
end

Cutscene.functions = {
  load = function (self)
    if session.save.startCutsceneDone then return o.removeFromWorld(self) end
    self.startingTime = session.save.time
    game.room.timeScreenEffect = "midnight"
    game.timeScreenEffect = "midnight"
    self.state = "start"
  end,

  update = function (self, dt)
    if session.save.startCutsceneDone then return end

    local ms = self.state_machine
    -- Check state
    ms.states[ms.state].check_state(self, dt)
    -- Run state
    ms.states[ms.state].run_state(self, dt)

    -- Control gameobject position
    self.playa.body:setPosition(self.playa.x, self.playa.y)
    self.rescuer.body:setPosition(self.rescuer.x, self.rescuer.y)

    -- Stop time from going too far
    if session.save.time - self.startingTime > 1 then
      game.room.timeDoesntPass = true
    end
  end,
}

function Cutscene:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Cutscene, instance, init) -- add own functions and fields
  return instance
end

return Cutscene
