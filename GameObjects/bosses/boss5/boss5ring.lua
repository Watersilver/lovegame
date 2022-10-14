local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local sm = require "state_machine"
local u = require "utilities"
local o = require "GameObjects.objects"

function initval(val, init)
  if val == nil then return init end
  return val
end

local axesSizeStates = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    check_state = function(instance, dt)
      if true then
        instance.ass:change_state(instance, dt, "smoothAlternating")
      end
    end,
    end_state = function(instance, dt)
    end
  },
  smoothAlternating = {
    run_state = function(instance, dt)
      instance.v = {0,0}
      local axis = instance.ass.r1 and 1 or 2

      if instance.ass.speed > 0 and instance["r" .. axis] == 1 then
        instance.ass.speed = -instance.ass.speed
        instance.ass.r1 = not instance.ass.r1
      elseif instance.ass.speed < 0 and instance["r" .. axis] <= .50 then
        instance.ass.speed = -instance.ass.speed
      end

      instance.v[axis] = instance.ass.speed
    end,
    start_state = function(instance, dt)
      instance.ass.r1 = initval(instance.ass.r1, true)
      instance.ass.speed = initval(instance.ass.speed, .1)
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
      instance.ass.r1 = nil
      instance.ass.speed = nil
    end
  },
}

local obj = {}

function obj.initialize(instance)
  instance.layer = pl1.layer

  instance.ass = sm.new_state_machine(axesSizeStates)
  instance.ass.state = "start"

  -- normalised axes of ellipse
  instance:setR1(.5)
  instance:setR2(1)

  -- r1 and r2 grow/shrink velocity
  instance.v = {0, 0}

  -- length of semi-major when max (i.e. r1 or r2 is 1)
  instance:setRmax(64)

  -- Whole ellipse angle
  instance:setAngle(0)
  -- Whole ellipse angular valocity
  instance.w = -.2

  -- Angular velocity of ellipse perimeter
  instance.wp = .1

  -- if I have parent these are relative coords
  instance.x = instance.x or 0
  instance.y = instance.y or 0

  -- xstart and ystart are absolute coords
  instance.xstart = instance:getAbsoluteX()
  instance.ystart = instance:getAbsoluteY()

  instance:setAngle(0)

  instance:createPolarPoints(13)
end

obj.functions = {
  setR1 = function (self, v)
    self.r1 = u.clamp(0, v, 1)
  end,
  setR2 = function (self, v)
    self.r2 = u.clamp(0, v, 1)
  end,
  setRmax = function (self, v)
    self.rmax = math.max(v, 0)
  end,
  setAngle = function (self, v)
    self.angle = v % (2 * math.pi)
  end,

  getAbsoluteX = function (self)
    return self.x + self:getParentX()
  end,
  getAbsoluteY = function (self)
    return self.y + self:getParentY()
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

  isVertical = function(self)
    return self.r2 > self.r1
  end,

  -- semi-major
  a = function (self)
    if self:isVertical() then
      return self.r2 * self.rmax
    else
      return self.r1 * self.rmax
    end
  end,

  -- semi-minor
  b = function (self)
    if self:isVertical() then
      return self.r1 * self.rmax
    else
      return self.r2 * self.rmax
    end
  end,

  -- eccentricity
  e = function (self)
    local e = (1 - (self:b() / self:a()) ^ 2) ^ 0.5

    -- Guard against divisions by 0
    return u.defineUndefined(e, 0)
  end,

  -- distance from center
  r = function (self, theta)
    -- Modify theta angle so equation works for vertical
    if (self:isVertical()) then theta = theta - math.pi / 2 end

    local r = self:b() / (1 - (self:e() * math.cos(theta)) ^ 2) ^ 0.5

    -- Guard against divisions by 0
    return u.defineUndefined(r, 0)
  end,

  createPolarPoints = function (self, number)
    local points = {}

    for point = 0, number - 1 do
      table.insert(points, {
        r = 0,
        th = 2 * math.pi * point / number
      })
    end

    self.points = points
  end,

  updatePolarPoints = function (self, dt)
    for _, point in ipairs(self.points) do
      point.th = (point.th + dt * self.wp) % (2 * math.pi)
      point.r = self:r(point.th)
    end
  end,

  updateEllipse = function (self, dt)
    self:updatePolarPoints(dt)

    self:setAngle(self.angle + dt * self.w)

    self:setR1(self.r1 + dt * self.v[1])
    self:setR2(self.r2 + dt * self.v[2])
  end,

  update = function (self, dt)
    -- do stuff depending on states
    local ass = self.ass
    ass.states[ass.state].check_state(self, dt)
    ass.states[ass.state].run_state(self, dt)

    self:updateEllipse(dt)
  end,

  draw = function (self)
    for _, point in ipairs(self.points) do
      local x, y = u.polarToCartesian(point.r, point.th + self.angle)

      love.graphics.circle("line", x + self:getAbsoluteX(), y + self:getAbsoluteY(), 3)
      love.graphics.print(_, x + self:getAbsoluteX(), y + self:getAbsoluteY(), 0, .1)
    end
  end,
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
