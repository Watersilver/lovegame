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

-- xplosion light
local ls = require "lightSources"

local dc = require "GameObjects.Helpers.determine_colliders"

local Bombsplosion = {}

local floor = math.floor
local clamp = u.clamp
local pi = math.pi

function Bombsplosion.initialize(instance)

  -- xplosion light
  instance.lightSource = {kind = "playerGlow"}
  instance.immabombsplosion = true
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.untouchable = true
  instance.damager = true
  instance.attackDmg = 4
  instance.impact = 1
  instance.sprite_info = {im.spriteSettings.playerBlast}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    shape = ps.shapes.circle2,
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT},
    categories = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT, ENEMYATTACKCAT}
  }
  instance.seeThrough = true
end

Bombsplosion.functions = {
  load = function (self)
    self.timer = 0.4
    self.startingTimer = self.timer
    self.body:setPosition(self.x, self.y)

    if session.save.dinsPower and not self.dustAccident then
      self.myShader = shdrs["itemRedShader"]
      self.blowUpForce = 200
      self.damCounter = 1.7
      self.poweredUp = true
    end

    -- find how far the explosion is happening from the player
    local pldistance = 0
    if pl1 then
      local plx, ply = pl1.body:getPosition()
      pldistance = u.distance2d(plx, ply, self.x, self.y)
    end

    -- determine the explosion's effects based pldistance and explosions power
    local magn, freq, dur = 1, 0.05, 1
    if session.save.dinsPower and not self.dustAccident then
      -- < 85 is close, > 95 is far
      if pldistance < 20 then
        magn, dur = 1.5, 2
      elseif pldistance > 150 then
        magn, dur = 0.5, 0.5
      elseif pldistance > 95 then
        magn, dur = 0.8, 0.8
      end
    else
      -- < 33 is close, > 38 is far
      if pldistance < 20 then
        magn, dur = 1.2, 1.5
      elseif pldistance > 93 then
        magn, dur = 0.4, 0.5
      elseif pldistance > 38 then
        magn, dur = 0.7, 0.7
      end
    end

    gsh.newShake(mainCamera, "displacement", magn, freq, dur)
    snd.play(glsounds.bomb)
  end,

  update = function (self, dt)

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

    -- bomb light
    self.lightSource.x, self.lightSource.y = x, y
    ls.drawSource(self.lightSource)

    local sprite = self.sprite
    local frame = sprite[floor(self.image_index)]
    local worldShader = love.graphics.getShader()

    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    love.graphics.setShader(worldShader)

    -- Debug
    -- love.graphics.polygon("line",
    -- self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.circle("line", x, y, self.fixture:getShape():getRadius())
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

  end,
}

function Bombsplosion:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Bombsplosion, instance, init) -- add own functions and fields
  return instance
end

return Bombsplosion
