local ps = require "physics_settings"
local im = require "image"
local o = require "GameObjects.objects"
local p = require "GameObjects.prototype"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local inp = require "input"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local npcPrototype = require "GameObjects.npcPrototype"

local NPC = {}

local texts = {
  init = "Hey you're awake! You were in a pretty bad shape. I was worried you wouldn't wake.",
  sec = "We found you to the northeast of here. Do you know how you ended up there?",
  tri = "...",
  qua = "I see. So you're ".. session.save.saveName .." from the land of " .. GCON.heroWorld .. " and it was a strange portal that brought you here...",
  cin = "I've never heard of your land. I'm afraid you're very far from it... Our land is called " .. GCON.shidun .. " and it's a very troubled place. We here at "..GCON.lakeVillage.." stick together and survive though.",
  six = "The mage "..GCON.npcNames.mage.." lives close to where you were found... Maybe you'll find out more about what happened to you if you go there.",
  -- six = "I'm sorry you got caught up in our troubles, " .. session.save.saveName .. ".",
}
local s_info = {
  {'NPCs/ResqueGirl/down', 2, padding = 2, width = 16, height = 16},
  {'NPCs/ResqueGirl/left', 2, padding = 2, width = 16, height = 16},
  {'NPCs/ResqueGirl/up', 2, padding = 2, width = 16, height = 16},
}
local spritepath = "NPCs/ResqueGirl/"
function NPC.initialize(instance)
  instance.sprite_info = s_info
  instance.spritepath = spritepath
  instance.ids[#instance.ids+1] = "rescuer"
  -- determine initial content
  instance.content = texts.init
end

local initHook = function(dlgControl, dt)
  cd.interactiveProximityTrigger(dlgControl, dt)
  -- Check if I have to make tutorial box
  if dlgControl.speechIndicator then
    -- write the text
    local cc = COLORCONST
    local ctable = {cc * 0.4,cc,cc * 0.6,cc}
    local myText = {
      {{ctable,"Press Enter to advance text in textboxes."},-1, "left"},
      {{ctable,"Also press Enter to interact with interactive stuff in the world."},-1, "left"},
      {{ctable,"Generally Enter confirms and Escape cancels."},-1, "left"},
      {{ctable,"Press up and down arrow keys for navigation and scrolling...\z
      \n...\z
      \nLike this."},-1, "left"},
      {{ctable,"Well done! Try talking to the character who approached you now."},-1, "left"}
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
    dlgControl.updateHook = cd.interactiveProximityTrigger
  end
end

local hookReturnHandleTable = {
  init = function (self)
    if session.save.startCutsceneDone then
      self.dlgState = "waiting"
    else
      self.dlgState = "init"
    end
  end,
  initCutsceneDone = function (self) self.dlgState = "waiting" end,
  ptTriggered = function (self) self.dlgState = "talking" end,
  ssbFar = function (self) self.dlgState = "interrupted" end,
  ssbDone = function (self)
    if session.save.startCutsceneDone then
      if self.speechBubble.enterPressed and session.save.rescuerDlg == 0 then
        session.save.rescuerDlg = 1
      end
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
      return
    else
      if self.content == texts.init then self.content = texts.sec
      elseif self.content == texts.sec then
        self.content = texts.tri
        self.dlgState = "auto"
        cd.ssbChange(self)
        return
      elseif self.content == texts.tri then self.content = texts.qua
      elseif self.content == texts.qua then self.content = texts.cin
      elseif self.content == texts.cin then self.content = texts.six
      else
        -- Clean up
        cd.cleanSsb(self)
        self.dlgState = "mute"
        return
      end
      cd.ssbChange(self)
      self.dlgState = "talking"
    end
  end,
}
local muteHook = function (dlgControl)
  if session.save.startCutsceneDone then
    dlgControl.updateHook = nil
    dlgControl.hookReturn = "initCutsceneDone"
  end
end
local updateHookTable = {
  init = function (self)
    self.indicatorCooldown = 0
    self.updateHook = initHook
  end,
  waiting = function (self)
    -- self.blockInput = false
    self.indicatorCooldown = 0.5
    self.updateHook = cd.interactiveProximityTrigger
  end,
  talking = function (self)
    self.updateHook = cd.nearInteractiveBubble
  end,
  auto = function (self)
    self.updateHook = cd.ssb.auto.sound.func
  end,
  mute = function (self)
    self.updateHook = muteHook
  end,
  interrupted = function (self)
    cd.ssbInterrupted(self)
  end,
}
NPC.functions = {
  getInterruptedDlg = function (self)
    return "Take care."
  end,

  getDlg = function (self)
    if session.save.startCutsceneDone then
      if session.save.rescuerDlg == 0 then
        self.content = "My name? It's " .. GCON.npcNames.rescuer .. "."
      elseif session.save.rescuerDlg == 1 then
        self.content = "You're free to stay here."
      end
    end
    return self.content
  end,

  getChoices = function (self)
    return self.choices
  end,

  handleHookReturn = function (self)
    hookReturnHandleTable[self.hookReturn or "init"](self)
  end,

  determineUpdateHook = function (self)
    updateHookTable[self.dlgState](self)
  end,

  load = function (self)
    dlgCtrl.functions.load(self)
    session.save.rescuerDlg = session.save.rescuerDlg or 0
  end,

  update = function (self, dt)
    dlgCtrl.functions.update(self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed)
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end

    if session.save.startCutsceneDone then
      self:faceTowards(pl1)
    end

    td.zAxis(self, dt)

    sh.handleShadow(self, true)
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(npcPrototype, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
