local u = require 'utilities'
local im = require "image"
local snd = require 'sound'
local game = require 'game'
local trans = require 'transitions'
local lighting = require "ScreenEffects.lighting.lighting"
local asp = require "GameObjects.Helpers.add_spell"
local ps = require "physics_settings"

---@class CollectableData
---@field id string
---@field effect fun(self) applies no matter how you got item
---@field nonFanfareEffect? fun(self) applies only when picked as a drop that doesn't trigger a fanfare
---@field fanfareData {info: string | (fun(self): string), comment: string | (fun(self): string), pl_image_index: number}
---@field sprite_info any
---@field image_speed number
---@field frame_speed_mods? {[number]: number}
---@field shadowHeightMod? number
---@field load? fun(self)
---@field fanfare_update? fun(self, dt) should only run during display fanfare
---@field unstoppable_update? fun(self, dt) should run for both drop and fanfare during the unstoppable update callback
---@field both_update? fun(self, dt) should run for both drop and fanfare, but for the drop it should be pausable
---@field update? fun(self, dt) should run only for drop because fanfare has time stopped
---@field dropTriggersFanfare 'never' | 'once' | 'always'
---@field type 'item' | 'spell' | 'other'

---@type {[string]: CollectableData}
local data = {}


data.testitems = {
  id = 'testitems',
  type = 'item',
  image_speed = 0.2,
  sprite_info = im.spriteSettings.pieceOfHeart,
  dropTriggersFanfare = 'always',
  fanfareData = {info = 'You got a bunch of items for testing purposes!', comment = 'How nice!', pl_image_index = 1},
  effect = function (self)
    -- session.addItem("testi")
    -- session.addItem("testi2")
    -- session.addItem("testi2")
    session.addItem("ringWindSlice")
    session.addItem("ringMyriadCuts")
    session.addItem("ringFocus")
    session.addItem("ringOld")
    session.addItem("ringScreen")
    session.addItem("ringGrey")
    session.addItem("ringVignette")
    session.addItem("ringRubber")
    session.addItem("ringGlide")
    session.addItem("ringTimeflow")
    session.addItem("ringRainbow")
    session.addItem("keyLyre")
    session.addItem("keyBedroll")
    session.addItem("focusDoll")
    for _ = 1, 22 do
      session.addItem("foodFrittata")
    end
    session.addItem("keySpellbook")
  end
}


data.magic_missile = {
  id = 'magic_missile',
  type = 'spell',
  image_speed = 0,
  sprite_info = im.spriteSettings.magic_missile_on_menu,
  nonFanfareEffect = function ()
    snd.play(glsounds.getHeart)
  end,
  effect = function()
    session.save.hasMissile = "missile"
    asp.emptySpellSlots()
    if pl1 then pl1:readSave() end
  end,
  fanfareData = {info = 'You found the magic missile!', comment = 'Hold the magic missile key to fire away!', pl_image_index = 0},
  dropTriggersFanfare = 'always'
}


data.heart = {
  id = 'heart',
  type = 'other',
  image_speed = 0.2,
  sprite_info = im.spriteSettings.dropHeart,
  shadowHeightMod = -3,
  nonFanfareEffect = function ()
    snd.play(glsounds.getHeart)
  end,
  effect = function()
    if not pl1 then return end
    if pl1 then pl1:addHealth(1) end
  end,
  fanfareData = {info = 'You found a health mushroom!', comment = 'It restores one health!', pl_image_index = 1},
  dropTriggersFanfare = 'once'
}


