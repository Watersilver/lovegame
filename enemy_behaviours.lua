local expl = require "GameObjects.explode"
local snd = require "sound"
local im = require "image"
local u = require "utilities"
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

function ebh.randomize4dir(object, setTimer)
  -- returns facing direction, if I want to.
  local myinp = object.input
  if object.moving then
    if setTimer then
      object.behaviourTimer = love.math.random(4)
    end
    myinp.left = 0; myinp.right = 0; myinp.up = 0; myinp.down = 0
    object.moving = false
  else
    if setTimer then
      object.behaviourTimer = love.math.random(2)
    end
    local dir = object.forcedDir or u.chooseKeyFromTable(myinp, object.avoidDir)
    myinp[dir] = 1
    object.avoidDir = nil
    object.forcedDir = nil
    object.moving = true
    -- New facing
    return dir
  end
  -- Don't change facing if staying still
  return object.facing
end

function ebh.beehaviour(object)
  -- Ensure that randomizeAnalogue never pauses by nilling direction
  if object.direction then
    object.direction = nil
  end
  ebh.randomizeAnalogue(object)
end

function ebh.bounceOffScreenEdge(object)
  if object.direction then
    if object.edgeSide then
      if object.edgeSide == "up" or object.edgeSide == "down" then
        object.direction = - object.direction
      else
        object.direction = - object.direction + math.pi
      end
      object.edgeSide = nil
      object.behaviourTimer = object.behaviourTimer + 1
    end
  end
end

function ebh.propelledByHit(object, other, myF, otherF, damage, forceMod, invframesMod, resetBehaviour)

  -- invulnerability
  invframesMod = invframesMod or 1
  object.invulnerable = invframesMod * 0.25

  -- Damage
  if (not object.shielded) or object.shieldDown then
    if object.hp then object.hp = object.hp - damage end
    if resetBehaviour then object.behaviourTimer = resetBehaviour end
  end

  -- Physics
  if not object.shieldWall then
    forceMod = forceMod or 1
    local speed = forceMod * 111 * object.body:getMass()
    local prevvx, prevvy = object.body:getLinearVelocity()

    local xadjust, yadjust

    local ox, oy = other.body:getPosition()
    local adj, opp = object.x - ox, object.y - oy
    local hyp = math.sqrt(adj*adj + opp*opp)

    -- object.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
    object.body:applyLinearImpulse(speed*adj/hyp, speed*opp/hyp)
  end
end

return ebh
