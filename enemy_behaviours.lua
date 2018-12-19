local expl = require "GameObjects.explode"
local snd = require "sound"
local im = require "image"
local o = require "GameObjects.objects"

local ebh = {}

local pi = math.pi

local defaultDeathSound = {"Testplosion"}
local defaultDeathSprite = {im.spriteSettings.testsplosion}

function ebh.die(object)
  local explOb = expl:new{
    x = object.x or object.xstart, y = object.y or object.ystart,
    layer = object.layer,
    explosionNumber = object.explosionNumber or 1,
    sprite_info = object.explosionSprite or defaultDeathSprite,
    image_speed = object.explosionSpeed or 0.5,
    sounds = snd.load_sounds({explode = object.explosionSound or defaultDeathSound})
  }
  o.addToWorld(explOb)
  o.removeFromWorld(object)
end

function ebh.randomizeAnalogue(object, setTimer)
  if object.direction then
    object.direction = nil
    if setTimer then
      object.behaviourTimer = love.math.random(4)
    end
  else
    object.direction = love.math.random() * 2 * pi
    object.normalisedSpeed = love.math.random()
    if setTimer then
      object.behaviourTimer = love.math.random(2)
    end
  end
end

return ebh
