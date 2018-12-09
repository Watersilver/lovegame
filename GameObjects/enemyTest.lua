local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local td = require "movement"; td = td.top_down

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
    masks = {ENEMYATTACKCAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.zo = 0
  instance.image_speed = 0
  instance.image_index = 0
  instance.impact = 20 -- how far I throw the player
  instance.damager = 1 -- how much damage I cause
  instance.grounded = true -- can be jumped over
end

Enemy.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
  end,

  update = function (self, dt)
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
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
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local xtotal, ytotal = trans.still_objects_coords(self)

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
    if other.immasword == true then
      local speed = 111
      local prevvx, prevvy = self.body:getLinearVelocity()

      local xadjust, yadjust
      local side = other.side
      if side == "left" or side == "right" then
        xadjust, yadjust = 0, 4
      elseif side == "up" then
        xadjust, yadjust = -3, 0
      else
        xadjust, yadjust = 3, 0
      end

      local ox, oy = other.body:getPosition()
      local adj, opp = self.x - ox - xadjust, self.y - oy - yadjust
      local hyp = math.sqrt(adj*adj + opp*opp)

      self.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
      -- mybod:applyLinearImpulse(h, g)
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
