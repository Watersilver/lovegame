local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.dropRupee5

local itemGetFunc = function ()
  session.save.rupees = math.min((session.save.rupees or 0) + 5, 9999)
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got 5 rupees!",
  comment = "Oh well...",
  itemGetEffect = itemGetFunc
}

return gottenItem
