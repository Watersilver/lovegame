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
    else
      session.usedItemComment = notIdleComment
      return "error"
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

-- Key
items.keySpellbook = {
  name = "Spellbook",
  description =
  "A Book on how to use\n\z
  focuses to control\n\z
  the effects of the\n\z
  magic dust.",
  limit = 1
}

-- Material
items.mateBlastSeed = {
  name = "Blast seed",
  description = "Used to cast magic blast",
  limit = 10
}

items.mateMagicDust = {
  name = "Magic dust",
  description = "Sprinkle for variety of\neffects\n\n\n\n\n\n*Highly volatile and\nunpredictable",
  limit = 20
}

-- Focuses
items.focusDoll = {
  name = "Doll",
  description = function()
    local desc =
    "Dolls like this were\n\z
    placed in kids' rooms,\n\z
    to confuse nightmares."
    if session.save.keySpellbook then
      desc = desc .. "\n\nSpell focus for Decoy"
    end
    return desc
  end,
  use = function()
    if session.save.keySpellbook then
      session.usedItemComment =
      "You say the magic words\n\z
      and it disintegrates in\n\z
      a flash of light!\n\z
      \n\z
      Decoy charged"
      session.removeItem("focusDoll")
      session.focus = "decoy"
    else
      session.save.dollFail = session.save.dollFail and session.save.dollFail + 1 or 0
      if session.save.dollFail < 10 or session.save.dollFail > 20 then
        session.usedItemComment = "You can't use it like that"
      elseif session.save.dollFail < 11 then
        session.usedItemComment = "You can't use it like that\n\nHow many times do I need\nto tell you?"
      elseif session.save.dollFail < 12 then
        session.usedItemComment = "You chew on it. Still\ndoesn't work"
      elseif session.save.dollFail < 13 then
        session.usedItemComment = "You play with the doll.\nNothing happens"
      elseif session.save.dollFail < 14 then
        session.usedItemComment = "You keep playing with the\nuntil the world blows up.\nYou are dead now.\n\nGame Over"
      elseif session.save.dollFail < 15 then
        session.usedItemComment = "It eats your face off"
      elseif session.save.dollFail < 16 then
        session.usedItemComment = "It consumes your soul.\n\nGame Over"
      elseif session.save.dollFail < 17 then
        session.usedItemComment = "You can't fit it there"
      elseif session.save.dollFail < 18 then
        session.usedItemComment = "Some kids come and ask to\n\z
        play with you.\nYou make your dolls\nfight and yours wins.\n\z
        The kids are so angry\nthey kill you.\n\nGame Over"
      elseif session.save.dollFail < 19 then
        session.usedItemComment = "You choke on it"
      elseif session.save.dollFail < 20 then
        session.usedItemComment = "It WILL blow up and\nyou WILL be sorry!!"
      else
        session.usedItemComment = "BOOM"
        session.forceCloseInv = true
        if pl1 then
          local mdust = require "GameObjects.Items.mdust"
          mdust.functions.chainReaction(pl1)
          session.removeItem("focusDoll")
        end
      end
      return "error"
    end
  end,
  limit = 10
}

-- Recovery
items.foodFrittata = {
  name = "Frittata",
  description = "It's not a verb.",
  use = function()
    return useFood("foodFrittata", 1, 4, "It was Italian omelette\nwith diced meat\nand vegetables")
  end,
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

items.ringRubber = {
  name = "R. Rubber Ring",
  description = "Makes you bouncy!",
  equip = function()
    session.usedItemComment = "Equipped Rubber Ring!"
    session.bounceRing = true
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Rubber Ring!"
    session.bounceRing = nil
  end,
  use = function()
    useRing("ringRubber")
  end
}

items.ringGlide = {
  name = "R. Glide Ring",
  description = "Double jump!",
  equip = function()
    session.usedItemComment = "Equipped Glide Ring!"
    session.jumpL2 = true
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Glide Ring!"
    session.jumpL2 = nil
  end,
  use = function()
    useRing("ringGlide")
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
