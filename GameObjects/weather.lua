local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local im = require "image"
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

---@class CreateCloudOptions
---@field side "left" | "right" | "up" | "down"

-- TODOMAYBE: create better algorithm for cloud creation that creates non overlapping clouds efficiently

---@param number number
---@param w number
---@param h number
---@param options? CreateCloudOptions
---@return Cloud[]
local function createClouds(number, w, h, options)
  ---@type Cloud[]
  local c = {}

  local x0, y0, dx, dy = 0, 0, 0, 0
  local xbound, ybound = 100, 35
  local cloudW, cloudH = 100 + xbound, 100 + ybound

  if options then
    if options.side == "left" then
      dx = cloudW * 0.5
    elseif options.side == "right" then
      x0 = cloudW * 0.5
      dx = x0
    elseif options.side == "up" then
      dy = cloudH * 0.5
    elseif options.side == "down" then
      y0 = cloudH * 0.5
      dy = y0
    end
  end

  for _ = 1, number do
    ---@type Cloud
    local cloud = {
      density = 1,
      angle = love.math.random() * 2 * math.pi,
      x = x0 + love.math.random(w - dx),
      y = y0 + love.math.random(h - dy),
      shape = {},
      w = cloudW,
      h = cloudH
    }

    for _ = 1, 3 + love.math.random(3) do
      local x, y = u.randomPointFromEllipse(xbound, ybound)
      table.insert(cloud.shape, {x=x, y=y})
    end

    table.insert(c, cloud)
  end

  return c
end

local function drawCloud(layer, cloud, x, y)
  local w2, h2 = cloud.w * 0.5, cloud.h * 0.5
  if not (x + w2 < caml or x - w2 > caml + camw or y + h2 < camt or y - h2 > camt + camh) then
    lighting.applyShadow{
      type = "cloudCurve",
      x = x,
      y = y,
      rgba = {
        r = 1,
        g = 1,
        b = 1,
        a = cloud.density * layer.opacity --* game.transitioning.progress
      },
    }
  end
end

local raindropHeight = 10
local raindropYSpeed = 200
local prevCaml = -1.0
local prevCamt = -1.0
local prevCamw = -1.0
local prevCamh = -1.0
local function rainSplash()
  local explOb = (require "GameObjects.explode"):new{
    x = prevCaml + math.random() * prevCamw, y = prevCamt + math.random() * prevCamh,
    layer = 15,
    explosionNumber = 1,
    explosion_sprite = im.spriteSettings.rainSplash,
    image_speed = 0.1,
    nosound = true,
  }
  o.addToWorld(explOb)
end

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
  instance.rainIntensity = 0
  instance.raindrops = {}
  instance.outgoingRaindrops = {}
  for _ = 1,300 do
    table.insert(instance.raindrops, {x = 0, y = 0})
    table.insert(instance.outgoingRaindrops, {x = 0, y = 0})
  end
end

-- sun is a huge light source veeeery far away, therefore:
-- sun shadows are about as big as the casting object
-- it's so far that it produces sharp shadows for objects that aren't too high
-- the higher from the groud the casting object goes the fuzzier the shadow (more penumbra)
-- objects that are close are lit from the same angle.
-- You need to travel far for the angle to change and it won't be noticable when objects are close to each other.

