local im = require "image"
local shdrs = require "Shaders.shaders"
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
    session.usedItemComment = "You ate Ganon's penis!"
    session.removeItem("testi")
  end
}

items.testi2 = {
  name = "Ganon's testis",
  description = "Basketball",
  use = function()
    session.usedItemComment = "You ate Ganon's testicle!"
    session.removeItem("testi2")
    session.drug = {duration = 15, slomo = 0.5, shader = shdrs.drugShader}
    session.drug.maxDuration = session.drug.duration
  end
}

-- Rings
-- Gameplay
items.ringFocus = {
  name = "R. Focus Ring",
  description = "Helps with reflexes!",
  equip = function()
    session.usedItemComment = "Equipped Focus Ring!"
    session.ringSlomo = 1 / 1.2
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Focus Ring!"
    session.ringSlomo = nil
  end,
  use = function()
    useRing("ringFocus")
  end
}

-- Skins
items.ringMage = {
  name = "R. Mage Ring",
  description = "Transform into\nMage!",
  equip = function()
    session.usedItemComment = "Equipped Mage Ring!"
    for i, plSprite in ipairs(im.spriteSettings.playerSprites) do
      im.replace_sprite(plSprite[1], altSkins.origPlayerSprites[i])
    end
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Mage Ring!"
    im.reloadPlSprites()
  end,
  use = function()
    useRing("ringMage")
  end
}

-- screen effects
items.ringOld = {
  name = "R. Old Ring",
  description = "See the world\nthrough a\ndifferent lens!",
  equip = function()
    session.usedItemComment = "Equipped Old Ring!"
    session.ringShader = shdrs.sepia
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Old Ring!"
    session.ringShader = nil
  end,
  use = function()
    useRing("ringOld")
  end
}

items.ringScreen = {
  name = "R. Screen Ring",
  description = "See the world\nthrough a\ndifferent lens!",
  equip = function()
    session.usedItemComment = "Equipped Screen Ring!"
    session.ringShader = shdrs.oldScreen
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Screen Ring!"
    session.ringShader = nil
  end,
  use = function()
    useRing("ringScreen")
  end
}

items.ringGrey = {
  name = "R. Grey Ring",
  description = "See the world\nthrough a\ndifferent lens!",
  equip = function()
    session.usedItemComment = "Equipped Grey Ring!"
    session.ringShader = shdrs.grayscale
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Grey Ring!"
    session.ringShader = nil
  end,
  use = function()
    useRing("ringGrey")
  end
}

items.ringVignette = {
  name = "R. Vignette Ring",
  description = "See the world\nthrough a\ndifferent lens!",
  equip = function()
    session.usedItemComment = "Equipped Vignette\nRing!"
    session.ringShader = shdrs.vignette
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Vignette\nRing!"
    session.ringShader = nil
  end,
  use = function()
    useRing("ringVignette")
  end
}


return items
