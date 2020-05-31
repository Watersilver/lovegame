local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local gsh = require "gamera_shake"

local dc = require "GameObjects.Helpers.determine_colliders"

local MagicDust = {}

local floor = math.floor
local clamp = u.clamp
local pi = math.pi


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
  if session.save.nayrusWisdom then
    instance.myShader = shdrs["itemBlueShader"]
    instance.chargedShader = shdrs.swordChargeShader
  end
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

  explode = function (self)
    local boom = (require "GameObjects.Items.bombsplosion"):new{
      x = self.x, y = self.y,
      layer = self.layer,
      dustAccident = true
    }
    o.addToWorld(boom)
  end,

  chainReaction = function (self)
    local chain = (require "GameObjects.Items.chainReaction"):new{
      x = self.x, y = self.y,
      layer = self.layer
    }
    o.addToWorld(chain)
  end,

  createBlock = function (self)
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

  update = function (self, dt)

    if self.fixture then
      self.fixture:setUserData(nil)
      self.fixture:destroy()
      self.fixture = nil
    end

    if not self.hasReacted then
      -- Make an untargeted reaction
      local reaction = u.chooseFromChanceTable{
        -- If you have nayrusWisdom, no explosions
        {value = self.explode, chance = session.save.nayrusWisdom and 0 or 0.08},
        {value = self.chainReaction, chance = session.save.nayrusWisdom and 0 or 0.02},
        -- If you hit a wall, no magic block
        {value = self.createBlock, chance = not self.hitSolid and 0.4 or 0},
        -- If none of the above happens, nothing happens
        {value = u.emptyFunc, chance = 1},
      }
      if not self.hitSolid then
      end
      reaction(self)
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
    local frame = sprite[floor(self.image_index)]
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
    if self.fixture then love.graphics.circle("line", x, y, self.fixture:getShape():getRadius()) end
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if not otherF:isSensor() then
      self.hitSolid = true
    end
  end,
}

function MagicDust:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(MagicDust, instance, init) -- add own functions and fields
  return instance
end

return MagicDust