data.fairy = {
  id = 'fairy',
  type = 'other',
  load = function(self)
    self.zvel = 0
    self.bounceOnce = false
    self.body:setType('dynamic')

    self.maxspeed = 80
    self.zo = - 2
    self.behaviourTimer = 0
    self.gravity = 0
    self.counter = 0

    require "GameObjects.objects".change_layer(self, 19)
  end,
  update = function(self, dt)
    local ebh = require "enemy_behaviours"
    local td = (require "movement").top_down
    local sh = require "GameObjects.shadow"

    -- Do necessary stuff
    self.behaviourTimer = self.behaviourTimer - dt
    self.invulnerableEnd = nil
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
    self.speed = u.magnitude2d(self.vx, self.vy)

    self.x_scale = self.x > 0 and 1 or -1

    -- Movement behaviour
    ebh.bounceOffScreenEdge(self)
    if self.behaviourTimer < 0 then
      ebh.beehaviour(self)
      self.behaviourTimer = love.math.random(2)
    end
    td.analogueWalk(self, dt)
    if self.direction then
      if math.cos(self.direction) > 0 then
        self.x_scale = -1
      else
        self.x_scale = 1
      end
    end

    sh.handleShadow(self)
  end,
  both_update = function (self, dt)
    self.counter = self.counter + dt
  end,
  unstoppable_update = function (self, dt)
    if not self.isDrop then return end
    lighting.applyLight{
      type = 'dynamic',
      x = self.x,
      y = self.y,
      dynamic_options = {radius = 9 + math.sin(6 * self.counter)}
    }
    lighting.applyLight{
      type = 'dynamic',
      x = self.x,
      y = self.y,
      dynamic_options = {radius = 11 + math.sin(6 * self.counter * 0.628)},
      rgba = {r = 1, g = 0.5, b = 0.5, a = 1}
    }
    lighting.applyLight{
      type = 'dynamic',
      x = self.x,
      y = self.y,
      dynamic_options = {radius = 13 + math.sin(6 * self.counter * 0.314)},
      rgba = {r = 1, g = 0, b = 0, a = 1}
    }
  end,
  shadowHeightMod = -3,
  image_speed = 0.1,
  sprite_info = im.spriteSettings.dropFairy,
  effect = function()
    if not pl1 then return end
    pl1:addHealth(8)
  end,
  nonFanfareEffect = function ()
    snd.play(glsounds.getHeart)
  end,
  fanfareData = {info = 'You found a fairy! It restores 8 health!', comment = 'It flies away having healed you.', pl_image_index = 0},
  dropTriggersFanfare = 'once'
}


data.piece_of_heart = {
  id = 'piece_of_heart',
  type = 'other',
  image_speed = 0.15,
  sprite_info = im.spriteSettings.pieceOfHeart,
  nonFanfareEffect = function ()
    snd.play(glsounds.heartContainer)
  end,
  effect = function(self)
    if not pl1 then return end
    if self.isDrop then
      session.save.randomPiecesOfHeart = (session.save.randomPiecesOfHeart or 0) + 1
    end
    session.save.piecesOfHeart = math.min(session.save.piecesOfHeart + 1, GCON.maxPOHs)
    pl1:readSave()
    pl1.health = pl1.maxHealth
  end,
  load = function (self)
    self.counter = 0
  end,
  both_update = function (self, dt)
    self.counter = self.counter + dt
  end,
  unstoppable_update = function (self, dt)
    if not self.isDrop then return end
    lighting.applyLight{
      type = 'dynamic',
      x = self.x,
      y = self.y,
      dynamic_options = {radius = 12 + 4 * math.sin(10 * self.counter)},
      rgba = {r = 1, g = 0, b = 0.75, a = 1}
    }
    lighting.applyLight{
      type = 'dynamic',
      x = self.x,
      y = self.y,
      dynamic_options = {radius = 28 + 6 * math.sin(10 * self.counter * 0.628)},
      rgba = {r = 0.75, g = 0, b = 1, a = 0.75}
    }
  end,
  -- TODO: have some special comment for random drops to help find them and count remaining
  -- This was the old one:
  -- local function commentDeterminer()
  --   local poh = session.save.piecesOfHeart or 0
  --   local incomingHeartContainer = math.floor((poh + 1) / 4) == (poh + 1) / 4
  --   if poh >= GCON.maxPOHs then return "Wait, there shouldn't be any more of those... \nUnfortunately it has no effect..." end
  --   if poh + 1 >= GCON.maxPOHs then return "You discovered the final Life Wisp! \nCongratulations!" end
  --   return incomingHeartContainer and "Health increased by one Heart!" or "Collect 4 to extend maximum health by one Heart!"
  -- end
  fanfareData = {info = 'You found a Life Wisp!', comment = 'It raises your max health by 0.25!', pl_image_index = 1},
  dropTriggersFanfare = 'always'
}


