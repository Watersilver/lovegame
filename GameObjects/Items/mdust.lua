local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local magic_dust_effects = require "GameObjects.Helpers.magic_dust_effects"

local dc = require "GameObjects.Helpers.determine_colliders"

local MagicDust = {}

function MagicDust.initialize(instance)

  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.untouchable = true
  instance.immamdust = true
  instance.sprite_info = {im.spriteSettings.playerMdust}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    shape = ps.shapes.circle1,
    masks = {PLAYERATTACKCAT},
    categories = {PLAYERATTACKCAT}
  }
  instance.seeThrough = true
  instance.poweredUp = session.save.nayrusWisdom
  if instance.poweredUp then
    instance.myShader = shdrs["itemBlueShader"]
    instance.chargedShader = shdrs.swordChargeShader
  end
  instance.lvl = session.save.magicLvl
  instance.chargedShaderFreq = 1 / 30
  instance.chargedShaderPhase = instance.chargedShaderFreq
end

MagicDust.functions = {
  load = function (self)
    self.timer = 0.5 -- | 0.4 or 0.5
    self.startingTimer = self.timer
    self.body:setPosition(self.x, self.y)
    snd.play(glsounds.magicDust)
  end,

  [GCON.md.reaction.boom] = function (self)
    local boom = (require "GameObjects.Items.bombsplosion"):new{
      x = self.x, y = self.y,
      layer = self.layer,
      dustAccident = true
    }
    o.addToWorld(boom)
  end,

  [GCON.md.reaction.kaboom] = function (self)
    local chain = (require "GameObjects.Items.chainReaction"):new{
      x = self.x, y = self.y,
      layer = self.layer
    }
    o.addToWorld(chain)
  end,

  [GCON.md.reaction.block] = function (self)
    local box = (require "GameObjects.Items.magicBox"):new{
      xstart = self.x,
      ystart = self.y,
      x = self.x,
      y = self.y,
      layer = self.creator and self.creator.layer - 1 or self.layer - 2,
      creator = self.creator
    }
    if self.creator then
      if self.creator.magicBox then
        self.creator.magicBox.creator = nil
      end
      self.creator.magicBox = box
    end
    o.addToWorld(box)
  end,

  [GCON.md.reaction.decoy] = function (self)
    local decoy = (require "GameObjects.Items.decoy"):new{
      x = self.x, y = self.y,
      layer = self.layer,
      side = self.side
    }
    o.addToWorld(decoy)
  end,

  [GCON.md.reaction.fire] = function (self)
    magic_dust_effects.burn(self)
  end,

  [GCON.md.reaction.wind] = function (self)
    magic_dust_effects.blow(self)
  end,

  [GCON.md.reaction.heart] = function (self) magic_dust_effects.createHeart(self) end,
  [GCON.md.reaction.fairy] = function (self) magic_dust_effects.createFairy(self) end,

  -- this methods will deplete focuses
  -- useFocus = function (focus)
  --   if session.save.focus == focus then
  --     local result = session.removeItem(focus)
  --     if result == 1 then
  --       async.realTime{
  --         function() snd.play(glsounds.runningLow) end,
  --         0.2,
  --         function() return session.save[focus] ~= 1 end
  --       }
  --     end
  --     if result == 0 then
  --       async.realTime{
  --         function() snd.play(glsounds.runOut) end,
  --         0.2,
  --         function() return session.save[focus] end
  --       }
  --     end
  --     -- Unequip focus if ran out
  --     if result <= 0 then
  --       session.save.focus = nil
  --     end
  --     if result >= 0 then
  --       return true
  --     end
  --   end
  -- end,

  noReagentReact = function (self)
    local r = GCON.md.reaction
    return u.chooseFromChanceTable{
      -- If you have nayrusWisdom, no explosions
      {value = r.boom, chance = self.poweredUp and 0 or 0.08},
      {value = r.kaboom, chance = self.poweredUp and 0 or 0.02},
      -- If you have nayrusWisdom, you may get healing instead
      {value = r.heart, chance = self.poweredUp and 0.08 or 0},
      {value = r.fairy, chance = self.poweredUp and 0.02 or 0},
      -- Inconsequential
      {value = r.fire, chance = 0.1},
      {value = r.wind, chance = 0.1},
      -- If you hit a wall, no magic block
      {value = r.block, chance = not self.hitSolid and 0.4 or 0},
      -- If you hit a wall, no decoy
      {value = r.decoy, chance = not self.hitSolid and 0.2 or 0},
      -- If none of the above happens, nothing happens
      {value = r.nothing, chance = 1},
    }
  end,

  update = function (self, dt)

    -- Delete and clean fixture data because it can only react during its first frame.
    if self.fixture then
      self.fixture:setUserData(nil)
      self.fixture:destroy()
      self.fixture = nil
    end

    if not self.hasReacted then
      local r = GCON.md.reaction
      local reactionID
      if self.reagent then
        -- Check if I will react with reagent and run its choice function if yes.
        reactionID = self.reagent[GCON.md.choose](self.reagent, self)
      else
        -- Or run my choice function.
        reactionID = self:noReagentReact()
      end

      -- Check if I have to force some reaction because of some focus
      if session.hasFocusEquipped("focusDoll") then
        reactionID = r.decoy
      end

      -- Check if reactionID must be overriden because of reagent special focus behaviour
      if session.hasFocusEquipped() and self.reagent and self.reagent.exists and self.reagent[GCON.md.focus] then
        local id = self.reagent[GCON.md.focus]()
        if id then reactionID = id end
      end

      -- Check if chosen reaction gets canceled for some reason.
      if self.hitSolid then
        local i = reactionID
        if i == r.decoy or i == r.block then
          reactionID = r.nothing
        end
      end

      -- Run Reaction.
      if self.reagent and self.reagent.exists then
        -- Run reaction on reagent
        if self.reagent[reactionID] then
          self.reagent[reactionID](self.reagent, self)

        -- If reaction doesn't exist on reagent and cascade is enabled then react without reagent
        elseif self.reagent[GCON.md.cascade] and self.reagent[GCON.md.cascade](self.reagent, reactionID) and self[reactionID] then
          self[reactionID](self)
        end
      elseif self[reactionID] then
        -- React without reagent
        self[reactionID](self)
      end

      self.hasReacted = true
    end

    -- determine shader
    if self.chargedShader then
      -- relative luminance: 0.2126 * R + 0.7152 * G + 0.0722 * B
      self.chargedShaderPhase = self.chargedShaderPhase + dt
      if self.chargedShaderPhase > self.chargedShaderFreq then
        self.chargedShaderPhase = self.chargedShaderPhase - self.chargedShaderFreq
        local randHue = COLORCONST * love.math.random()
        local r1, g1, b1, a = HSL(randHue, 1 * COLORCONST, 0.5 * COLORCONST, COLORCONST)
        local r2, g2, b2, a = HSL(randHue, 1 * COLORCONST, 0.75 * COLORCONST, COLORCONST)
        local ccInv = 1 / COLORCONST
        r1, g1, b1, r2, g2, b2 =
        r1 * ccInv, g1 * ccInv, b1 * ccInv,
        r2 * ccInv, g2 * ccInv, b2 * ccInv
        if self.chargedShader then
          self.chargedShader:send("rgb", r1, g1, b1, r2, g2, b2, a)
        end
        self.currentShader = self.chargedShader
      end
    else
      self.currentShader = self.myShader
    end

    local sprite = self.sprite
    self.image_index = sprite.frames * (1 - self.timer / self.startingTimer)
    if self.image_index >= sprite.frames then self.image_index = sprite.frames - 1 end

    if self.timer < 0 then
      o.removeFromWorld(self)
    end
    self.timer = self.timer - dt
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    self.x, self.y = x, y

    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    local worldShader = love.graphics.getShader()
    local ymod
    if self.side == "down" then
      ymod = -6
    elseif self.side == "up" then
      ymod = -4
    else
      ymod = 0
    end

    love.graphics.setShader(self.currentShader)
    love.graphics.draw(
    sprite.img, frame, x, y + 4 + ymod, 0,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    love.graphics.setShader(worldShader)

    -- Debug
    -- if self.fixture then love.graphics.circle("line", x, y, self.fixture:getShape():getRadius()) end
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if not otherF:isSensor() and not other.floor then
      self.hitSolid = true
    end

    if other[GCON.md.choose] and not self.reagent then
      self.reagent = other
    end
  end,
}

function MagicDust:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(MagicDust, instance, init) -- add own functions and fields
  return instance
end

return MagicDust
