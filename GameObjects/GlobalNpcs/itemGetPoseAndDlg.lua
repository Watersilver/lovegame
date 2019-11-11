local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local inp = require "input"
local inv = require "inventory"
local dlg = require "dialogue"
local u = require "utilities"
local o = require "GameObjects.objects"
local game = require "game"
local ps = require "physics_settings"

local npcTest = require "GameObjects.NpcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"
local autoActivatedDlg = require "GameObjects.GlobalNpcs.autoActivatedDlg"

local itemSprite = im.spriteSettings.dropRupee
local playerSprites = im.spriteSettings.playerSprites

local floor = math.floor

local NPC = {}

local cc = COLORCONST

-- write the text
local myText = {
  {{{cc,cc,cc,cc}, nil},-1, "left"},
  {{{cc,cc,cc,cc}, nil},-1, "left"}
}

-- do the funcs
local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  game.cutscenePause(true)
  self.activator.invisible = true
  if self.itemGetEffect then
    self.itemGetEffect()
  end
  snd.play(self.sounds.myFanfare or glsounds.fanfareItem)
  -- self.music_info = snd.bgm.last_loaded_music_info
  self.music_info = snd.bgmV2.current
  snd.bgmV2.overrideAndLoad({previousFadeOut = math.huge, silenceDuration = 0})

  self.typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

local function onDialogueRealEnd(instance)
  instance.image_index = 0
  instance.activator.invisible = false
  game.cutscenePause(false)
  snd.bgmV2.overrideAndLoad()
  o.removeFromWorld(instance)
end

function NPC.initialize(instance)
  instance.myText = myText
  instance.myText[1][1][2] = instance.information or "You got [ITEM]!"
  if type(instance.comment) == "function" then instance.comment = instance.comment() end
  instance.myText[2][1][2] = instance.comment or "How nice!"
  instance.activateFuncs = activateFuncs
  instance.onDialogueRealEnd = onDialogueRealEnd
  instance.layer = 21
  instance.sounds = {}
  instance.itemSprite_info = instance.itemSprite or itemSprite
  instance.itemSprite_info = instance.itemSprite_info[1]
  instance.sprite_info = playerSprites
  instance.playerFrame = instance.playerFrame or 0
  instance.noLetterSound = {[1] = true}
end

NPC.functions = {
  load = function (self)
    if o.identified and o.identified.PlayaTest and o.identified.PlayaTest[1] then
      self.activator = o.identified.PlayaTest[1]
    end
    self.sprite = im.sprites["Witch/display_down"]
    self.activated = true
    if self.itemSprite_info then
      im.load_sprite(self.itemSprite_info)
      self.itemSprite = im.sprites[self.itemSprite_info[1] or self.itemSprite_info["img_name"]]
    end
  end,

  delete = function (self)
    if self.itemSprite_info then
      im.unload_sprite(self.itemSprite_info[1] or self.itemSprite_info["img_name"])
    end
  end,

  draw = function (self)
    if pl1 then
      local xtotal, ytotal = pl1.x + pl1.iox, pl1.y + pl1.ioy + pl1.zo
      local sprite = self.sprite
      local frame = sprite[self.playerFrame]
      local worldShader = love.graphics.getShader()
      love.graphics.setShader(pl1.playerShader)
      love.graphics.draw(
      sprite.img, frame, xtotal, ytotal, 0,
      sprite.res_x_scale*pl1.x_scale, sprite.res_y_scale*pl1.y_scale,
      sprite.cx, sprite.cy)
      love.graphics.setShader(worldShader)

      local itemSprite = self.itemSprite
      local frame = itemSprite[0]
      love.graphics.draw(
      itemSprite.img, frame, xtotal, ytotal - ps.shapes.plshapeHeight, 0,
      itemSprite.res_x_scale*pl1.x_scale, itemSprite.res_y_scale*pl1.y_scale,
      itemSprite.cx, itemSprite.height)
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(autoActivatedDlg, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
