local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.pieceOfHeart

local itemGetFunc = function ()
  session.save.piecesOfHeart = session.save.piecesOfHeart and session.save.piecesOfHeart + 1 or 1
  if pl1 then
    pl1:readSave()
    pl1.health = pl1.maxHealth
  end
end

local function incomingHeartContainer()
  return not ((not session.save.piecesOfHeart) or
  (math.floor((session.save.piecesOfHeart + 1) / 4)
    ~= (session.save.piecesOfHeart + 1) / 4))
end

local function heartContainer()
  local poc = session.save.piecesOfHeart or 0
  return math.floor(poc / 4) == poc / 4
end

local function commentDeterminer()
  return incomingHeartContainer() and "Health increased by one Heart!" or "Collect 4 to extend maximum health by one Heart!"
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
