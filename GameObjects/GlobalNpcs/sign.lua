local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local dlg = require "dialogue"
local ps = require "physics_settings"
local drops = require "GameObjects.drops.drops"
local expl = require "GameObjects.explode"
local inp = require "input"
local game = require "game"
local dc = require "GameObjects.Helpers.determine_colliders"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local o = require "GameObjects.objects"

local npcTest = require "GameObjects.npcTest"


local function throw_collision(self)
  expl.commonExplosion(self, im.spriteSettings.woodDestruction)
  drops.normal(self.x, self.y)
end


local floor = math.floor

local NPC = {}

function NPC.initialize(instance)
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.sign
  instance.spritefixture_properties = nil
  instance.unpushable = false
  instance.pushback = not session.save.dinsPower
  instance.liftable = true
  instance.ballbreaker = true
  instance.layer = 15
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.pauseWhenReading = false
  instance.throw_collision = throw_collision
end

NPC.functions = {
  activate = function (self, dt)
    if self.activated then
      if self.pauseWhenReading then game.cutscenePause(true) end

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
          if self.pauseWhenReading then game.cutscenePause(false) end
        end
      else -- cant read from that side
        if self.activator then
          if self.activator.body then self.activator.body:setType("static") end
          if self.activator.player then inp.disable_controller(self.activator.player) end
        end
        snd.play(glsounds.letter)
        dlg.simpleWallOfText.setUp(
          {{{COLORCONST,COLORCONST,COLORCONST,COLORCONST},
          "Can't read it from here..."},
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
      if self.pauseWhenReading then game.cutscenePause(false) end
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
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if (other.immasword and session.save.dinsPower) or other.immabombsplosion then
      self:throw_collision()
      o.removeFromWorld(self)
      self.beginContact = nil
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
