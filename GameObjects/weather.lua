local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local snd = require "sound"
local lighting = require "ScreenEffects.lighting.lighting"
local transitions = require "transitions"

---@class Cloud
---@field shape {radius: number, x: number, y: number}[]
---@field density number
---@field angle number
---@field x number
---@field y number
---@field w number
---@field h number

---@param number number
---@param w number
---@param h number
---@return Cloud[]
local function createClouds(number, w, h)
  ---@type Cloud[]
  local c = {}

  for _ = 1, number do
    ---@type Cloud
    local cloud = {
      density = 1,
      angle = love.math.random() * 2 * math.pi,
      x = love.math.random(w),
      y = love.math.random(h),
      shape = {},
      w = 200,
      h = 135
    }

    for _ = 1, 3 + love.math.random(3) do
      local x, y = u.randomPointFromEllipse(100, 35)
      table.insert(cloud.shape, {x=x, y=y})
    end

    table.insert(c, cloud)
  end

  return c
end

---@class CloudLayer
---@field clouds Cloud[]
---@field opacity number

local Weather = {}

function Weather.initialize(instance)
  instance.persistent = true
  instance.ids[#instance.ids+1] = "Weather"
  if o.identified.Weather and o.identified.Weather[1].exists then
    error( "Trying to instantiate multiple weathers." )
  end
  instance.layer = 30
  instance.windDir = 0.5
  instance.windSpeed = 17
  instance.outgoingOpacity = 0
  instance.incomingOpacity = 0
  instance.outgoingOpacityTarget = 0
  instance.incomingOpacityTarget = 0

  instance.clouds = {}
  instance.outgoingClouds = {}
end

-- sun is a huge light source veeeery far away, therefore:
-- sun shadows are about as big as the casting object
-- it's so far that it produces sharp shadows for objects that aren't too high
-- the higher from the groud the casting object goes the fuzzier the shadow (more penumbra)
-- objects that are close are lit from the same angle.
-- You need to travel far for the angle to change and it won't be noticable when objects are close to each other.

---@class WeatherMethods
Weather.functions = {
  ---@return table<string, CloudLayer>
  getCloudLayers = function(self)
    return self.clouds
  end,

  ---@return table<string, CloudLayer>
  getOutgoingCloudLayers = function(self)
    return self.outgoingClouds
  end,

  ---@param name string
  ---@return CloudLayer | nil
  getCloudLayer = function(self, name)
    return self.clouds[name]
  end,

  ---@param name string
  ---@param cl CloudLayer
  setCloudLayer = function(self, name, cl)
    self.clouds[name] = cl
  end,

  createClouds = function(self)
    self.clouds = {}
    self:setCloudLayer('l1', {opacity = .3, clouds = createClouds(3, game.room.width, game.room.height)})
  end,

  ---gets wind direction of room in rads
  getWindDirection = function(self)
    return self.windDir or 0.0
  end,

  getWindSpeed = function(self)
    return self.windSpeed or 20.0
  end,

  ---@param self WeatherType
  unstoppable_update = function(self, dt)
    if game.transitioning then
      if game.transitioning.firstFrame then
        -- Create weather effects
        if game.transitioning.type == "whiteScreen" then
          if game.isWorldScreen() then
            self:createClouds()
          end
        elseif game.transitioning.type == "scrolling" then
          self.outgoingClouds = self.clouds
          if game.isWorldScreen() then
            self:createClouds()
          end

          -- Check if outgoing clouds are in bounds of the new
          -- screen and if yes add them to new cloud layers

          local side = game.transitioning.side

          local dx, dy = 0, 0
          if side == "left" then
            dx = game.room.width
          elseif side == "right" then
            dx = -game.prevRoom.width
          elseif side == "up" then
            dy = game.room.height
          elseif side == "down" then
            dy = -game.prevRoom.height
          end

          local ls = self:getOutgoingCloudLayers()
          for layerName, l in pairs(ls) do
            for i, cloud in ipairs(l.clouds) do
              local newX, newY = cloud.x + dx, cloud.y + dy
              local outOfBounds = newX + cloud.w * 0.5 < 0 or
                newY + cloud.h * 0.5 < 0 or
                newX - cloud.w * 0.5 > game.room.width or
                newY - cloud.h * 0.5 > game.room.height
              if not outOfBounds then
                if not self.clouds[layerName] then self.clouds[layerName] = {clouds = {}, opacity = l.opacity} end
                if not self.clouds[layerName].clouds then self.clouds[layerName].clouds = {} end
                local newCloud = u.deep_copy(cloud)
                newCloud.x, newCloud.y = newX, newY
                if not self.clouds[layerName].clouds[i] then
                  table.insert(self.clouds[layerName].clouds, newCloud)
                else
                  self.clouds[layerName].clouds[i] = newCloud
                end
              end
            end
          end
        end
      end
    end

    -- on transition end adjust cloud coordinates
  end,

  ---@param self WeatherType
  update = function (self, dt)
    for _, l in pairs(self:getCloudLayers()) do
      for _, cloud in ipairs(l.clouds) do
        -- Move clouds
        local vx, vy = u.polarToCartesian(self:getWindSpeed(), self:getWindDirection())
        cloud.x = cloud.x + vx * dt
        cloud.y = cloud.y + vy * dt

        -- Loop out of bounds clouds
        if cloud.x + cloud.w * 0.5 < 0 then
          cloud.x = game.room.width + cloud.w * 0.5
        end
        if cloud.y + cloud.h * 0.5 < 0 then
          cloud.y = game.room.height + cloud.h * 0.5
        end
        if cloud.x - cloud.w * 0.5 > game.room.width then
          cloud.x = -cloud.w * 0.5
        end
        if cloud.y - cloud.h * 0.5 > game.room.height then
          cloud.y = -cloud.h * 0.5
        end
      end
    end
  end,

  ---@param self WeatherType
  draw = function (self)
    -- Only  draw clouds in world screen
    if not game.isWorldScreen() then return end

    local ls = self:getCloudLayers()
    for _, l in pairs(ls) do
      for _, cloud in ipairs(l.clouds) do
        for _, part in ipairs(cloud.shape) do
          lighting.applyShadow{
            type = "cloudCurve",
            x = cloud.x + part.x,
            y = cloud.y + part.y,
            rgba = {
              r = 1,
              g = 1,
              b = 1,
              a = cloud.density * l.opacity
            },
          }
        end
      end
    end
  end,

  ---@param self WeatherType
  trans_draw = function(self)
    if game.wasWorldScreen() then
      local ls = self:getOutgoingCloudLayers()
      for _, l in pairs(ls) do
        for _, cloud in ipairs(l.clouds) do
          for _, part in ipairs(cloud.shape) do
            local x, y = cloud.x + part.x, cloud.y + part.y
            x, y = transitions.transform(x, y)
            lighting.applyShadow{
              type = "cloudCurve",
              x = x,
              y = y,
              rgba = {
                r = 1,
                g = 1,
                b = 1,
                a = cloud.density * l.opacity --* (1 - game.transitioning.progress)
              },
            }
          end
        end
      end
    end

    if not game.isWorldScreen() then return end

    local ls = self:getCloudLayers()
    for _, l in pairs(ls) do
      for _, cloud in ipairs(l.clouds) do
        for _, part in ipairs(cloud.shape) do
          local x, y = cloud.x + part.x, cloud.y + part.y
          x, y = transitions.transform(x, y, true)
          lighting.applyShadow{
            type = "cloudCurve",
            x = x,
            y = y,
            rgba = {
              r = 1,
              g = 1,
              b = 1,
              a = cloud.density * l.opacity --* game.transitioning.progress
            },
          }
        end
      end
    end
  end
}

---@class WeatherType : WeatherMethods
---@field clouds table<string, CloudLayer>

---@return WeatherType
function Weather:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Weather, instance, init) -- add own functions and fields
  return instance
end

local singleton

---@return WeatherType
function Weather:create(init)
  if not singleton then
    singleton = Weather:new(init)
    o.addToWorld(singleton)
  end
  return Weather:get()
end

---@return WeatherType
function Weather:get()
  return singleton
end

return Weather
