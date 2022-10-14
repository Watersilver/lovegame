local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"

-- Closes behind player when entering this room
local seal = {}

function seal.initialize(instance)
  instance.image_index = 12
  instance.sprite_info = {im.spriteSettings.clutter}
  instance.physical_properties = {
    bodyType = "kinematic",
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1,
    mass = 40,
    linearDamping = 40,
    restitution = 0,
  }
  instance.layer = 20
  instance.pushback = true
  instance.ballbreaker = true
  instance.forceSwordSound = true
end

seal.functions = {
  load = function (self)
    self.body:setLinearVelocity(0, -10);
  end,

  -- early_update = functio (self, dt)
  -- end,

  update = function (self, dt)
    self.x, self.y = self.body:getPosition()
    if self.stop then return end
    if self.y <= self.ystart - 16 then
      self.body:setLinearVelocity(0, 0)
      self.body:setPosition(200, 232)
      self.stop = true
    end
  end,

  -- late_update = functio (self, dt)
  -- end,

  draw = function (self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  -- beginContact = function (self, a, b, coll)
  -- end,

  -- endContact = function (self, a, b, coll)
  -- end,

  -- preSolve = function (self, a, b, coll)
  -- end,
}

function seal:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(seal, instance, init) -- add own functions and fields
  return instance
end

return seal
