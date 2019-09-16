local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee200

local itemGetFunc = function ()
  session.addMoney(200)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 200 rupees!",
  comment = "What a lucky fucker!",
  itemGetEffect = itemGetFunc
}

return gottenItem
