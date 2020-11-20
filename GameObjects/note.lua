local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"

local Note = {}

function Note.initialize(instance)
  instance.sprite_info = {im.spriteSettings.note}
  instance.x_scale = 1
  instance.y_scale = 1
  instance.timer = 1
  instance.angvel = 1
  instance.phase = 0
  instance.magnitude = 2
  instance.yVel = -13
end

local angvelRandomizer = {
  {weight = 100, value = 1},
  {weight = 50, value = 2},
  {weight = 25, value = 5}
}
local magnRandomizer = {
  {weight = 100, value = 2},
  {weight = 50, value = 4},
  {weight = 25, value = 7}
}
Note.functions = {
  load = function (self)
    self.xstart = self.x
    self.ystart = self.y
    if self.randomize then
      local angvelside = (love.math.random() > 0.5) and 1 or -1
      self.angvel = angvelside * u.chooseFromWeightTable(angvelRandomizer)
      self.magnitude = u.chooseFromWeightTable(magnRandomizer)
    end
  end,

  destroy = function (self)
  end,

  update = function (self, dt)
    self.phase = self.phase + self.angvel * dt
    self.x = self.xstart + math.sin(self.phase) * self.magnitude
    self.y = self.y + self.yVel * dt

    -- Determine coordinates for transition
    self.xlast = self.x
    self.ylast = self.y

    -- See how long it lasts
    if self.timer < 0 then
      o.removeFromWorld(self)
    end

    -- update timer
    self.timer = self.timer - dt
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    self.x, self.y = x, y

    local sprite = self.sprite
    local frame = sprite[0]
    -- local worldShader = love.graphics.getShader()

    -- love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale,
    sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.setShader(worldShader)
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast
    self:draw(true)
  end,
}

function Note:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Note, instance, init) -- add own functions and fields
  return instance
end

return Note
