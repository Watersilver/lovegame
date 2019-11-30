local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local dlg = require "dialogue"
local ps = require "physics_settings"
local inp = require "input"
local game = require "game"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local o = require "GameObjects.objects"

local npcTest = require "GameObjects.npcTest"
local chest = require "GameObjects.GlobalNpcs.chest"


local floor = math.floor

local NPC = {}

function NPC.initialize(instance)
  instance.chestId = "debugTest"
  instance.chestContentsInit =
    (require "GameObjects.GlobalNpcs.fanfareGottenItems.debug").itemInfo
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(chest, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