---@class WeatherMethods
Weather.functions = {
  ---@param self WeatherType
  ---@return table<string, CloudLayer>
  getCloudLayers = function(self)
    return self.clouds
  end,

  ---@param self WeatherType
  ---@return table<string, CloudLayer>
  getOutgoingCloudLayers = function(self)
    return self.outgoingClouds
  end,

  ---@param self WeatherType
  ---@param name string
  ---@return CloudLayer | nil
  getCloudLayer = function(self, name)
    return self.clouds[name]
  end,

  ---@param self WeatherType
  ---@param name string
  ---@param cl CloudLayer
  setCloudLayer = function(self, name, cl)
    self.clouds[name] = cl
  end,

  ---@param self WeatherType
  ---@param options? CreateCloudOptions
  createClouds = function(self, options)
    self.clouds = {}
    self:setCloudLayer('l1', {opacity = .3, clouds = createClouds(25, game.room.width, game.room.height, options)})
  end,

  ---gets wind direction of room in rads
  ---@param self WeatherType
  getWindDirection = function(self)
    return self.windDir or 0.0
  end,

  ---@param self WeatherType
  getWindSpeed = function(self)
    return self.windSpeed or 20.0
  end,

  ---@param self WeatherType
  getWindVelocity = function(self)
    return u.polarToCartesian(self:getWindSpeed(), self:getWindDirection())
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

          local side = game.transitioning.side

          if game.isWorldScreen() then
            self:createClouds({side = side})
          end

          -- Check if outgoing clouds are in bounds of the new
          -- screen and if yes add them to new cloud layers

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

          local newCaml, newCamt = prevCaml, prevCamt
          if side == "left" then
            newCaml = game.room.width - prevCamw
          elseif side == "right" then
            newCaml = 0
          elseif side == "up" then
            newCamt = game.room.height - prevCamh
          elseif side == "down" then
            newCamt = 0
          end

          -- Populate outgoing and incoming raindrops
          for i, drop in ipairs(self.raindrops) do
            self.outgoingRaindrops[i] = u.deep_copy(drop)

            drop.x = newCaml + prevCamw * math.random()
            drop.y = newCamt + prevCamh * math.random()
          end
        end
      end
    end
  end,

  ---@param self WeatherType
  update = function (self, dt)
    -- Clouds
    local vx, vy = self:getWindVelocity()
    for _, l in pairs(self:getCloudLayers()) do
      for _, cloud in ipairs(l.clouds) do
        -- Move clouds
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

    --Rain

    -- TEMP
    self.rainIntensity = 1

    local activeRaindrops = 0
    local maxRaindrops = math.floor(self.rainIntensity * #self.raindrops)
    local activatedRaindrop = false
    if not game.paused then
      if self.rainIntensity > 0 and game.isWorldScreen() then
        -- Timer before new raindrop is created
        self.rTimer = self.rTimer or 0.1
        self.rTimer = self.rTimer - dt
        if self.rTimer <= 0 then
          self.rTimer = nil
          rainSplash()
          if math.random() < 0.15 then rainSplash() end
        end
      end

      for i = 1,#self.raindrops do
        local drop = self.raindrops[i]

        -- Mark if active or dead
        if activeRaindrops < maxRaindrops then
          if not drop.active and not activatedRaindrop then
            if self.rTimer == nil then
              drop.init = true
            end
            activatedRaindrop = true
          end
        else
          drop.dead = true
        end
        if drop.active then activeRaindrops = activeRaindrops + 1 end

        -- Move
        drop.x = drop.x + vx * dt
        drop.y = drop.y + dt * raindropYSpeed
      end
    end
  end,

  ---@param self WeatherType
  draw = function (self)
    -- Only draw weather in world screen
    if not game.isWorldScreen() then return end

    local ls = self:getCloudLayers()
    for _, l in pairs(ls) do
      for _, cloud in ipairs(l.clouds) do
        for _, part in ipairs(cloud.shape) do
          drawCloud(l, cloud, cloud.x + part.x, cloud.y + part.y)
        end
      end
    end

    local vx = self:getWindVelocity()

    prevCaml = caml
    prevCamt = camt
    prevCamw = camw
    prevCamh = camh

    -- Rain
    for _, drop in ipairs(self.raindrops) do
      if drop.init then
        drop.init = false
        drop.active = true
        drop.x = love.math.random(caml, caml + camw)
        drop.y = camt
      end
      if drop.active then

        -- Raindrop falls off screen
        while drop.y - raindropHeight > camt + camh do
          if drop.dead then
            -- Deactivate raindrop
            drop.active = false
            drop.y = camt
          else
            -- Reposition raindrop
            drop.x = love.math.random(caml, caml + camw)
            drop.y = drop.y - camh - raindropHeight
          end
        end

        local dropWidth = vx * 10 / raindropYSpeed
        -- Raindrop width if moving towards right
        local leftwidth = dropWidth > 0 and dropWidth or 0
        -- Raindrop width if moving towards left
        local rightwidth = dropWidth < 0 and -dropWidth or 0

        -- wraparound
        if drop.x - leftwidth > caml + camw then
          drop.x = caml - rightwidth
        end
        if drop.x - rightwidth < caml then
          drop.x = caml + camw - leftwidth
        end

        -- Draw
        local resetCol = u.storeColour()
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * 0.5)
        love.graphics.line(drop.x, drop.y, drop.x - dropWidth, drop.y - raindropHeight)
        resetCol()
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
            drawCloud(l, cloud, x, y)
          end
        end
      end

      -- Rain
      for _, drop in ipairs(self.outgoingRaindrops) do
        if drop.active then

          local vx = self:getWindVelocity()

          local dropWidth = vx * 10 / raindropYSpeed

          -- Draw
          local resetCol = u.storeColour()
          love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * 0.5)
          local x, y = transitions.transform(drop.x, drop.y)
          love.graphics.line(x, y, x - dropWidth, y - raindropHeight)
          resetCol()
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
          drawCloud(l, cloud, x, y)
        end
      end
    end

    -- Rain
    for _, drop in ipairs(self.raindrops) do
      if drop.active then

        local vx = self:getWindVelocity()

        local dropWidth = vx * 10 / raindropYSpeed

        -- Draw
        local resetCol = u.storeColour()
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * 0.5)
        local x, y = transitions.transform(drop.x, drop.y, true)
        love.graphics.line(x, y, x - dropWidth, y - raindropHeight)
        resetCol()
      end
    end
  end
}

---@class WeatherType : WeatherMethods
---@field clouds table<string, CloudLayer>
---@field outgoingClouds table<string, CloudLayer> | nil
---@field windDir number | nil
---@field windSpeed number | nil
---@field rTimer number | nil
---@field raindrops table<number, Raindrop>
---@field outgoingRaindrops table<number, Raindrop>
---@field rainIntensity number

---@class CloudLayer
---@field clouds Cloud[]
---@field opacity number

---@class Raindrop
---@field x number
---@field y number
---@field active boolean
---@field dead boolean
---@field init boolean

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
