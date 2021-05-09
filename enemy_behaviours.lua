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
  if object.enemyId then
    session.deadEnemies:add(object.enemyId)
  end

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
    drop = object.drop or "normal",
    drops = object.drops -- Objects custom droptable
  }
  o.addToWorld(explOb)
  o.removeFromWorld(object)
end

function ebh.randomizeAnalogue(object, setTimer, nonStop)
  if object.direction and not nonStop then
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

function ebh.randomize4dir(object, setTimer, nonStop)
  -- returns facing direction, if I want to.
  local myinp = object.input
  myinp.left = 0; myinp.right = 0; myinp.up = 0; myinp.down = 0
  if object.moving and not nonStop then
    if setTimer then
      object.behaviourTimer = love.math.random(4)
    end
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
    -- Shield gets pierced if it's weak and I get attacked by bomb or empowered sword
    (object.weakShield and
    ((session.save.dinsPower and object.lastHit == "sword") or
    object.lastHit == "bombsplosion")) or
    -- Shield gets pierced if it's medium and I get attacked by empowered bomb or empowered sword
    (object.mediumShield and
    ((session.save.dinsPower and object.lastHit == "sword") or
    (object.lastHitEmpowered and object.lastHit == "bombsplosion"))) or
    -- Shield gets pierced if it's hard and I get attacked by empowered bomb
    (object.hardShield and
    (object.lastHitEmpowered and object.lastHit == "bombsplosion"))
  )
end

function ebh.damagedByHit(object, other, myF, otherF)

  -- Do nothing if dying
  if object.hp <= 0 then return end

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
      baseDamage = session.save.nayrusWisdom and (other.deflected and 3 or 2) or (other.deflected and 2 or 1)
      damageMod = object.missileDamageMod or 1
    elseif object.lastHit == "thrown" then
      baseDamage = session.save.dinsPower and 5 or 4
      damageMod = object.thrownDamageMod or 1
    elseif object.lastHit == "bombsplosion" then
      baseDamage = other.poweredUp and 5 or 4
      damageMod = object.bombsplosionDamageMod or 1
    elseif object.lastHit == "bullrush" then
      baseDamage = session.save.faroresCourage and 1 or 0.5
      damageMod = object.bullrushDamageMod or 1
    end
    -- Weaker strikes if shaking (can't check trigger because it might get reset before we get here)
    if pl1 and (pl1.shakex ~= 0 or pl1.shakey ~= 0) then baseDamage = baseDamage * 0.5 end
    local damage = baseDamage * damageMod

    -- Apply damage
    if object.hp then object.hp = object.hp - damage end
    if object.hp <= 0 then
      object.harmless = true
      snd.play(object.sounds.fatalHit or object.sounds.hitSound)
    else
      snd.play(object.sounds.hitSound)
    end
    if object.resetBehaviour then object.behaviourTimer = object.resetBehaviour end

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
    baseForceMod = session.save.nayrusWisdom and (other.deflected and 2 or 1) or (other.deflected and 1 or 0.5)
    attackForceMod = object.missileForceMod or 1
  elseif object.lastHit == "thrown" then
    baseForceMod = session.save.dinsPower and 3 or 2
    attackForceMod = object.thrownForceMod or 1
  elseif object.lastHit == "bombsplosion" then
    baseForceMod = other.poweredUp and 5 or 4
    attackForceMod = object.bombsplosionForceMod or 1
  elseif object.lastHit == "bullrush" then
    baseForceMod = session.save.faroresCourage and 4 or 3
    attackForceMod = object.bullrushForceMod or 1
  end
  -- Weaker strikes if shaking (can't check trigger because it might get reset before we get here)
  if pl1 and (pl1.shakex ~= 0 or pl1.shakey ~= 0) then baseForceMod = baseForceMod * 0.5 end
  local forceMod = baseForceMod * attackForceMod * (object.universalForceMod or 1)

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
