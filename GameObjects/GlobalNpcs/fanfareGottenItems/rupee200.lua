local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee200

local itemGetFunc = function ()
  session.save.rupees = math.min((session.save.rupees or 0) + 200, 9999)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 200 rupees!",
  comment = "What a lucky fucker!",
  itemGetEffect = itemGetFunc
}

return gottenItem
