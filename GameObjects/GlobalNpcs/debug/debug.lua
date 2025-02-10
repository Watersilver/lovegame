local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local test1 = require 'ConversationData.data.debug_convo'
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'
local asp = require "GameObjects.Helpers.add_spell"
local game = require 'game'
local im = require 'image'

local function depowerPlayer()
  session.save.hasSword = nil
  session.save.hasJump = nil
  session.save.hasMissile = nil
  session.save.hasMark = nil
  session.save.hasRecall = nil
  session.save.hasGrip = nil
  session.save.hasBomb = nil
  session.save.hasSpeed = nil
  session.save.hasMystery = nil
  asp.emptySpellSlots()
  session.save.dinsPower = false
  session.save.nayrusWisdom = false
  session.save.faroresCourage = false
  session.save.hotkeys = false
  session.save.customMarkAvailable = false
  session.save.customMissileAvailable = false
  session.save.customSwordAvailable = false
  session.save.customTunicAvailable = false
  session.save.walkOnWater = false
  session.save.playerGlowAvailable = false
  session.save.armorLvl = 0
  session.save.magicLvl = 0
  session.save.athleticsLvl = 0
  session.save.swordLvl = 0
  session.save.piecesOfHeart = 0
end

local NPC = {}

function NPC.initialize(instance)
  instance.conversation = conv.addNew(test1, instance)
  instance.conversation:setIdToObject('debug', instance)
  instance.type = ''
  instance.ability = ''
  instance.boss = 0
  instance.sprite_info = im.spriteSettings.npcTest3Sprites
end

