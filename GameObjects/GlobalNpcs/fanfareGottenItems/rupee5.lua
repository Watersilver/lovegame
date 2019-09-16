local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee5

local itemGetFunc = function ()
  session.addMoney(5)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 5 rupees!",
  comment = "Oh well...",
  itemGetEffect = itemGetFunc
}

return gottenItem
