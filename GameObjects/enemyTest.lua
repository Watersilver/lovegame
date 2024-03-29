local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local td = require "movement"; td = td.top_down
local si = require "sight"
local ebh = require "enemy_behaviours"

local dc = require "GameObjects.Helpers.determine_colliders"

local floor = math.floor

local hitShader = shdrs.enemyHitShader

local hitSound = {"Effects/Oracle_Enemy_Hit"}
local deathSound = {"Effects/Oracle_Enemy_Die"}

local Enemy = {}

function Enemy.initialize(instance)
  instance.sprite_info = { im.spriteSettings.testenemy2 }
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    density = 160, --160 is 50 kg when combined with plshape dimensions(w 10, h 8)
    shape = ps.shapes.plshape,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0,
    masks = {ENEMYATTACKCAT, FLOORCOLLIDECAT},
    categories = {DEFAULTCAT, FLOORCOLLIDECAT, ROOMEDGECOLLIDECAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.enemy = true
  instance.input = {left = 0, right = 0, up = 0, down = 0}
  instance.zo = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.image_index = 0
  instance.impact = 20 -- how far I throw the player
  instance.damager = 1 -- how much damage I cause
  instance.grounded = true -- can be jumped over
  instance.flying = false -- can go through walls
  instance.goThroughPlayer = false -- can go through player
  instance.jumping = false -- can go over player and other non solids
  instance.levitating = false -- can go through over hazardous floor
  instance.actAszo0 = false -- move in regards to floor friction etc as if grounded
  instance.controlledFlight = false -- Floor doesn't affect me at all, but I still have breaks on air
  instance.lowFlight = false -- can be affected by attacks that only target grounded targets
  instance.canSeeThroughWalls = false -- what it says on the tin
  instance.shielded = false -- can be damaged
  instance.shieldDown = false -- shield temporarily disabled
  instance.shieldWall = false -- can be propelled by force
  instance.weakShield = false -- shield can be broken with empowered sword and bombs
  instance.mediumShield = false -- shield can be broken with empowered sword and empowered bombs
  instance.hardShield = false -- shield can be broken with empowered bombs
  instance.attackDodger = false -- weapon that hit me doesn't react
  instance.hp = love.math.random(3)
  instance.maxspeed = 20
  instance.behaviourTimer = 0
  instance.bounceEdge = true
  instance.ballbreaker = true
  instance.bombGoesThrough = true
  instance.canBeBullrushed = true
  instance.canBeRolledThrough = true
  instance.ignoreFloorMovementModifiers = true
  instance.lookFor = si.lookFor
  instance.layer = 20
  instance.angle = 0
  instance.sounds = snd.load_sounds({
    hitSound = hitSound
  })
  instance.deathSound = deathSound
  instance.explosionSprite = im.spriteSettings.enemyExplosion
  -- instance.side = "up"
  instance.vx = 0
  instance.vy = 0
  -- Drops examples
  -- instance.drops = {{value = "fairy", chance = 1}}
  -- OR
  -- instance.drop = "cheap"
end

Enemy.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
    self:enemyLoad()
  end,

  enemyLoad = function (self)
  end,

  enemyUpdate = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(self.target) end
    -- Movement behaviour
    if self.behaviourTimer < 0 then
      ebh.randomizeAnalogue(self, true)
    end
    if self.invulnerable then
      self.direction = nil
    end
    td.analogueWalk(self, dt)
  end,

  hitBySword = function (self, other, myF, otherF)
    ebh.damagedByHit(self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
    ebh.damagedByHit(self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
    ebh.damagedByHit(self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
    ebh.damagedByHit(self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
    ebh.damagedByHit(self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF)
  end,

  touchedBySword = function (self, other, myF, otherF)
  end,

  touchedByMissile = function (self, other, myF, otherF)
  end,

  touchedByThrown = function (self, other, myF, otherF)
  end,

  touchedByBombsplosion = function (self, other, myF, otherF)
  end,

  touchedByBullrush = function (self, other, myF, otherF)
  end,

  hitPlayer = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF, coll)
  end,

  hitStatic = function (self, other, myF, otherF, coll)
  end,

  die = function (self)
    ebh.die(self)
  end,

  update = function (self, dt)
    -- Do necessary stuff
    self.behaviourTimer = self.behaviourTimer - dt
    self.invulnerableEnd = nil
    if self.invulnerable then
      self.invulnerable = self.invulnerable - dt
      -- if not self.shielded or self.shieldDown then
      self.myShader = nil
      if floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
      -- end
      if self.invulnerable < 0 then
        self.invulnerable = nil
        self.invulnerableEnd = true
      end
    else
      self.myShader = nil
      if self.hp <= 0 or self.shouldDie then
        self.die(self)
      end
    end
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
    self.speed = u.magnitude2d(self.vx, self.vy)
    if self.image_speed then
      self.image_index = (self.image_index + dt*60*self.image_speed)
    end
    -- Do specialised stuff
    self:enemyUpdate(dt)

    self.attacked = false
    self.attemtedToBeAttacked = false
  end,

  draw = function (self)
    if self.invisible then return end

    local zo = self.zo or 0
    local xtotal, ytotal = self.x, self.y + zo

    if self.spritebody then
      if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
      self.spritebody:setPosition(xtotal, ytotal)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

    local sprite = self.sprite
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
    end
    local frame = sprite[floor(self.image_index)]

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    -- if self.body then
    --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- end

    -- si.drawRay(self, pl1)
  end,

  trans_draw = function (self)
    if self.invisible then return end

    local sprite = self.sprite
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
    end
    local frame = sprite[floor(self.image_index)]

    local zo = self.zo or 0
    local xtotal, ytotal = trans.moving_objects_coords(self)
    ytotal = ytotal + zo

    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, self.angle,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   -- draw
    -- end
  end,

  enemyBeginContact = function(other, myF, otherF, coll)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Determine if I'm at the room edge. If not and I'm flying, skip.
    if other.roomEdge then
      -- return if I don't collide with room edge
      if self.canLeaveRoom then return end
      self.edgeSide = other.roomEdge
      self.avoidDir = other.roomEdge
    else
      self.edgeSide = nil
      self.avoidDir = nil
    end

    -- Check if hit static (before I check for floor, because some floors are static)
    if otherF:getBody():getType() == "static" and not otherF:isSensor() then
      self:hitStatic(other, myF, otherF, coll)
    end

    -- If I'm levitating, skip if appropriate
    if other.floor then
      if self.levitating or self.flying or self.jumping then
        return
      end
    end

    -- Check if touched player
    if other.player then
      self:hitPlayer(other, myF, otherF)
    end

    -- Check if hit solid static
    if otherF:getBody():getType() == "static" and not otherF:isSensor() and not other.notSolidStatic then
      self:hitSolidStatic(other, myF, otherF, coll)
    end

    -- Force next direction to avoid further collisions
    if not otherF:isSensor() and not other.doesntForceDir then
      if math.abs(self.vx) > math.abs(self.vy) then
        if self.vx > 0 then
          self.forcedDir = "left"
        else
          self.forcedDir = "right"
        end
      else
        if self.vy > 0 then
          self.forcedDir = "up"
        else
          self.forcedDir = "down"
        end
      end
      -- Check if the fixture I've collided with is a tile with a side to help with forced dir
      local tileSide = otherF:getUserData()
      if tileSide then
        if tileSide == "u" then
          self.forcedDir = "up"
        elseif tileSide == "l" then
          self.forcedDir = "left"
        elseif tileSide == "d" then
          self.forcedDir = "down"
        elseif tileSide == "r" then
          self.forcedDir = "right"
        end
      end
      -- If I'm on the room edge, go to the opposite direction
      if other.oppositeDir then self.forcedDir = other.oppositeDir end
    end

    -- Check if hit by sword
    -- if other.immasword == true and not self.invulnerable and not self.undamageable then
    --   self.lastHit = "sword"
    --   self.attacked = true
    --   self:hitBySword(other, myF, otherF)
    -- end
    if other.immasword == true then
      self.attemtedToBeAttacked = "sword"
      self:touchedBySword(other, myF, otherF)
      if not self.invulnerable and not self.undamageable then
        self.lastHit = "sword"
        self.lastHitEmpowered = other.poweredUp
        self.attacked = true
        self:hitBySword(other, myF, otherF)
      end
    end

    -- Check if hit by missile
    if other.immamissile == true then
      self.attemtedToBeAttacked = "missile"
      self:touchedByMissile(other, myF, otherF)
      if not self.invulnerable and not self.undamageable then
        self.lastHit = "missile"
        self.lastHitEmpowered = other.poweredUp
        self.attacked = true
        self:hitByMissile(other, myF, otherF)
      end
    end

    -- Check if hit by thrown object
    if other.immathrown == true and not other.iAmBomb then
      self.attemtedToBeAttacked = "thrown"
      self:touchedByThrown(other, myF, otherF)
      if not self.invulnerable and not self.undamageable then
        self.lastHit = "thrown"
        self.lastHitEmpowered = other.poweredUp
        self.attacked = true
        self:hitByThrown(other, myF, otherF)
      end
    end

    -- Check if hit by bombsplosion
    if other.immabombsplosion == true then
      self.attemtedToBeAttacked = "bombsplosion"
      self:touchedByBombsplosion(other, myF, otherF)
      if not self.invulnerable and (not self.undamageable or self.damageableByBombsplosion) then
        self.lastHit = "bombsplosion"
        self.lastHitEmpowered = other.poweredUp
        self.attacked = true
        self:hitByBombsplosion(other, myF, otherF)
      end
    end

    -- Check if hit by sprint
    if not otherF:isSensor() and other.immasprint == true then
      self.attemtedToBeAttacked = "bullrush"
      self:touchedByBullrush(other, myF, otherF)
      if self.canBeBullrushed and not self.attackDodger and not self.invulnerable and not self.undamageable then
        self.lastHit = "bullrush"
        self.lastHitEmpowered = other.poweredUp
        self.attacked = true
        self:hitByBullrush(other, myF, otherF)
      end
    end

    -- Check if hit by magic dust
    if other.immamdust == true and not other.hasReacted then
      self.attemtedToBeAttacked = "mdust"
      self.lastHit = "mdust"
      self.lastHitEmpowered = other.poweredUp
      self.attacked = true
    end

    self:enemyBeginContact(other, myF, otherF, coll)
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.roomEdge then
      if self.canLeaveRoom then
        coll:setEnabled(false)
      end
      return
    end

    if self.disableCollisions or self.flying or (self.goThroughEnemies and other.enemy) then
      coll:setEnabled(false)
    elseif self.jumping then
      if other.body:getType() ~= "static" then coll:setEnabled(false) end
    else
      if other.floor then
        if self.levitating then
          coll:setEnabled(false)
        -- elseif other.water and self.invulnerable and not self.shieldWall then
        --   o.removeFromWorld(self)
        --   if not other.startSinking then other.startSinking = true end
        -- end
        -- if self.levitating then
        --   coll:setEnabled(false)
        -- elseif other.gap and self.invulnerable and not self.shieldWall then
        --   o.removeFromWorld(self)
        --   if not other.startFalling then other.startFalling = true end
        end
      end
    end
  end
}

function Enemy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Enemy, instance, init) -- add own functions and fields
  return instance
end

return Enemy
