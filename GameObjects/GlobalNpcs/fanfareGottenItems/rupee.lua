local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee

local itemGetFunc = function ()
  session.addMoney(1)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 1 rupee!",
  comment = "What a boner-killer!",
  itemGetEffect = itemGetFunc
}

return gottenItem
