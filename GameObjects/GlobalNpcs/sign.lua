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

function NPC.initialize(instance)
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.sign
  instance.spritefixture_properties = nil
  instance.unpushable = false
  instance.pushback = true
  instance.ballbreaker = true
  instance.layer = 15
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.pauseWhenReading = true
end

NPC.functions = {
  activate = function (self, dt)
    if self.activated then
      game.cutscenePause(true)

      if pl1 and pl1.y > self.ystart + self.sprite.height / 2 then -- Read sign
        local ssw = self.sprite.width * 0.4
        if pl1.x < self.xstart + ssw and pl1.x > self.xstart - ssw then
          if self.activator then
            if self.activator.body then self.activator.body:setType("static") end
            if self.activator.player then inp.disable_controller(self.activator.player) end
          end
          snd.play(glsounds.letter)
          dlg.simpleWallOfText.setUp(
            {{{COLORCONST,COLORCONST,COLORCONST,COLORCONST},
            "Hi, I'm a sign!"},
            -1, "left"},
            self.y,
            function() self.dialogueEnd = true end
          )
          self.dialogueActive = true
          dlg.enable = true
        else
          self.doNothing = true
          game.cutscenePause(false)
        end
      else -- cant read from that side
        if self.activator then
          if self.activator.body then self.activator.body:setType("static") end
          if self.activator.player then inp.disable_controller(self.activator.player) end
        end
        snd.play(glsounds.letter)
        dlg.simpleWallOfText.setUp(
          {{{COLORCONST,COLORCONST,COLORCONST,COLORCONST},
          "Can't read from that side..."},
          -1, "left"},
          self.y,
          function() self.dialogueEnd = true end
        )
        self.dialogueActive = true
        dlg.enable = true
      end
    elseif self.active then
      if self.doNothing then
        self.doNothing = false
        self.active = false
      elseif self.dialogueActive then
      if self.dialogueEnd then self.active = false end
      end
    else
      game.cutscenePause(false)
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
      end
      if self.dialogueActive then
        snd.play(glsounds.textDone)
        self.dialogueActive = nil
        self.dialogueEnd = nil
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
