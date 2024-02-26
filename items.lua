local im = require "image"
local shdrs = require "Shaders.shaders"
local altSkins = require "altSkins"
local snd = require "sound"
local inv = require "inventory"
local game= require "game"

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

---@class RecoverySettings
---@field onUse? fun()
---@field power? number
---@field duration? number
---@field gradual? boolean
---@field usageText? string
---@field notIdleText? string
---@field immobilizes? boolean
---@field animation? boolean
---@field mustBeStill? boolean

---comment
---@param id string
---@param settings RecoverySettings
local function useRecovery(id, settings)
  if pl1 then
    local ut = settings.usageText or "Yum!"
    local nit = settings.notIdleText or (settings.mustBeStill and "You must stand idle to do that." or "Can't use this right now.")
    local useSuccess = pl1.movement_state.state == "normal"

    if settings.mustBeStill then
      useSuccess = useSuccess and pl1.animation_state.state:find("still")
    else
      useSuccess = useSuccess
      and (
        pl1.animation_state.state:find("still")
        or pl1.animation_state.state:find("walk")
        or pl1.animation_state.state:find("halt")
        or pl1.animation_state.state:find("push")
        or pl1.animation_state.state:find("jump")
        or pl1.animation_state.state:find("fall")
      )
    end
    if useSuccess then
      if settings.immobilizes then
        forceCloseInv()
        pl1.movement_state:change_state(pl1, "noDt", "using_item")
        pl1.animation_state:change_state(pl1, "noDt", "downrecovery")
        pl1.item_recovery_animation = settings.animation
        pl1.item_use_duration = settings.duration or 4
        if not settings.gradual then pl1.item_health_bonus = settings.power or 1 end
      end

      session.usedItemComment = ut

      if settings.onUse then
        settings.onUse()
      else
        session.removeItem(id)
      end

      if settings.gradual then
        local activeDur = 0
        local regen = (settings.power or 1) / (settings.duration or 4)
        pl1:addActiveEffect({
          onAdd = function()
            pl1.regen = pl1.regen + regen
          end,
          onRemove = function()
            pl1.regen = pl1.regen - regen
          end,
          update = function(effect, _, dt)
            local expired = activeDur > (settings.duration or 4)
            local stopped = settings.immobilizes and pl1.movement_state.state ~= "using_item"
            if expired or stopped then
              pl1:removeActiveEffect(effect)
            end
            activeDur = activeDur + dt
          end
        })
      end
    else
      session.usedItemComment = nit
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
items.keyBedroll = {
  name = "Bedroll",
  description =
  "Unroll and sleep, simple as that!",
  limit = 1,
  use = function()
    if pl1 then
      if pl1.movement_state.state == "normal" and
      pl1.animation_state.state:find("still") and
      not game.room.timeDoesntPass
      then
        forceCloseInv()
        session.usedItemComment = ""
        session.usedItemComment = nil
        if pl1 then
          pl1.movement_state:change_state(pl1, "noDt", "stand_still")
          pl1.animation_state:change_state(pl1, "noDt", "sleeping")
        end
      else
        -- if not game.isWorldScreen() then
        --   session.usedItemComment = "Can only use that in overworld."
        -- elseif
        if pl1.animation_state.state == 'sleeping' then
          session.usedItemComment = "You're already using that."
        elseif game.room.timeDoesntPass then
          session.usedItemComment = "Can't do that here."
        else
          session.usedItemComment = "You must stand idle to do that."
        end
        return "error"
      end
    end
  end
}

items.keyLyre = {
  name = "Lyre",
  description = "Select to play, escape or backspace to stop.",
  limit = 1,
  useCallback = function()
    session.usedItemComment = nil
    if pl1 then
      pl1.animation_state:change_state(pl1, "noDt", "downharp")
    end
  end,
  failedToUseCallback = function()
    if pl1 and pl1.animation_state.state == "downharp" then
      forceCloseInv()
      session.usedItemComment = nil
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
    return useRecovery('foodFrittata', {
      power = 1,
      duration = 4,
      usageText = "It was Italian omelette with diced meat and vegetables.",
      gradual = true,
      immobilizes = true,
    })
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
    for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
      local sname = plSprite[1]:gsub("Witch/", '')
      local s
      for _, altSpr in ipairs(altSkins.origPlayerSprites) do
        if altSpr[1]:gsub("WitchOrig/", '') == sname then s = altSpr end
      end
      if s then
        im.replace_sprite(plSprite[1], s)
      end
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

-- other effects
items.ringRainbow = {
  name = "Rainbow Ring",
  description = "Make your life more colourful!",
  equip = function()
    session.usedItemComment = "Equipped Rainbow Ring!"
    session.wornRing = 'ringRainbow'
  end,
  unequip = function()
    session.usedItemComment = "Unequipped Rainbow Ring!"
    session.wornRing = nil
  end,
  use = function()
    useRing("ringRainbow")
  end
}


return items
