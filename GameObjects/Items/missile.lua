local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local Missile = {}

local floor = math.floor
local pi = math.pi
local sqrt = math.sqrt

--  Calculate sword position and angle offset due to creator's side
local function calculate_offset(side, phase)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    xoff = 0
    yoff = 3
  elseif side == "right" then
    xoff = 9
    yoff = 3
  elseif side == "left" then
    xoff = - 9
    yoff = 3
  elseif side == "up" then
    xoff = 0
    yoff = - 7
  end
  return xoff, yoff
end

function Missile.initialize(instance)

  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = {
    {'Inventory/UseMissileL1', 5, padding = 2, width = 4, height = 4}
  }
  -- instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.missile,
    categories = {PLAYERATTACKCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
end

Missile.functions = {
  load = function (self)
    self.sox, self.soy = calculate_offset(self.side)
  end,

  early_update = function(self, dt)
    local cr = self.creator

    if self.weld and not self.weld:isDestroyed() then self.weld:destroy(); self.weld = nil end

    if not self.fired then

      if cr.missile_cooldown then
        local stage = cr.missile_cooldown/cr.missile_cooldown_limit
        self.image_index = stage * (self.sprite.frames - 1)
      end

      -- Determine offset due to falling
      local fy = 0
      if cr.edgeFall and cr.edgeFall.step2 then
        fy = - cr.edgeFall.height
      end

      -- Set position
      local creatorx, creatory = cr.body:getPosition()
      local x, y = creatorx + self.sox, creatory + self.soy + cr.zo + fy
      self.body:setPosition(x, y)

      -- Weld
      self.weld = love.physics.newWeldJoint(cr.body, self.body, x, y, true)

      local layeradjust = 0
      if self.side == "up" then layeradjust = -1 end
      o.change_layer(self, cr.layer+layeradjust)
    -- else
    --   self.weld = nil
    end

    -- if self.spritejoint then self.spritejoint:destroy() end
    local x, y = self.body:getPosition()
    -- self.spritebody:setPosition(x, y)
    -- self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    self.x, self.y = x, y

  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x = x + trans.xtransform
      y = y + trans.ytransform
    end

    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    -- Debug
    -- love.graphics.polygon("line",
    -- self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.circle("line", x, y, self.fixture:getShape():getRadius())
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Check if propelled by sword
    if other.sword == true then
      local speed = 200
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

      local adj, opp = self.x - cr.x - xadjust, self.y - cr.y - yadjust
      local hyp = sqrt(adj*adj + opp*opp)

      self.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
    end

    -- edge handling:
    -- store my velocity
    -- compare it to edge side.
    -- if I go through one edge without getting destroyed I go through all of them
  end,

  preSolve = function(self, a, b, coll, aob, bob)
  end,

  delete = function(self)
    if self == self.creator.missile then self.creator.missile = nil end
  end
}

function Missile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Missile, instance, init) -- add own functions and fields
  return instance
end

return Missile
