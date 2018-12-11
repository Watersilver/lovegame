local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local td = require "movement"; td = td.top_down
local si = require "sight"

local dc = require "GameObjects.Helpers.determine_colliders"

local Enemy = {}

function Enemy.initialize(instance)
  instance.sprite_info = { im.spriteSettings.testenemy }
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    density = 160, --160 is 50 kg when combined with plshape dimensions(w 10, h 8)
    shape = ps.shapes.plshape,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0,
    masks = {ENEMYATTACKCAT},
    categories = {DEFAULTCAT, FLOORCOLLIDECAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.zo = 0
  instance.image_speed = 0
  instance.image_index = 0
  instance.impact = 20 -- how far I throw the player
  instance.damager = 1 -- how much damage I cause
  instance.grounded = true -- can be jumped over
  instance.lookFor = si.lookFor
end

Enemy.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
  end,

  enemyUpdate = function (self, dt)
    if self.invulnerable then
      self.invulnerable = self.invulnerable - dt
      if self.invulnerable < 0 then self.invulnerable = nil end
    end
    if self.lookFor then self.canSeePlayer = self:lookFor(player) end
  end,

  update = function (self, dt)
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
    self:enemyUpdate(dt)
    td.stand_still(self, dt)
  end,

  draw = function (self)
    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
    self.spritebody:setPosition(self.x, self.y)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    local sprite = self.sprite
    local frame = sprite[self.image_index]

    love.graphics.draw(
    sprite.img, frame, self.x, self.y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- end

    si.drawRay(self, player)
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local xtotal, ytotal = trans.moving_objects_coords(self)

    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   -- draw
    -- end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Check if propelled by sword
    if other.immasword == true and not self.invulnerable then
      self.invulnerable = 0.25
      local speed = 111 * self.body:getMass()
      local prevvx, prevvy = self.body:getLinearVelocity()

      local xadjust, yadjust

      local ox, oy = other.body:getPosition()
      local adj, opp = self.x - ox, self.y - oy
      local hyp = math.sqrt(adj*adj + opp*opp)

      -- self.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
      self.body:applyLinearImpulse(speed*adj/hyp, speed*opp/hyp)
    end

    if self.grounded then
      if other.floor then
        if other.water then
          o.removeFromWorld(self)
          if not other.startSinking then other.startSinking = true end
        end
        if other.gap then
          o.removeFromWorld(self)
          if not other.startFalling then other.startFalling = true end
        end
      end
    end

    -- edge handling:
    -- store my velocity
    -- compare it to edge side.
    -- if I go through one edge without getting destroyed I go through all of them
  end
}

function Enemy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Enemy, instance, init) -- add own functions and fields
  return instance
end

return Enemy