local function getRupeeFullWalletComment()
  return u.chooseFromWeightTable{
    {
      weight = 100,
      value = "You can't fit it in your wallet so you throw it away in an unreasonably violent manner!"
    },
    {
      weight = 100,
      value = "Your wallet's full though, so forget about it!"
    },
    {
      weight = 1,
      value = "There's not enough space in your wallet so you eat it instead!"
    },
    {
      weight = 1,
      value = "Wallet's full dangit! You destroy it with your eye lasers! If you can't have it nobody can!"
    },
    {
      weight = 1,
      value = "You throw it away instead of giving it to some poor sod that might need it! You animal!"
    },
    {
      weight = 1,
      value = "No sooner had you put it in your wallet than a tax collector appears and seizes it! What an outrage!"
    }
  }
end

data.rupee = {
  id = 'rupee',
  type = 'other',
  effect = function() session.addMoney(1) end,
  nonFanfareEffect = function() snd.play(glsounds.getRupee) end,
  fanfareData = {
    info = "You got a green " .. GCON.money .. "... It's worth 1 " .. GCON.money .. "!",
    -- comment = 'What a boner-killer!',
    comment = function()
      if session.save.rupees == session.prevRupees then
        return getRupeeFullWalletComment()
      end
      if session.save.rupees > 50 then
        return "You might as well not have bothered..."
      end
      return "It might not be a lot but it's a start!"
    end,
    pl_image_index = 0
  },
  sprite_info = im.spriteSettings.dropRupee,
  image_speed = 0.2,
  frame_speed_mods = {
    [0] = 0.25
  },
  shadowHeightMod = -3,
  dropTriggersFanfare = 'once',
  unstoppable_update = function (self)
    if not self.isDrop then return end
    local x, y = self.x or self.xstart, (self.y or self.ystart) + (self.zo or 0)
    local a = u.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.4,
      last = 0.4,
      [0] = 0.4,
      [2] = 0.5,
      [7] = 0.4
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee',
      x = x,
      y = y,
      rgba = {
        g = 1,
        r = 0.2,
        b = 0.8,
        a = a
      }
    }
  end
}

data.rupee5 = {
  id = 'rupee5',
  type = 'other',
  effect = function() session.addMoney(5) end,
  nonFanfareEffect = function() snd.play(glsounds.getRupee5) end,
  fanfareData = {
    info = "You got a red " .. GCON.money .. "... It's worth 5 " .. GCON.moneys .. "!",
    comment = function()
      if session.save.rupees == session.prevRupees then
        return getRupeeFullWalletComment()
      end
      if session.save.rupees > 100 then
        return "How underwhelming..."
      end
      return "Not bad!"
    end,
    pl_image_index = 0
  },
  sprite_info = im.spriteSettings.dropRupee5,
  image_speed = 0.2,
  frame_speed_mods = {
    [0] = 0.25
  },
  shadowHeightMod = -2,
  dropTriggersFanfare = 'once',
  unstoppable_update = function (self)
    if not self.isDrop then return end
    local x, y = self.x or self.xstart, (self.y or self.ystart) + (self.zo or 0)
    local a = u.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.5,
      last = 0.5,
      [0] = 0.5,
      [3] = 0.6,
      [8] = 0.5
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee5',
      x = x,
      y = y,
      rgba = {
        g = 0.5,
        r = 1,
        b = 0.5,
        a = a
      }
    }
  end
}

