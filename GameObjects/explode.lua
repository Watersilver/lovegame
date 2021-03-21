local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local drops = require "GameObjects.drops.drops"

local noBody = require "GameObjects.noBody"

local floor = math.floor

enexploshaders = {shdrs.enemyExplodeShader1, shdrs.enemyExplodeShader2}

local Explode = {}

local default_explosion_sprite = im.spriteSettings.rockDestruction
local default_explosion_sound = {"Effects/Oracle_Rock_Shatter"}
function Explode.commonExplosion(instance, explosion_sprite, explosion_sound, xdest, ydest)
  local explOb = Explode:new{
    x = instance.x or instance.xstart, y = instance.y or instance.ystart,
    layer = instance.layer,
    explosionNumber = 1,
    explosion_sprite = explosion_sprite or default_explosion_sprite,
    image_speed = instance.explosionSpeed,
    sounds = snd.load_sounds({explode = explosion_sound or default_explosion_sound}),
    sound = nil
  }
  explOb.xdest = xdest
  explOb.ydest = ydest
  o.addToWorld(explOb)
end

local sink_sprite = im.spriteSettings.rockSink
local sink_sound = {"Effects/Oracle_Link_Wade"}
function Explode.sink(instance)
  instance.explosionSpeed = 0.4
  Explode.commonExplosion(instance, sink_sprite, sink_sound)
  o.removeFromWorld(instance)
end

local plummet_sprite = im.spriteSettings.rockPlummet
local plummet_sound = {"Effects/Oracle_Block_Fall"}
function Explode.plummet(instance)
  instance.explosionSpeed = 0.2
  Explode.commonExplosion(instance, plummet_sprite, plummet_sound, instance.xClosestTile, instance.yClosestTile)
  o.removeFromWorld(instance)
end

function Explode.initialize(instance)
  instance.sprite_info = {im.spriteSettings.testsplosion}
  instance.image_speed = 0.5
  instance.image_index = 0 -- make sure it's int
  instance.sounds = snd.load_sounds({
    explode = {"Testplosion"}
  })
end

Explode.functions = {
  load = function (self)
    self.image_indexfloat = self.image_index
    self.xstart = self.x or self.xstart
    self.ystart = self.y or self.ystart
    self.xexplode = self.xexplode or self.xstart
    self.yexplode = self.yexplode or self.ystart
    self.explodeDistance = self.explodeDistance or 8
    self.explosionTimer = 0
    if not self.nosound then
      if self.sound then
        snd.play(self.sound)
      elseif self.sounds then
        snd.play(self.sounds.explode)
      end
    end
    if self.explosion_sprite then
      im.load_sprite(self.explosion_sprite)
      self.sprite = im.sprites[self.explosion_sprite[1] or self.explosion_sprite["img_name"]]
    end
  end,

  delete = function (self)
    if self.explosion_sprite then
      im.unload_sprite(self.explosion_sprite[1] or self.explosion_sprite["img_name"])
    end
  end,

  update = function (self, dt)
    self.explosionTimer = self.explosionTimer + dt
    self.image_indexfloat = (self.image_indexfloat + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_indexfloat >= frames do
      o.removeFromWorld(self)
      if self.explosionNumber and self.explosionNumber > 1 then
        self.explosionNumber = self.explosionNumber - 1
        if self.onlySoundOnce then self.nosound = true end
        local nextplosion = Explode:new{
          xexplode = self.xexplode,
          yexplode = self.yexplode,
          xstart = self.xexplode + math.random(-self.explodeDistance, self.explodeDistance),
          ystart = self.yexplode + math.random(-self.explodeDistance, self.explodeDistance),
          layer = self.layer,
          explosionNumber = self.explosionNumber,
          image_speed = self.image_speed,
          sprite_info = self.sprite_info,
          explosion_sprite = self.explosion_sprite,
          nosound = self.nosound,
          normalDrop = self.normalDrop,
          drop = self.drop,
          explodeDistance = self.explodeDistance,
          createOnExplEnd = self.createOnExplEnd
        }
        o.addToWorld(nextplosion)
      else
        if self.onExplEnd then
          -- For specific stuff, use custom method
          self:onExplEnd()
        elseif self.drops then
          -- If I have custom drops, use them to determine drop
          drops.custom(self.xexplode or self.xstart, self.yexplode or self.ystart, self.drops)
        elseif self.drop and self.drop ~= "noDrop" then
          -- Else use one of the drop tables
          drops[self.drop](self.xexplode or self.xstart, self.yexplode or self.ystart)
        end
      end
      self.image_indexfloat = frames - 1
      self.image_speed = 0
    end
    self.image_index = floor(self.image_indexfloat)
    if self.xdest and self.ydest then
      local pmod = self.explosionTimer * 10
      if pmod > 1 then pmod = 1 end
      self.x = self.xstart + pmod * (self.xdest - self.xstart)
      self.y = self.ystart + pmod * (self.ydest - self.ystart)
    end

    --shaders
    if self.enexploshaders then
      local shdrIndex = love.math.random( 2 )
      self.myShader = enexploshaders[shdrIndex]
    end
  end
}

function Explode:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(noBody, instance) -- add parent functions and fields
  p.new(Explode, instance, init) -- add own functions and fields
  return instance
end

return Explode
