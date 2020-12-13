local im = require "image"
local asp = require "GameObjects.Helpers.add_spell"

local gottenItem = {}

-- local sprite = im.spriteSettings.dropRupee
local sprite = im.load_sprite{'Inventory/InvMissileL1', 1, padding = 3, width = 10, height = 10}

local itemGetFunc = function ()
  session.save.hasMissile = "missile"
  asp.emptySpellSlots()
  if pl1 then pl1:readSave() end
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You found the magic missile!",
  comment = "Hold the magic missile key to fire away!",
  itemGetEffect = itemGetFunc,
  type = "spell"
}

return gottenItem
