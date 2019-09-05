local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee20

local itemGetFunc = function ()
  session.save.rupees = math.min((session.save.rupees or 0) + 20, 9999)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 20 rupees!",
  comment = "Not bad!",
  itemGetEffect = itemGetFunc
}

return gottenItem
