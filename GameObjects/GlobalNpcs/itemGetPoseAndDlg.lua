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
local lighting = require "ScreenEffects.lighting.lighting"

local npcTest = require "GameObjects.NpcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"
local autoActivatedDlg = require "GameObjects.GlobalNpcs.autoActivatedDlg"

local defaultItemSprite = im.spriteSettings.dropRupee

local NPC = {}

-- write the text
local myText = {
  {{{1,1,1,1}, nil},-1, "left"},
  {{{1,1,1,1}, nil},-1, "left"},
  {{{0.4,1,0.6,1}, "You found your first item! Most items can be seen by navigating to the items tag of the pause menu. You can use some items by selecting them and pressing Enter."},-1, "left"},
  {{{0.4,1,0.6,1}, GCON.fsm},-1, "left"}
}

-- do the funcs
local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  ---@type CollectableData | nil
  local data = self.data

  if pl1 and pl1.exists then
    self.prevPlSpr = pl1.sprite
    self.prevPlImIn = pl1.image_index
    pl1.sprite = im.sprites["Witch/display_down"]

    if data then
      pl1.image_index = data.fanfareData.pl_image_index
    end
  end
  game.cutscenePause(true)
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
  -- session.save.gotFirstSpell
  if self.type == "spell" then
    self.next = session.save.gotFirstSpell and "end" or 4
  elseif self.type == 'item' then
    self.next = session.save.gotFirstItem and "end" or 3
  else
    self.next = "end"
  end
end
activateFuncs[3] = function (self, dt, textIndex)
  session.save.gotFirstItem = true
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end
activateFuncs[4] = function (self, dt, textIndex)
  session.save.gotFirstSpell = true
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

local function onDialogueRealEnd(instance)
  if pl1 then
    pl1.sprite = instance.prevPlSpr
    pl1.image_index = instance.prevPlImIn
  end
  instance.image_index = 0
  game.cutscenePause(false)
  snd.bgmV2.overrideAndLoad()
  o.removeFromWorld(instance)
end

function NPC.initialize(instance)
  if pl1 then
    local xtotal, ytotal = pl1.x + pl1.iox, pl1.y + pl1.ioy + pl1.zo - ps.shapes.plshapeHeight
    instance.xstart = xtotal
    instance.ystart = ytotal
    instance.x = xtotal
    instance.y = ytotal
  end
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.onDialogueRealEnd = onDialogueRealEnd
  instance.layer = 21
  instance.sounds = {}
  instance.sprite_info = defaultItemSprite
  instance.playerFrame = instance.playerFrame or 0
  instance.noLetterSound = {[1] = true}
  instance.image_index = 0
  instance.image_speed = 0
  instance.frame_speed_mods = {}
  instance.angle = 0
  instance.x_scale = 0
  instance.y_scale = 0

  instance.life_timer = 0
  instance.hasAppliedEffect = false

  session.setInstanceId(instance, 'itemGetPoseAndDlg')
end

NPC.functions = {
  isMyTurn = function(self)
    local i = o.identified['itemGetPoseAndDlg']
    if i then
      if i[1] == self then
        return true
      else
        return false
      end
    else
      return true
    end
  end,

  load = function (self)
    if o.identified and o.identified.PlayaTest and o.identified.PlayaTest[1] then
      self.activator = o.identified.PlayaTest[1]
    end

    self.activated = true
  end,

  unpausable_update = function (self, dt)
    if not self:isMyTurn() then return end

    -- Apply effect here instead of load so we ensure it gets applied during our turn
    if not self.hasAppliedEffect then
      self.hasAppliedEffect = true

      ---@type CollectableData | nil
      local data = self.data

      if data then
        session.save['dropfanfare_'..data.id] = 1

        data.effect(self)

        if not self.information and data then
          local i = data.fanfareData.info
          if type(i) == 'function' then
            self.information = i(self)
          else
            self.information = i
          end
        end
        self.myText[1][1][2] = self.information or "You got [ITEM]!"
        if not self.comment and data then
          local c = data.fanfareData.comment
          if type(c) == 'function' then
            self.comment = c(self)
          else
            self.comment = c
          end
        end
        if type(self.comment) == "function" then self.comment = self.comment() end
        self.myText[2][1][2] = self.comment or "How nice!"
      end
    end

    npcTest.functions.unpausable_update(self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed*(self.frame_speed_mods[math.floor(self.image_index)] or 1))
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end
  end,

  unstoppable_update = function (self, dt)
    if not self:isMyTurn() then return end

    ---@type CollectableData | nil
    local data = self.data

    if pl1 then
      local xtotal, ytotal = pl1.x + pl1.iox, pl1.y + pl1.ioy + pl1.zo - ps.shapes.plshapeHeight - self.sprite.height * 0.5

      self.life_timer = self.life_timer + dt
      ytotal = ytotal + 2 * math.sin(self.life_timer)
      lighting.applyLight{
        type = 'dynamic',
        dynamic_options = {radius = math.max(self.sprite.height, self.sprite.width) * 0.5 + 1},
        x = xtotal,
        y = ytotal
      }
      lighting.applyLight{
        type = 'dynamic',
        dynamic_options = {radius = math.max(self.sprite.height, self.sprite.width) * 0.5 + 4},
        x = xtotal,
        y = ytotal,
        rgba = {r = 1, g = 0, b = 1, a = 1}
      }
      self.angle = 0.1 * math.sin(3.5 * self.life_timer)
      self.x_scale = 1 + 0.05 * math.sin(7 * self.life_timer)
      self.y_scale = 1 + 0.05 * math.sin(7 * self.life_timer + math.pi * 0.5)

      self.xstart = xtotal
      self.ystart = ytotal
      self.x = xtotal
      self.y = ytotal
    end

    if data then
      if data.both_update then
        data.both_update(self, dt)
      end
      if data.unstoppable_update then
        data.unstoppable_update(self, dt)
      end
    end
  end,

  draw = function (self)
    if not self:isMyTurn() then return end

    if pl1 then
      local sprite = self.sprite
      while self.image_index >= sprite.frames do
        self.image_index = self.image_index - sprite.frames
      end
      local frame = sprite[math.floor(self.image_index)]
      love.graphics.draw(
      sprite.img, frame, self.x, self.y, self.angle,
      self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
      sprite.cx, sprite.cy)
    end
  end,

  trans_draw = function() end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(autoActivatedDlg, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

---@param data CollectableData
---@param init? any
function NPC:fromData(data, init)
  local a = {
    data = data,
    sprite_info = data.sprite_info,
    image_speed = data.image_speed,
    type = data.type
  }

  if data.frame_speed_mods then
    a.frame_speed_mods = data.frame_speed_mods
  end

  if init then
    for key, val in pairs(init) do
      a[key] = val
    end
  end

  local newNPC = NPC:new(a)
  o.addToWorld(newNPC)
  return newNPC
end

return NPC
