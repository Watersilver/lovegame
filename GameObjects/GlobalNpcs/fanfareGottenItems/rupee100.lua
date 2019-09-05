local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee100

local itemGetFunc = function ()
  session.save.rupees = math.min((session.save.rupees or 0) + 100, 9999)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 100 rupees!",
  comment = "Amazing!",
  itemGetEffect = itemGetFunc
}

return gottenItem
