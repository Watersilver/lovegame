local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee20

local itemGetFunc = function ()
  session.addMoney(20)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 20 rupees!",
  comment = "Not bad!",
  itemGetEffect = itemGetFunc
}

return gottenItem