NPC.functions = {
  load = function (self)
    self.conversation:listen('goto_sidescroll', function()
      local trans = {
        type = "whiteScreen",
        progress = 0,
        roomTarget = '',
        playa = pl1,
        desx = 0,
        desy = 0
      }
      trans.roomTarget = "Rooms/sideScrollTest.lua"
      trans.desx = 24
      trans.desy = 350

      if not game.transitioning then
        game.transition(trans)
      end
    end)
    self.conversation:listen('type', function(payload)
      self.type = payload
    end)
    self.conversation:listen('ability', function(payload)
      self.ability = payload
    end)
    self.conversation:listen('value', function(payload)
      if self.type == 'spell' then
        local enable = payload == 'enable'
        if self.ability == 'sword' then
          session.save.hasSword = enable and "sword" or nil
        elseif self.ability == 'jump' then
          session.save.hasJump = enable and "jump" or nil
        elseif self.ability == 'missile' then
          session.save.hasMissile = enable and "missile" or nil
        elseif self.ability == 'markrecall' then
          session.save.hasMark = enable and "mark" or nil
          session.save.hasRecall = enable and "recall" or nil
        elseif self.ability == 'grip' then
          session.save.hasGrip = enable and "grip" or nil
        elseif self.ability == 'bomb' then
          session.save.hasBomb = enable and "bomb" or nil
        elseif self.ability == 'speed' then
          session.save.hasSpeed = enable and "speed" or nil
        elseif self.ability == 'mystery' then
          session.save.hasMystery = enable and "mystery" or nil
        end
      elseif self.type == 'special' then
        local enable = payload == 'enable'
        if self.ability == 'power' then
          session.save.dinsPower = enable
        elseif self.ability == 'wisdom' then
          session.save.nayrusWisdom = enable
        elseif self.ability == 'courage' then
          session.save.faroresCourage = enable
        elseif self.ability == 'hotkeys' then
          session.save.hotkeys = enable
        elseif self.ability == 'waterwalk' then
          session.save.walkOnWater = enable
        elseif self.ability == 'light' then
          session.save.playerGlowAvailable = enable
        elseif self.ability == 'customize' then
          session.save.customMarkAvailable = enable
          session.save.customMissileAvailable = enable
          session.save.customSwordAvailable = enable
          session.save.customTunicAvailable = enable
        end
      elseif self.type == 'skill' then
        if self.ability == 'armor' then
          session.save.armorLvl = tonumber(payload)
        elseif self.ability == 'swordspeed' then
          session.save.swordLvl = tonumber(payload)
        elseif self.ability == 'missilespeed' then
          session.save.magicLvl = tonumber(payload)
        elseif self.ability == 'athlectics' then
          session.save.athleticsLvl = tonumber(payload)
        end
      elseif self.type == 'life' then
        session.save.piecesOfHeart = tonumber(payload) * 4
      end
      if pl1 then pl1:readSave() end
    end)
    self.conversation:listen('bosschoice', function(payload)
      self.boss = tonumber(payload)
    end)
    self.conversation:listen('lvlchoice', function(lvl)
      if not pl1 then return end

      if lvl ~= "skip" then
        depowerPlayer()

        if self.boss == 1 then
          session.save.hasGrip = "grip"
        elseif self.boss == 2 then
          session.save.hasSword = "sword"
          session.save.hasMissile = "missile"
        elseif self.boss == 3 then
          session.save.hasBomb = "bomb"
        elseif self.boss == 4 then
          session.save.hasGrip = "grip"
          session.save.hasJump = "jump"
          session.save.hasSword = "sword"
        elseif self.boss == 5 then
          session.save.hasMystery = "mystery"
        end

        if lvl == "decent" or lvl == "prepared" then
          session.save.armorLvl = 1
          session.save.magicLvl = 1
          session.save.athleticsLvl = 1
          session.save.swordLvl = 1
          session.save.piecesOfHeart = math.min(3 * 4, GCON.maxPOHs)

          if self.boss == 1 then
            session.save.dinsPower = true
            session.save.hasSpeed = "speed"
            session.save.athleticsLvl = 2
          elseif self.boss == 2 then
            session.save.hasJump = "jump"
            session.save.magicLvl = 2
            session.save.playerGlowAvailable = true
            session.save.hasMark = "mark"
            session.save.hasRecall = "recall"
            session.save.faroresCourage = true
          elseif self.boss == 3 then
            session.save.hasSpeed = "speed"
            session.save.nayrusWisdom = true
          elseif self.boss == 4 then
            session.save.hasMissile = "missile"
            session.save.hasSpeed = "speed"
            session.save.hasMark = "mark"
            session.save.hasRecall = "recall"
            session.save.faroresCourage = true
            session.save.playerGlowAvailable = true
          elseif self.boss == 5 then
          end
        end

        if lvl == "prepared" then
          session.save.armorLvl = 2
          session.save.magicLvl = 2
          session.save.athleticsLvl = 2
          session.save.swordLvl = 2
          session.save.piecesOfHeart = math.min(6 * 4, GCON.maxPOHs)

          if self.boss == 1 then
            session.save.nayrusWisdom = true
            session.save.faroresCourage = true
            session.save.athleticsLvl = 3
          elseif self.boss == 2 then
            session.save.nayrusWisdom = true
            session.save.dinsPower = true
            session.save.hasBomb = "bomb"
          elseif self.boss == 3 then
            session.save.hasJump = "jump"
            session.save.dinsPower = true
          elseif self.boss == 4 then
            session.save.hasMissile = "missile"
            session.save.hasSpeed = "speed"
            session.save.hasMark = "mark"
            session.save.hasRecall = "recall"
            session.save.faroresCourage = true
            session.save.playerGlowAvailable = true
          elseif self.boss == 5 then
          end
        end

        if lvl == "decked_out" then
          session.save.armorLvl = 3
          session.save.magicLvl = 3
          session.save.athleticsLvl = 3
          session.save.swordLvl = 3
          session.save.hasSword = "sword"
          session.save.hasJump = "jump"
          session.save.hasMissile = "missile"
          session.save.hasMark = "mark"
          session.save.hasRecall = "recall"
          session.save.hasGrip = "grip"
          session.save.hasBomb = "bomb"
          session.save.hasSpeed = "speed"
          session.save.hasMystery = "mystery"
          session.save.dinsPower = true
          session.save.nayrusWisdom = true
          session.save.faroresCourage = true
          session.save.customMarkAvailable = true
          session.save.customMissileAvailable = true
          session.save.customSwordAvailable = true
          session.save.customTunicAvailable = true
          session.save.walkOnWater = true
          session.save.playerGlowAvailable = true
          session.save.hotkeys = true
          session.save.piecesOfHeart = GCON.maxPOHs
        end

        if pl1 then pl1:readSave() end
      end

      if pl1 then
        pl1:addHealth((session.save.piecesOfHeart or GCON.maxPOHs) * 2)
      end

      local trans = {
        type = "whiteScreen",
        progress = 0,
        roomTarget = '',
        playa = pl1,
        desx = 0,
        desy = 0
      }

      if self.boss == 1 then
        trans.roomTarget = "Rooms/boss1room.lua"
        trans.desx = 72
        trans.desy = 120
      elseif self.boss == 2 then
        trans.roomTarget = "Rooms/boss2room.lua"
        trans.desx = 200
        trans.desy = 200
      elseif self.boss == 3 then
        trans.roomTarget = "Rooms/boss3room.lua"
        trans.desx = 263
        trans.desy = 480
      elseif self.boss == 4 then
        trans.roomTarget = "Rooms/testtesttest.lua"
        trans.desx = 158
        trans.desy = 24
      elseif self.boss == 5 then
        trans.roomTarget = "Rooms/boss5room.lua"
        trans.desx = 200
        trans.desy = 232
      end

      if not game.transitioning then

        for _, data in pairs(require "collectables".data) do
          session.save['dropfanfare_'..data.id] = 1
        end

        game.transition(trans)
      end
    end)
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
