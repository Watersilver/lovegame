local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local inp = require "input"
local dlg = require "dialogue"
local npcTest = require "GameObjects.npcTest"
local snd = require "sound"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

local function typical_activate(self, dt, textIndex)
  dlg.simpleWallOfText.setUp(
    self.myText[textIndex],
    self.y,
    self.onDialogueEnd
  )
  dlg.enable = true
  if self.activator then
    if self.activator.body then self.activator.body:setType("static") end
    if self.activator.player then inp.disable_controller(self.activator.player) end
  end
end

local myText = {
  {{{cc,cc*0.5,cc*0.5,cc}, "Up & down arrow keys to read textbox.\n", {cc,cc,cc,cc},"Default controls (changeable in main menu):\n-arrow keys: movement\n-a,s,d,z,x,c: spell slots\n-space: inventory/pause\nOther controls (Not changeable): \n-arrow keys: navigate main menu/dialogue/inventory\n-enter: accept/activate/choose\n-escape: back(main menu)\n-F11: fullscreen on/off"},-1, "left"},
}

local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.counter = 1
  instance.myText = myText
  instance.physical_properties = nil
  instance.spritefixture_properties = nil
  instance.sprite_info = nil
  instance.update = nil
  instance.draw = nil
  instance.trans_draw = nil
  instance.onDialogueEnd = function()
    if type(instance.next) == "table" then
      instance.counter = instance.next[dlg.cursor+1] -- cursor starts from 0, arrays start from 1, so add 1
    else
      instance.counter = instance.next
    end
    if instance.counter == "end" then
      instance.active = false
    else
      instance.activated = true
      dlg.enabled = true
    end
  end
end

NPC.functions = {
  load = function (self)
    if session.save.instructionsDialogueRead then
      self.skipDelete = true
      o.removeFromWorld(self)
      return
    end
    self.activator = o.identified.PlayaTest[1]
    self.activated = true
    self.roomMusic = game.room.music_info
    game.room.music_info = nil
  end,

  activate = function (self, dt)
    if self.activated then
      activateFuncs[self.counter](self, dt, self.counter)
    elseif self.active then
    else
      self.counter = 1
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
      end
      session.save.instructionsDialogueRead = true
      o.removeFromWorld(self)
    end
  end,

  -- update = function (self, dt)
  --   snd.bgm:load()
  -- end,

  delete = function (self)
    if self.skipDelete then return end
    -- snd.bgm:load(self.roomMusic)
    snd.bgmV2:load(session.getMusic())
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
