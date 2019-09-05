local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local dlg = require "dialogue"
local ps = require "physics_settings"
local inp = require "input"
local game = require "game"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local o = require "GameObjects.objects"

local npcTest = require "GameObjects.NpcTest"


local floor = math.floor

local NPC = {}

local function onDialogueRealEnd(instance)
end

function NPC.initialize(instance)
  instance.onDialogueRealEnd = onDialogueRealEnd
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.chest
  instance.spritefixture_properties = nil
  instance.unpushable = false
  instance.pushback = true
  instance.ballbreaker = true
  instance.layer = 15
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.chestId = "teschest"
  -- instance.chestContentsInit = (require "GameObjects.GlobalNpcs.fanfareGottenItems.pieceOfHeart").itemInfo
end

NPC.functions = {
  load = function (self)
    if session.save["chest_" .. self.chestId] then
      self.unactivatable = true
      self.image_index = 1
    end
  end,

  activate = function (self, dt)
    if self.activated then
      game.cutscenePause(true)

      if pl1 and pl1.y > self.ystart + self.sprite.height / 2 then -- Chest open
        local ssw = self.sprite.width * 0.4
        if pl1.x < self.xstart + ssw and pl1.x > self.xstart - ssw then
          if self.activator then
            if self.activator.body then self.activator.body:setType("static") end
            if self.activator.player then inp.disable_controller(self.activator.player) end
          end
          self.opened = true
          snd.play(glsounds.open)
          self.timer = 0
          self.image_index = 1
        else
          self.doNothing = true
          game.cutscenePause(false)
        end
      else -- cant open from that side
        if self.activator then
          if self.activator.body then self.activator.body:setType("static") end
          if self.activator.player then inp.disable_controller(self.activator.player) end
        end
        snd.play(glsounds.letter)
        dlg.simpleWallOfText.setUp(
          {{{COLORCONST,COLORCONST,COLORCONST,COLORCONST},
          "Can't open from that side..."},
          -1, "left"},
          self.y,
          function() self.sideDialogueEnd = true end
        )
        self.sideDialogue = true
        dlg.enable = true
      end
    elseif self.active then
      if self.opened then
        -- Chest open timer
        self.timer = self.timer + dt
        if self.timer > 0.7 then self.active = false end
      elseif self.sideDialogue then
        -- cant open from that side
        if self.sideDialogueEnd then self.active = false end
      elseif self.doNothing then
        self.doNothing = false
        self.active = false
      end
    else
      game.cutscenePause(false)
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
      end
      if self.opened then -- Chest open end
        self.unactivatable = true
        local chestContents = itemGetPoseAndDlg:new(self.chestContentsInit)
        o.addToWorld(chestContents)
        session.save["chest_" .. self.chestId] = true
      elseif self.sideDialogue then -- cant open from that side
        snd.play(glsounds.textDone)
        self.sideDialogue = nil
        self.sideDialogueEnd = nil
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
