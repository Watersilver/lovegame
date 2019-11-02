local im = require "image"
local altSkins = require "altSkins"

local items = {}


-- Rings should only affect save directly via equippedRing
-- Everything else via session, (effects applied on init when loading)
local function useRing(ringid)
  if ringid == session.save.equippedRing then
    -- unequip
    items[ringid].unequip()
    session.save.equippedRing = nil
  else
    -- unequip old, equip new
    if session.save.equippedRing then
      items[session.save.equippedRing].unequip()
    end
    items[ringid].equip()
    session.save.equippedRing = ringid
  end
end


items.testi = {
  name = "Ganon's penis",
  description = "Quite large",
  use = function()
    session.usedItemComment = "You ate Ganon's dick!"
    session.removeItem("testi")
  end
}

items.testi2 = {
  name = "Ganon's testis",
  description = "Basketball",
  use = function()
    session.usedItemComment = "You ate Ganon's testicle!"
    session.removeItem("testi2")
  end
}

items.ringMageForm = {
  name = "(R) Mage Form",
  description = "Transform into\nMage!",
  equip = function()
    session.usedItemComment = "Equipped Ring of Mage\nForm!"
    for i, plSprite in ipairs(im.spriteSettings.playerSprites) do
      im.replace_sprite(plSprite[1], altSkins.origPlayerSprites[i])
    end
    -- force change immediately
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Ring of Mage\nForm!"
    im.reloadPlSprites()
    -- force change immediately
  end
}
items.ringMageForm.use = function()
  useRing("ringMageForm")
end


return items
