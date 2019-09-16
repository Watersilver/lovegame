local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.pieceOfHeart

local itemGetFunc = function ()
  session.save.piecesOfHeart = math.min(session.save.piecesOfHeart + 1, GCON.maxPOHs)
  if pl1 then
    pl1:readSave()
    pl1.health = pl1.maxHealth
  end
end

local function heartContainer()
  local poh = session.save.piecesOfHeart or 0
  return math.floor(poh / 4) == poh / 4
end

local function commentDeterminer()
  local poh = session.save.piecesOfHeart or 0
  incomingHeartContainer = math.floor((poh + 1) / 4) == (poh + 1) / 4
  if poh >= GCON.maxPOHs then return "Wait, there shouldn't be any more of those... \nUnfortunately it has no effect..." end
  if poh + 1 >= GCON.maxPOHs then return "You discovered the final piece of Heart! \nCongratulations!" end
  return incomingHeartContainer and "Health increased by one Heart!" or "Collect 4 to extend maximum health by one Heart!"
end

local function soundDeterminer()
  if heartContainer() then return glsounds.heartContainer else return glsounds.letter end
end

local altLetterSound = {[2] = soundDeterminer}
gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got a piece of heart!",
  comment = commentDeterminer,
  itemGetEffect = itemGetFunc,
  altLetterSound = altLetterSound
}

return gottenItem
