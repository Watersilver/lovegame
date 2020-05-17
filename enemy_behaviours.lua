local snd = require "sound"
local im = require "image"
local snd = require "sound"
local u = require "utilities"
local o = require "GameObjects.objects"

local ebh = {}

local pi = math.pi

local defaultDeathSound = {"Testplosion"}
local defaultDeathSprite = {im.spriteSettings.testsplosion}

function ebh.die(object)
  -- require to avoid circular dependency
  local explOb = (require "GameObjects.explode"):new{
    x = object.x or object.xstart, y = object.y or object.ystart,
    layer = object.layer,
    explosionNumber = object.explosionNumber or 1,
    explosion_sprite = object.explosionSprite or defaultDeathSprite,
    image_speed = object.explosionSpeed or 0.2,
    sounds = snd.load_sounds({explode = object.deathSound}),
    enexploshaders = true,
    onlySoundOnce = true,
    drop = object.drop or "normal"
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

local function checkIfShieldPierced(object)
  return (
    object.weakShield and
    (session.save.dinsPower and object.lastHit == "sword") or
    object.lastHit == "bombsplosion"
  )
end

function ebh.damagedByHit(object, other, myF, otherF)

  -- Determine if shield was pierced
  local piercedShield = checkIfShieldPierced(object)

  if (not object.shielded) or object.shieldDown or piercedShield then
    -- Calculate damage received
    local baseDamage
    local damageMod
    if object.lastHit == "sword" then
      baseDamage = session.save.dinsPower and 4 or 3
      damageMod = object.swordDamageMod or 1
    elseif object.lastHit == "missile" then
      -- if missile is hit by sword, raise damage
      baseDamage = session.save.nayrusWisdom and (other.hitBySword and 3 or 2) or (other.hitBySword and 2 or 1)
      damageMod = object.missileDamageMod or 1
    elseif object.lastHit == "thrown" then
      baseDamage = session.save.dinsPower and 5 or 4
      damageMod = object.thrownDamageMod or 1
    elseif object.lastHit == "bombsplosion" then
      baseDamage = session.save.dinsPower and 5 or 4
      damageMod = object.bombsplosionDamageMod or 1
    end
    local damage = baseDamage * damageMod

    -- Apply damage
    if object.hp then object.hp = object.hp - damage end
    if object.hp <= 0 then object.harmless = true end
    if object.resetBehaviour then object.behaviourTimer = object.resetBehaviour end
    snd.play(object.sounds.hitSound)

    -- invulnerability
    local invframesMod = object.invframesMod or 1
    object.invulnerable = invframesMod * 0.25
  end
end

function ebh.propelledByHit(object, other, myF, otherF, damage, forceMod, invframesMod)

  -- Determine if shield was pierced
  local piercedShield = checkIfShieldPierced(object)
  
  -- Calculate force
  local baseForceMod
  local attackForceMod
  if object.lastHit == "sword" then
    baseForceMod = session.save.dinsPower and (other.spin and 3 or (other.stab and 1 or 2)) or (other.spin and 1.5 or (other.stab and 0.5 or 1))
    attackForceMod = object.swordForceMod or 1
  elseif object.lastHit == "missile" then
    -- if missile is hit by sword, raise force
    baseForceMod = session.save.nayrusWisdom and (other.hitBySword and 2 or 1) or (other.hitBySword and 1 or 0.5)
    attackForceMod = object.missileForceMod or 1
  elseif object.lastHit == "thrown" then
    baseForceMod = session.save.dinsPower and 3 or 2
    attackForceMod = object.thrownForceMod or 1
  elseif object.lastHit == "bombsplosion" then
    baseForceMod = session.save.dinsPower and 5 or 4
    attackForceMod = object.bombsplosionForceMod or 1
  end
  local forceMod = baseForceMod * attackForceMod

  -- Physics
  if not object.shieldWall or piercedShield then
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
