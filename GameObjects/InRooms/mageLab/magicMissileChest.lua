local p = require "GameObjects.prototype"
local npcTest = require "GameObjects.npcTest"
local chest = require "GameObjects.GlobalNpcs.chest"

local floor = math.floor

local Chest = {}

function Chest.initialize(instance)
  instance.chestId = "magicMissileChest"
  instance.chestContentsInit =
    (require "GameObjects.GlobalNpcs.fanfareGottenItems.magicMissile").itemInfo
end

Chest.functions = {}

function Chest:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(chest, instance, init) -- add parent functions and fields
  p.new(Chest, instance, init) -- add own functions and fields
  return instance
end

return Chest
