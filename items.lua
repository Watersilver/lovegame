local im = require "image"
local shdrs = require "Shaders.shaders"
local altSkins = require "altSkins"
local inp = require "input"
local snd = require "sound"

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

local function useFood(type, bonus, duration, eatComment, notIdleComment)
  if pl1 then
    eatComment = eatComment or "Yum!"
    notIdleComment = notIdleComment or "You must stand idle\nto do that."
    if pl1.movement_state.state == "normal" and pl1.animation_state.state:find("still") then
      session.forceCloseInv = true
      session.usedItemComment = eatComment
      session.removeItem(type)
      pl1.item_health_bonus = bonus
      pl1.item_use_duration = duration
      pl1.movement_state:change_state(pl1, "noDt", "using_item")
      pl1.animation_state:change_state(pl1, "noDt", "downeating")
      snd.play(glsounds.useItem)
    else
      session.usedItemComment = notIdleComment
      snd.play(glsounds.error)
    end
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

-- Somatic
items.somaBlastSeed = {
  name = "Blast seed",
  description = "Used to cast magic blast",
  limit = 10
}

-- Recovery
items.foodFrittata = {
  name = "Frittata",
  description = "It's not a verb.",
  use = function()
    useFood("foodFrittata", 1, 4, "It was Italian omelette\nwith diced meat\nand vegetables")
  end,
  handleUseSound = true
}

-- Rings
-- Gameplay
items.ringFocus = {
  name = "R. Focus Ring",
  description = "Helps with reflexes!",
  equip = function()
    session.usedItemComment = "Equipped Focus Ring!"
    session.ringSlomo = 0.8
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
