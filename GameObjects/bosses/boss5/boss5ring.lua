local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local sm = require "state_machine"
local u = require "utilities"
local o = require "GameObjects.objects"

local pointMethods = {
  __index = {
    updateTheta = function(self, dt)
      local v = self.angvel * dt
      if self.theta_buffer > 0 then
        self.theta_buffer = self.theta_buffer - math.abs(v)

        -- Prevent theta from changing untill theta buffer is empty
        if self.theta_buffer > 0 then return end

        -- Take remaining value and apply it to theta like normal
        local s = u.sign(v)
        v = -self.theta_buffer * s
      end
      self.theta = (self.theta + v) % (2 * math.pi)
    end,
  }
}

-- defaults are 0. theta_buffer changes instead of theta when not zero.
local function newPoint(point_init)
  local point = {
    theta = point_init.theta or 0, -- Position on ring
    theta_buffer = point_init.theta_buffer or 0,
    angvel = point_init.angvel or 0
  }
  setmetatable(point, pointMethods)
  return point
end

local obj = {}

function obj.initialize(instance)
  instance.layer = pl1.layer

  instance.points = {}
  for i = 1, 8 do
    local th = math.pi * (i - 1) / 4
    table.insert(instance.points, newPoint{theta = th, theta_buffer = 0, angvel = 1})
  end

  -- Ring axes scaling.
  instance.x_scale = 1
  instance.y_scale = .1

  -- Ring radius.
  instance.r = 64

  -- Angular velocity of ring rotation.
  instance.angvel = 1

  -- Rotation of ring
  instance.rotation = 0
end

obj.functions = {
  getX = function(self)
    return (self.x or 0) + self:getParentX()
  end,

  getY = function(self)
    return (self.y or 0) + self:getParentY()
  end,

  getParentX = function(self)
    if not self.parent then return 0 end
    if not self.parent.x then return 0 end
    return self.parent.x
  end,

  getParentY = function(self)
    if not self.parent then return 0 end
    if not self.parent.y then return 0 end
    return self.parent.y
  end,

  update = function(self, dt)
    self.rotation = (self.rotation + self.angvel * dt) % (2 * math.pi)
    for _, point in ipairs(self.points) do
      point:updateTheta(dt)
    end
  end,

  draw = function (self)
    for i, point in ipairs(self.points) do
      -- Find x and y on ring
      local x, y = u.polarToCartesian(self.r, point.theta)
      -- Find x and y on transformed ring
      x, y = self.x_scale * x, self.y_scale * y
      -- Find polar coords of x and y on transformed ring
      local r, th = u.cartesianToPolar(x, y)
      -- Rotate found polar coords by whole ring rotation
      x, y = u.polarToCartesian(r, th + self.rotation)

      love.graphics.circle("line", x + self:getX(), y + self:getY(), 3)
      love.graphics.print(tostring(i), x + self:getX(), y + self:getY(), 0, .1)
    end
  end,
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
