local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee100

local itemGetFunc = function ()
  session.addMoney(100)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 100 rupees!",
  comment = "Amazing!",
  itemGetEffect = itemGetFunc
}

return gottenItem