data.rupee20 = {
  id = 'rupee20',
  type = 'other',
  effect = function() session.addMoney(20) end,
  nonFanfareEffect = function() snd.play(glsounds.getRupee20) end,
  fanfareData = {
    info = "You got a blue " .. GCON.money .. "... It's worth 20 " .. GCON.moneys .. "!",
    comment = function()
      if session.save.rupees == session.prevRupees then
        return getRupeeFullWalletComment()
      end
      if session.save.rupees > 200 then
        return "Not bad."
      end
      return "Lucky you!"
    end,
    pl_image_index = 0
  },
  sprite_info = im.spriteSettings.dropRupee20,
  image_speed = 0.2,
  frame_speed_mods = {
    [0] = 0.25
  },
  shadowHeightMod = -1,
  dropTriggersFanfare = 'once',
  unstoppable_update = function (self)
    if not self.isDrop then return end
    local x, y = self.x or self.xstart, (self.y or self.ystart) + (self.zo or 0)
    local a = u.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.6,
      last = 0.6,
      [0] = 0.6,
      [3] = 0.8,
      [4] = 0.8,
      [5] = 0.8,
      [8] = 0.6
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee20',
      x = x,
      y = y,
      rgba = {
        g = 0.5,
        r = 0.2,
        b = 1,
        a = a
      }
    }
  end
}

data.rupee100 = {
  id = 'rupee100',
  type = 'other',
  effect = function() session.addMoney(100) end,
  nonFanfareEffect = function() snd.play(glsounds.getRupee20) end,
  fanfareData = {
    info = "You got a gold " .. GCON.money .. "... It's worth 100 " .. GCON.moneys .. "!",
    comment = function()
      if session.save.rupees == session.prevRupees then
        return getRupeeFullWalletComment()
      end
      return "Amazing!"
    end,
    pl_image_index = 0
  },
  sprite_info = im.spriteSettings.dropRupee100,
  image_speed = 0.2,
  shadowHeightMod = 0,
  frame_speed_mods = {
    [0] = 0.25
  },
  dropTriggersFanfare = 'always',
  unstoppable_update = function (self)
    if not self.isDrop then return end
    local x, y = self.x or self.xstart, (self.y or self.ystart) + (self.zo or 0)
    local a = u.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.7,
      last = 0.7,
      [0] = 0.7,
      [3] = 0.9,
      [4] = 0.9,
      [5] = 0.9,
      [9] = 0.7
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee100',
      x = x,
      y = y,
      rgba = {
        g = 0.8,
        r = 1,
        b = 0.4,
        a = a
      }
    }
  end
}

data.rupee200 = {
  id = 'rupee200',
  type = 'other',
  effect = function() session.addMoney(200) end,
  nonFanfareEffect = function() snd.play(glsounds.getRupee20) end,
  fanfareData = {
    info = "You got a Purple " .. GCON.money .. "... It's worth 200 " .. GCON.moneys .. "!",
    comment = function()
      if session.save.rupees == session.prevRupees then
        return getRupeeFullWalletComment()
      end
      return "Incredible!"
    end,
    pl_image_index = 0
  },
  sprite_info = im.spriteSettings.dropRupee200,
  image_speed = 0.2,
  frame_speed_mods = {
    [0] = 0.25
  },
  shadowHeightMod = 2,
  dropTriggersFanfare = 'always',
  unstoppable_update = function (self)
    if not self.isDrop then return end
    local x, y = self.x or self.xstart, (self.y or self.ystart) + (self.zo or 0)
    local a = u.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.8,
      last = 0.8,
      [0] = 0.8,
      [2] = 1,
      [5] = 1,
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee200',
      x = x,
      y = y,
      rgba = {
        g = 1,
        r = 1,
        b = 1,
        a = a
      }
    }
  end
}


local collectables = {
  data = data
}

return collectables