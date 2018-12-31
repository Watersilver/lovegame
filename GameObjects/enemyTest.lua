local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local td = require "movement"; td = td.top_down
local si = require "sight"
local ebh = require "enemy_behaviours"

local dc = require "GameObjects.Helpers.determine_colliders"

local hitShader = shdrs.playerHitShader

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
    masks = {ENEMYATTACKCAT},
    categories = {DEFAULTCAT, FLOORCOLLIDECAT, ROOMEDGECOLLIDECAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
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
  instance.hp = love.math.random(3)
  instance.maxspeed = 20
  instance.behaviourTimer = 0
  instance.bounceEdge = true
  instance.ignoreFloorMovementModifiers = true
  instance.lookFor = si.lookFor
  -- instance.side = "up"
end

Enemy.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
    self.vx = 0
    self.vy = 0
  end,

  enemyUpdate = function (self, dt)
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(pl1) end
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
    ebh.propelledByHit(self, other, myF, otherF, 3)
  end,

  hitPlayer = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  update = function (self, dt)
    -- Do necessary stuff
    self.behaviourTimer = self.behaviourTimer - dt
    self.invulnerableEnd = nil
    if self.invulnerable then
      self.invulnerable = self.invulnerable - dt
      if self.invulnerable < 0 then
        self.invulnerable = nil
        self.invulnerableEnd = true
      end
      if not self.shielded or self.shieldDown then self.myShader = hitShader end
    else
      self.myShader = nil
      if self.hp <= 0 then
        ebh.die(self)
      end
    end
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
    -- Do specialised stuff
    self:enemyUpdate(dt)
  end,

  draw = function (self)
    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
    self.spritebody:setPosition(self.x, self.y)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    local zo = self.zo or 0
    local xtotal, ytotal = self.x, self.y + zo

    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    -- if self.body then
    --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- end

    -- si.drawRay(self, pl1)
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local zo = self.zo or 0
    local xtotal, ytotal = trans.moving_objects_coords(self)
    ytotal = ytotal + zo

    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   -- draw
    -- end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    self.edgeSide = other.roomEdge
    self.avoidDir = other.roomEdge

    -- Check if touched player
    if other.player then
      self:hitPlayer(other, myF, otherF)
    end

    -- Check if hit static
    if otherF:getBody():getType() == "static" and not otherF:isSensor() then
      self:hitSolidStatic(other, myF, otherF)
    end

    -- Force next direction to avoid further collisions
    if not otherF:isSensor() then
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
    end

    -- Check if hit by sword
    if other.immasword == true and not self.invulnerable then
      self:hitBySword(other, myF, otherF)
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    if self.flying then
      -- Find which fixture belongs to whom
      local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
      if not other.roomEdge then coll:setEnabled(false) end
    else
      -- Find which fixture belongs to whom
      local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
      if other.floor then
        if other.water and self.invulnerable and not self.shieldWall then
          o.removeFromWorld(self)
          if not other.startSinking then other.startSinking = true end
        end
        if other.gap and self.invulnerable and not self.shieldWall then
          o.removeFromWorld(self)
          if not other.startFalling then other.startFalling = true end
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
