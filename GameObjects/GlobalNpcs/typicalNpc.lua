local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local inp = require "input"
local dlg = require "dialogue"
local npcTest = require "GameObjects.NpcTest"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

local function typical_activate(self, dt, textIndex)
  local yToAvoid = self.y
  if self.dontDrawOverPlayer and pl1 then
    yToAvoid = pl1.y
  end
  dlg.simpleWallOfText.setUp(
    self.myText[textIndex],
    yToAvoid,
    self.onDialogueEnd
  )
  dlg.enable = true
  if self.activator then
    if self.activator.body then self.activator.body:setType("static") end
    if self.activator.player then inp.disable_controller(self.activator.player) end
  end
end

-- Write the text
local myText = {
  {{{cc,cc,cc,cc},"Something something..."},-1, "left"},
  {{{cc,cc,cc,cc},"Yes or no?"},-1, "left"},
  {{{cc,cc,cc,cc},"Yes? Yes!"},-1, "left"},
  {{{cc,cc,cc,cc},"No? No..."},-1, "left"}
}

-- do the funcs
local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp("Yes.", "No.")
  self.next = {3, 4}
end
activateFuncs[3] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end
activateFuncs[4] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.sprite_info = im.spriteSettings.npcTest2Sprites
  instance.counter = 1
  instance.noLetterSound = {}
  instance.altLetterSound = {}
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.onDialogueEnd = function()
    if type(instance.next) == "table" then
      snd.play(glsounds.select)
      instance.counter = instance.next[dlg.cursor+1] -- cursor starts from 0, arrays start from 1, so add 1
    else
      instance.counter = instance.next
    end
    if instance.counter == "end" then
      instance.active = false
      -- Only play when there's no selection involved
      if type(instance.next) ~= "table" then snd.play(glsounds.textDone) end
    else
      instance.activated = true
      dlg.enabled = true
    end
  end
  instance.typical_activate = typical_activate
end

NPC.functions = {
  activate = function (self, dt)
    if self.activated then
      -- Only play when there's no selection involved and at dialogue start
      if not self.noLetterSound[self.counter] and not self.altLetterSound[self.counter] and ((type(self.next) ~= "table") or self.counter == 1) then snd.play(glsounds.letter) end
      if self.altLetterSound[self.counter] then
        if type(self.altLetterSound[self.counter] == "function") then
          snd.play(self.altLetterSound[self.counter]())
        else
          snd.play(self.altLetterSound[self.counter])
        end
      end
      self.activateFuncs[self.counter](self, dt, self.counter)
    elseif self.active then
    else
      self.counter = 1
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
        if self.onDialogueRealEnd then
          self:onDialogueRealEnd()
        end
      end
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
