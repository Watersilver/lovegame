local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local inp = require "input"
local inv = require "inventory"
local dlg = require "dialogue"
local u = require "utilities"

local npcTest = require "GameObjects.NpcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

-- because Imma moron
local saveKeysToBeIgnored = {
  hasSword = true, hasJump = true,
  hasMissile = true, hasMark = true,
  hasRecall = true, hasGrip = true,
  swordKey = true, jumpKey = true,
  missileKey = true, markKey = true,
  recallKey = true, gripKey = true,
  playerX = true, playerY = true,
  playerHealth = true
}

-- write the text
local myText = {
  {{{cc,cc,cc,cc},"Save game?"},-1, "left"},
  {{{cc,cc,cc,cc},"Saved!"},-1, "left"}
}

-- do the funcs
local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp()
  self.next = {2, "end"}
end
activateFuncs[2] = function (self, dt, textIndex)
  self.image_index = 1
  -- save game
  local saveContent = "local save = {}"
  local saveName = "Saves/" .. session.save.saveName .. ".lua"
  -- local success = love.filesystem.write(saveName, "local save = {}")
  -- write save (except spell slots and coordinates)
  for key, value in pairs(session.save) do
    if not saveKeysToBeIgnored[key] then
      if type(value) == "string" then value = '"' .. value .. '"' end
      if type(value) == "boolean" then value = value and "true" or "false" end
      -- love.filesystem.append(saveName, "\nsave." .. key .. " = " .. value)
      saveContent = saveContent .. "\nsave." .. key .. " = " .. value
    end
  end
  -- write coordinates
  -- love.filesystem.append(saveName, "\nsave.playerX = " .. pl1.x)
  -- love.filesystem.append(saveName, "\nsave.playerY = " .. pl1.y)
  saveContent = saveContent .. "\nsave.playerX = " .. pl1.x
  saveContent = saveContent .. "\nsave.playerY = " .. pl1.y
  -- write health
  saveContent = saveContent .. "\nsave.playerHealth = " .. pl1.health
  -- write spel slots
  for i, slot in ipairs(inv.slots) do
    if slot.item then
      -- love.filesystem.append(saveName, "\nsave." .. "has" .. u.capitalise(slot.item.name) .. " = " .. slot.item.name)
      -- love.filesystem.append(saveName, "\nsave." .. slot.item.name .. "Key = " .. '"' .. slot.key .. '"')
      saveContent = saveContent .. "\nsave." .. "has" .. u.capitalise(slot.item.name) .. " = " .. '"' .. slot.item.name .. '"'
      saveContent = saveContent .. "\nsave." .. slot.item.name .. "Key = " .. '"' .. slot.key .. '"'
    end
  end
  -- love.filesystem.append(saveName, "\nreturn save")
  saveContent = saveContent .. "\nreturn save"
  local success = love.filesystem.write(saveName, saveContent)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

local function onDialogueRealEnd(instance)
  instance.image_index = 0
end

local enmptyTable = {}
function NPC.initialize(instance)
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.onDialogueRealEnd = onDialogueRealEnd
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.owlStatue
  instance.lightSource = {kind = "owlStatue"}

  instance.pushback = true
  instance.ballbreaker = true
  instance.unpushable = false
  instance.physical_properties.masks = enmptyTable
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
