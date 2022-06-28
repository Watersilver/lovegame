local im = require "image"

local gottenItem = {}

local sprite = im.spriteSettings.pieceOfHeart

local itemGetFunc = function ()
  session.save.piecesOfHeart = math.min(session.save.piecesOfHeart + 1, GCON.maxPOHs)
  if pl1 then
    pl1:readSave()
    pl1.health = pl1.maxHealth
  end
  -- session.addItem("testi")
  -- session.addItem("testi2")
  -- session.addItem("testi2")
  session.addItem("ringWindSlice")
  session.addItem("ringMyriadCuts")
  session.addItem("ringFocus")
  session.addItem("ringMage")
  session.addItem("ringOld")
  session.addItem("ringScreen")
  session.addItem("ringGrey")
  session.addItem("ringVignette")
  session.addItem("ringRubber")
  session.addItem("ringGlide")
  session.addItem("ringTimeflow")
  session.addItem("keyLyre")
  for _ = 1, 22 do
    session.addItem("mateMagicDust")
    session.addItem("mateBlastSeed")
    session.addItem("focusDoll")
  end
  session.addItem("keySpellbook")
end

gottenItem.itemInfo = {
  itemSprite = sprite,
  information = "You got several stuff!",
  comment = "Well done " .. session.save.saveName .. "!",
  itemGetEffect = itemGetFunc,
}

return gottenItem
