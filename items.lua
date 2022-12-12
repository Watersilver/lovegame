local im = require "image"
local shdrs = require "Shaders.shaders"
local altSkins = require "altSkins"
local snd = require "sound"
local inv = require "inventory"

local function forceCloseInv()
  if inv.isOpen() then session.forceCloseInv = true end
end

local items = {}

-- max name line: nnnnnnnnnnnnnnnn

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
    notIdleComment = notIdleComment or "You must stand idle to do that."
    if pl1.movement_state.state == "normal" and pl1.animation_state.state:find("still") then
      forceCloseInv()
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

local function useWhenStill(useCallback, failedToUseCallback)
  if pl1 then
    if pl1.movement_state.state == "normal" and
    pl1.animation_state.state:find("still")
    then
      forceCloseInv()
      session.usedItemComment = ""
      if useCallback then useCallback() end
    else
      session.usedItemComment = "You must stand idle to do that."
      if failedToUseCallback then return failedToUseCallback() end
      return "error"
    end
  end
end


items.useItem = function(itemid)
  if items[itemid] and items[itemid].use then
    local glsound = items[itemid].use()
    if not items[itemid].handleUseSound then
      if glsound then
        snd.play(glsounds[glsound])
      else
        snd.play(glsounds.useItem)
      end
    end
    return true
  else
    snd.play(glsounds.error)
    return false
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
-- items.keySpellbook = {
--   name = "Spellbook",
--   description =
--   "A Book on how to use\n\z
--   focuses to control\n\z
--   the effects of the\n\z
--   magic dust.",
--   limit = 1
-- }

items.keyLyre = {
  name = "Lyre",
  description = "wat",
  limit = 1,
  useCallback = function()
    if pl1 then
      pl1.animation_state:change_state(pl1, "noDt", "downharp")
    end
  end,
  failedToUseCallback = function()
    if pl1 and pl1.animation_state.state == "downharp" then
      forceCloseInv()
      session.usedItemComment = ""
      pl1.animation_state:change_state(pl1, "noDt", "downstill")
    else
      return "error"
    end
  end,
  use = function()
    return useWhenStill(
      items.keyLyre.useCallback,
      items.keyLyre.failedToUseCallback
    )
  end
}

-- Material
items.mateBlastSeed = {
  name = "Blast seed",
  description = "Used to cast magic blast",
  limit = 10
}

items.mateMagicDust = {
  name = "Magic dust",
  description = "Sprinkle for variety of effects.\n\n\n\n\n\n*Highly volatile and unpredictable",
  limit = 20
}

-- Focuses
items.focusDoll = {
  name = "Doll",
  description = function()
    local desc =
    "Dolls like this were \z
    placed in kids' rooms, \z
    to confuse nightmares."
    -- if session.save.keySpellbook then
    if session.save.hasMystery then
      desc = desc .. "\n\nSpell focus for Decoy"
    end
    return desc
  end,
  use = function()
    if session.save.hasMystery then
      -- session.usedItemComment =
      -- "You say the magic words\n\z
      -- and it disintegrates in\n\z
      -- a flash of light!\n\z
      -- \n\z
      -- Decoy charged"
      -- session.removeItem("focusDoll")
      -- session.focus = "decoy"
      if session.save.focus == "focusDoll" then
        session.usedItemComment = "Unequipped doll as spell focus"
        session.save.focus = nil
      else
        session.usedItemComment = "Equipped doll as spell focus"
        session.save.focus = "focusDoll"
      end
    else
      session.save.dollFail = session.save.dollFail and session.save.dollFail + 1 or 0
      if session.save.dollFail < 10 or session.save.dollFail > 20 then
        session.usedItemComment = "You can't use it like that"
      elseif session.save.dollFail < 11 then
        session.usedItemComment = "You can't use it like that\n\nHow many times do I need to tell you?"
      elseif session.save.dollFail < 12 then
        session.usedItemComment = "You chew on it. Still doesn't work"
      elseif session.save.dollFail < 13 then
        session.usedItemComment = "You play with the doll.\nNothing happens"
      elseif session.save.dollFail < 14 then
        session.usedItemComment = "You keep playing with the doll until the world blows up. You are dead now.\n\nGame Over"
      elseif session.save.dollFail < 15 then
        session.usedItemComment = "It eats your face off"
      elseif session.save.dollFail < 16 then
        session.usedItemComment = "It consumes your soul.\n\nGame Over"
      elseif session.save.dollFail < 17 then
        session.usedItemComment = "You can't fit it there"
      elseif session.save.dollFail < 18 then
        session.usedItemComment = "Some kids come and ask to \z
        play with you.\nYou make your dolls fight and yours wins.\n\z
        The kids are so angry they kill you.\n\nGame Over"
      elseif session.save.dollFail < 19 then
        session.usedItemComment = "You choke on it"
      elseif session.save.dollFail < 20 then
        session.usedItemComment = "It WILL blow up and you WILL be sorry!!"
      else
        session.usedItemComment = "BOOM"
        forceCloseInv()
        if pl1 then
          local mdust = require "GameObjects.Items.mdust"
          mdust.functions[GCON.md.reaction.kaboom](pl1)
        end
      end
      return "error"
    end
  end,
  limit = 1
}

-- Recovery
items.foodFrittata = {
  name = "Frittata",
  description = "It's not a verb.",
  use = function()
    return useFood("foodFrittata", 1, 4, "It was Italian omelette with diced meat and vegetables.")
  end,
}

-- Rings
-- Gameplay
items.ringWindSlice = {
  name = "Windslice Ring",
  description = "Slice with sword at first recall of mark.",
  equip = function()
    session.usedItemComment = "Equipped Windslice Ring!"
    session.ringRecallSlice = 1
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Windslice Ring!"
    session.ringRecallSlice = nil
  end,
  use = function()
    useRing("ringWindSlice")
  end
}

items.ringMyriadCuts = {
  name = "Myriad Cuts Ring",
  description = "Slice with sword at every recall.",
  equip = function()
    session.usedItemComment = "Equipped Myriad Cuts Ring!"
    session.ringRecallSlice = math.huge
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Myriad Cuts Ring!"
    session.ringRecallSlice = nil
  end,
  use = function()
    useRing("ringMyriadCuts")
  end
}

items.ringTimeflow = {
  name = "Timeflow Ring",
  description = "Helps with reflexes a lot!",
  equip = function()
    session.usedItemComment = "Equipped Timeflow Ring!"
    session.ringTimeflow = 1.2
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Timeflow Ring!"
    session.ringTimeflow = nil
  end,
  use = function()
    useRing("ringTimeflow")
  end
}

items.ringFocus = {
  name = "Focus Ring",
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
  name = "Rubber Ring",
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
  name = "Glide Ring",
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
  name = "Mage Ring",
  description = "Transform into Mage!",
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
  name = "Old Ring",
  description = "See the world through a different lens!",
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
  name = "Screen Ring",
  description = "See the world through a different lens!",
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
  name = "Grey Ring",
  description = "See the world through a different lens!",
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
  name = "Vignette Ring",
  description = "See the world through a different lens!",
  equip = function()
    session.usedItemComment = "Equipped Vignette Ring!"
    session.ringShader = shdrs.vignette
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Vignette Ring!"
    session.ringShader = nil
  end,
  use = function()
    useRing("ringVignette")
  end
}


return items
