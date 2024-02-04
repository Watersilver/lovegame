local p = require "GameObjects.prototype"
local u = require "utilities"
local utilities = require "utilities"
local lighting = require 'ScreenEffects.lighting.lighting'

local Particles = {}

function Particles.initialize(instance)
  instance.simpleSparks = {}
  instance.colouredSparks = {}
  instance.age = 0
  instance.layer = 25
  instance.transPersistent = true
end

local function addDefault(self, sparkInfo, sparkType)
  sparkInfo.birth = self.age
  sparkInfo.lifespan = sparkInfo.lifespan or 1
  sparkInfo.vy = sparkInfo.vy or -5
  sparkInfo.vx = sparkInfo.vx or 0
  sparkInfo.birthRoom = session.latestVisitedRooms:getLast()
  table.insert(self[sparkType], sparkInfo)
end

local function updateDefault(self, dt, sparkType)
  local sparkInfo = nil
  local age = self.age
  local sparks = self[sparkType] or self.simpleSparks
  local currentRoom = session.latestVisitedRooms:getLast()
  for i = 1,#sparks do
    -- delete sparks whose time is past
    while
    sparks[i] ~= nil and
    (
      age - sparks[i].birth >= sparks[i].lifespan or
      currentRoom ~= sparks[i].birthRoom
    )
    do
      sparks[i], sparks[#sparks] = sparks[#sparks], sparks[i]
      table.remove(sparks)
    end
    sparkInfo = sparks[i]
    -- if sparkInfo has been deleted break
    if sparkInfo == nil then return end

    -- do the updating
    sparkInfo.y = sparkInfo.y + dt * sparkInfo.vy
    sparkInfo.x = sparkInfo.x + dt * sparkInfo.vx
  end
end

Particles.functions = {
  updateAge = function (self, dt)
    self.age = self.age + dt
    -- Set lifetime back to 0 if too high and ensure spark lifetime doesn't get ruined.
    -- Probably won't need to do that because too high are thousands of years apparently
  end,

  updateSimpleSparks = function (self, dt)
    updateDefault(self, dt, "simpleSparks")
  end,

  updateColouredSparks = function (self, dt)
    updateDefault(self, dt, "colouredSparks")
  end,

  addSpark = function (self, sparkInfo)
    addDefault(self, sparkInfo, "simpleSparks")
  end,

  addColouredSpark = function (self, sparkInfo)
    local r, g, b, a = HSL(love.math.random(), 1, (love.math.random() * 0.5 + 0.5), 0.9)
    sparkInfo.color = sparkInfo.color or {r = r, g = g, b = b, a = a}
    addDefault(self, sparkInfo, "colouredSparks")
  end,

  update = function (self, dt)
    self:updateAge(dt)
    self:updateSimpleSparks(dt)
    self:updateColouredSparks(dt)
  end,

  draw = function (self)
    for _, sparkInfo in ipairs(self.simpleSparks) do
      love.graphics.rectangle("fill", sparkInfo.x, sparkInfo.y, 1, 1);
      lighting.applyLight{
        type = 'pixel',
        x = sparkInfo.x,
        y = sparkInfo.y
      }
    end

    local restoreColour = utilities.storeColour()
    for _, sparkInfo in ipairs(self.colouredSparks) do
      local c = sparkInfo.color
      love.graphics.setColor(c.r, c.g, c.b, c.a)
      love.graphics.rectangle("fill", sparkInfo.x, sparkInfo.y, 1, 1);
      lighting.applyLight{
        type = 'pixel',
        x = sparkInfo.x,
        y = sparkInfo.y,
        rgba = {
          r = c.r,
          g = c.g,
          b = c.b,
          a = 1
        }
      }
    end
    restoreColour()
  end
}

function Particles:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Particles, instance, init) -- add own functions and fields
  return instance
end

return Particles
