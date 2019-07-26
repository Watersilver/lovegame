local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"

local noBody = require "GameObjects.noBody"

local floor = math.floor

local Explode = {}

local default_explosion_sprite = im.spriteSettings.rockDestruction
local default_explosion_sound = {"Effects/Oracle_Rock_Shatter"}
function Explode.commonExplosion(instance, explosion_sprite, explosion_sound)
  local explOb = Explode:new{
    x = instance.x or instance.xstart, y = instance.y or instance.ystart,
    layer = instance.layer,
    explosionNumber = 1,
    explosion_sprite = explosion_sprite or default_explosion_sprite,
    image_speed = instance.explosionSpeed,
    sounds = snd.load_sounds({explode = explosion_sound or default_explosion_sound})
  }
  o.addToWorld(explOb)
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
    snd.play(self.sounds.explode)
    if self.explosion_sprite then
      im.load_sprite(self.explosion_sprite)
      self.sprite = im.sprites[self.explosion_sprite[1] or self.explosion_sprite[img_name]]
    end
  end,

  delete = function (self)
    if self.explosion_sprite then
      im.unload_sprite(self.explosion_sprite[1] or self.explosion_sprite[img_name])
    end
  end,

  update = function (self, dt)
    self.image_indexfloat = (self.image_indexfloat + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_indexfloat >= frames do
      o.removeFromWorld(self)
      if self.explosionNumber and self.explosionNumber > 1 then
        self.explosionNumber = self.explosionNumber - 1
        local nextplosion = Explode:new{
          xexplode = self.xexplode,
          yexplode = self.yexplode,
          xstart = self.xexplode + math.random(-self.explodeDistance, self.explodeDistance),
          ystart = self.yexplode + math.random(-self.explodeDistance, self.explodeDistance),
          layer = self.layer,
          explosionNumber = self.explosionNumber,
          image_speed = self.image_speed,
          sprite_info = self.sprite_info,
        }
        o.addToWorld(nextplosion)
      end
      self.image_indexfloat = frames - 1
      self.image_speed = 0
    end
    self.image_index = floor(self.image_indexfloat)
  end
}

function Explode:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(noBody, instance) -- add parent functions and fields
  p.new(Explode, instance, init) -- add own functions and fields
  return instance
end

return Explode
