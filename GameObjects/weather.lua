local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local im = require "image"
local transitions = require "transitions"

-- -- Played with noise
-- local data = love.image.newImageData(80 * 3, 45 * 3)
-- local noiseImg = love.graphics.newImage(data)
-- local noiseT = 0
-- local gx, gy = -love.math.random() * 100000, -love.math.random() * 100000
-- local xrest, yrest = 0, 0

-- ---@param opacity? number
-- local function drawNoise(opacity)

--   opacity = opacity or 1

--   noiseT = noiseT + delta_time * 0.1

--   local l, t = mainCamera:getVisible()

--   local w, h = data:getDimensions()
--   local sw, sh = 400 / w, 225 / h

--   local dx, dy = 0, 0
--   if transitions.mode == 'scrolling' then
--     dx, dy = transitions.transform(0, 0)
--   end

--   local prevXrest, prevYrest = xrest, yrest

--   if transitions.just_stopped_scrolling then
--     gx = prevXrest + dx - l
--     gy = prevYrest + dy - t
--   end

--   xrest, yrest = gx + l - dx, gy + t - dy

--   data:mapPixel(
--     function(x, y)
--       x = xrest + x * sw
--       y = yrest + y * sh
--       local val = love.math.noise(x*0.0075, y*0.0075, noiseT)

--       local op = 1 or love.math.noise(x*0.001, y*0.001, noiseT, 10000)
--       -- if we have a different noise for each colour we get interesting rgb effect
--       return val, val, val, opacity * op
--     end
--   )

--   -- v1 Removed Image:getData and Image:refresh, use Image:replacePixels instead
--   noiseImg:refresh()

--   lighting.applyShadow{
--     x = 0,
--     y = 0,
--     type = 'canvas',
--     canvasImg = noiseImg
--   }

--   -- debug
--   -- local l, t = mainCamera:getVisible()
--   -- love.graphics.push("all")
--   -- love.graphics.setBlendMode('lighten', 'premultiplied')
--   -- love.graphics.draw(noiseImg, l, t)
--   -- love.graphics.pop()
-- end

-- -@class Cloud
-- -@field shape {x: number, y: number}[]
-- -@field density number
-- -@field angle number
-- -@field x number
-- -@field y number
-- -@field w number
-- -@field h number

-- -@class CreateCloudOptions
-- -@field side "left" | "right" | "up" | "down"

-- TODOMAYBE: create better algorithm for cloud creation that creates non overlapping clouds efficiently
-- Lots of magic numbers in here... Hope I remember why they're here...
-- -@param number number
-- -@param w number
-- -@param h number
-- -@param options? CreateCloudOptions
-- -@param clouds? Cloud[][]
-- -@return Cloud[]
-- local function createClouds(number, w, h, options, clouds)
--   ---@type Cloud[]
--   local c = {}

--   local x0, y0, dx, dy = 0, 0, 0, 0
--   local xbound, ybound = 100, 35
--   local cloudW, cloudH = 100 + xbound, 100 + ybound

--   if options then
--     if options.side == "left" then
--       x0 = x0 - 100
--       dx = cloudW * 0.5
--     elseif options.side == "right" then
--       x0 = cloudW * 0.5 + 100
--       dx = x0
--     elseif options.side == "up" then
--       y0 = y0 - 100
--       dy = cloudH * 0.5
--     elseif options.side == "down" then
--       y0 = cloudH * 0.5 + 100
--       dy = y0
--     end
--   end

--   -- local minDist = ybound ^ 2
--   local minDist = 100 ^ 2

--   for _ = 1, number do
--     local attempts = 0
--     local overlaps = true

--     ---@type Cloud
--     local cloud = {
--       density = 1,
--       angle = love.math.random() * 2 * math.pi,
--       x = 0,
--       y = 0,
--       shape = {},
--       w = cloudW,
--       h = cloudH
--     }

--     while overlaps and attempts < 10 do
--       cloud.x = x0 - 100 + love.math.random(w - dx + 200)
--       cloud.y = y0 - 100 + love.math.random(h - dy + 200)

--       overlaps = false

--       for _, cl in ipairs(c) do
--         if u.distanceSqared2d(cl.x, cl.y, cloud.x, cloud.y) < minDist then
--           overlaps = true
--           break
--         end
--       end

--       if clouds then
--         for _, cloudsOfLayer in ipairs(clouds) do
--           if overlaps then break end

--           for _, cl in ipairs(cloudsOfLayer) do
--             if u.distanceSqared2d(cl.x, cl.y, cloud.x, cloud.y) < minDist then
--               overlaps = true
--               break
--             end
--           end

--         end
--       end

--       attempts = attempts + 1
--     end

--     for _ = 1, 3 + love.math.random(3) do
--       local x, y = u.randomPointFromEllipse(xbound, ybound)
--       table.insert(cloud.shape, {x=x, y=y})
--     end

--     table.insert(c, cloud)
--   end

--   return c
-- end

-- local function drawCloud(layer, cloud, x, y)
--   local w2, h2 = cloud.w * 0.5, cloud.h * 0.5
--   if not (x + w2 < caml or x - w2 > caml + camw or y + h2 < camt or y - h2 > camt + camh) then
--     -- lighting.applyShadow{
--     --   type = "cloudCurve",
--     --   x = x,
--     --   y = y,
--     --   rgba = {
--     --     r = 1,
--     --     g = 1,
--     --     b = 1,
--     --     a = cloud.density * layer.opacity --* game.transitioning.progress
--     --   },
--     -- }
--     local a = cloud.density * layer.opacity --* game.transitioning.progress
--     lighting.applyShadow{
--       type = "dynamic",
--       x = x,
--       y = y,
--       dynamic_options = {radius = 30},
--       rgba = { r = 1, g = 0.8, b = 0.5, a = a },
--     }
--     lighting.applyShadow{
--       type = "dynamic",
--       x = x,
--       y = y,
--       dynamic_options = {radius = 50},
--       rgba = { r = 1, g = 0.8, b = 0.5, a = a * 0.5 },
--     }
--   end
-- end

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
  instance.cloudsOpacityTarget = {
    l1 = 0,
    l2 = 0,
    l3 = 0,
    l4 = 0
  }
  instance.outgoingClouds = {}
  instance.rainIntensity = 0
  instance.snowIntensity = 0
  instance.weatherIntensityTarget = 0
  instance.raindrops = {}
  instance.outgoingRaindrops = {}
  for _ = 1,300 do
    table.insert(instance.raindrops, {x = 0, y = 0})
    table.insert(instance.outgoingRaindrops, {x = 0, y = 0})
  end

  ---@type WeatherAnims
  instance.weatherAnims = {
    init = true,
    areas = {
      overworld = {
        value = 0,
        duration = 0
      },
      grassland = {
        value = 0,
        duration = 0
      },
      snowy = {
        value = 0,
        duration = 0
      },
      tropical = {
        value = 0,
        duration = 0
      }
    }
  }
end

-- sun is a huge light source veeeery far away, therefore:
-- sun shadows are about as big as the casting object
-- it's so far that it produces sharp shadows for objects that aren't too high
-- the higher from the groud the casting object goes the fuzzier the shadow (more penumbra)
-- objects that are close are lit from the same angle.
-- You need to travel far for the angle to change and it won't be noticable when objects are close to each other.

---@class WeatherMethods
Weather.functions = {
  -- ---@param self WeatherType
  -- ---@return table<string, CloudLayer>
  -- getCloudLayers = function(self)
  --   return self.clouds
  -- end,

  -- ---@param self WeatherType
  -- ---@return table<string, CloudLayer>
  -- getOutgoingCloudLayers = function(self)
  --   return self.outgoingClouds
  -- end,

  -- ---@param self WeatherType
  -- ---@param name string
  -- ---@return CloudLayer | nil
  -- getCloudLayer = function(self, name)
  --   return self.clouds[name]
  -- end,

  -- ---@param self WeatherType
  -- ---@param name string
  -- ---@param cl CloudLayer
  -- setCloudLayer = function(self, name, cl)
  --   self.clouds[name] = cl
  -- end,

  -- ---@param self WeatherType
  -- ---@param options? CreateCloudOptions
  -- createClouds = function(self, options)
  --   if self.weatherAnims.init then
  --     self:updateWeather()
  --     self.weatherAnims.init = false
  --   end
  --   self.clouds = {}
  --   -- self:setCloudLayer('l1', {opacity = self.cloudsOpacityTarget.l1, clouds = createClouds(25, game.room.width, game.room.height, options), heightFactor = 1})
  --   -- self:setCloudLayer('l2', {opacity = self.cloudsOpacityTarget.l2, clouds = createClouds(25, game.room.width, game.room.height, options), heightFactor = 2})
  --   -- self:setCloudLayer('l3', {opacity = self.cloudsOpacityTarget.l3, clouds = createClouds(25, game.room.width, game.room.height, options), heightFactor = 3})
  --   -- self:setCloudLayer('l4', {opacity = self.cloudsOpacityTarget.l4, clouds = createClouds(25, game.room.width, game.room.height, options), heightFactor = 4})
  -- end,

  -- ---@param self WeatherType
  -- getBiomeArea = function(self)
  --   local b = self:getBiome()
  --   if b == 'grassland' then
  --     return self.weatherAnims.areas.grassland
  --   elseif b == 'snowy' then
  --     return self.weatherAnims.areas.snowy
  --   elseif b == 'tropical' then
  --     return self.weatherAnims.areas.tropical
  --   else
  --     return self.weatherAnims.areas.overworld
  --   end
  -- end,

  getBiome = function()
    if not game.isWorldScreen() then return nil end
    -- snowy = 90x93 to 93x95
    -- grassland = 93-94x101 -> 92-94x102 -> 91x103 to 94x106
    -- tropical isle = 102x105 to 104x106
    local x, y = game.getRoomCoords()
    ---@type 'overworld' | 'snowy' | 'grassland' | 'tropical'
    local biome = 'overworld'
    if x and y then
      if x >= 90 and x <= 93 then
        if y >= 93 and y <=95 then
          biome = 'snowy'
        end
      end
      if
        ((x == 93 or x == 94) and y == 101)
        or ((x >= 92 and x <= 94) and y == 102)
        or ((x >= 91 and x <= 94) and (y >= 103 and y <= 106))
      then
        biome = 'grassland'
      end
      if x >= 102 and x <= 104 and y >= 105 and y <= 106 then
        biome = 'tropical'
      end
    end
    ---@type 'overworld' | 'snowy' | 'grassland' | 'tropical'
    return biome
  end,

  ---@param self WeatherType
  updateWeather = function(self)
    if game.isWorldScreen() then

      local biome = self:getBiome()

      self.weatherIntensityTarget = 0
      if biome == 'overworld' then
        local w = self.weatherAnims.areas.overworld
        if w.value < 0.1 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 1
        elseif w.value < 0.15 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.0
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.0
          self.weatherIntensityTarget = 0.5
        elseif w.value < 0.17 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
          self.weatherIntensityTarget = 0.15
        elseif w.value < 0.3 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
        elseif w.value < 0.6 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.0
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.0
        elseif w.value < 0.8 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.0
        else
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
        end
      elseif biome == 'snowy' then
        local w = self.weatherAnims.areas.snowy
        if w.value < 0.3 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 1
        elseif w.value < 0.5 then
          self.cloudsOpacityTarget.l1 = 0.4
          self.cloudsOpacityTarget.l2 = 0.4
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 1
        elseif w.value < 0.7 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 0.75
        elseif w.value < 0.8 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.3
          self.cloudsOpacityTarget.l4 = 0.0
          self.weatherIntensityTarget = 0.5
        elseif w.value < 0.9 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
          self.weatherIntensityTarget = 0.15
        else
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.0
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
        end
      elseif biome == 'grassland' then
        local w = self.weatherAnims.areas.grassland
        if w.value < 0.4 then
          self.cloudsOpacityTarget.l1 = 0.4
          self.cloudsOpacityTarget.l2 = 0.4
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 1
        elseif w.value < 0.8 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 1
        elseif w.value < 0.9 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
          self.weatherIntensityTarget = 0.3
        else
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.4
          self.cloudsOpacityTarget.l4 = 0.4
        end
      elseif biome == 'tropical' then
        local w = self.weatherAnims.areas.tropical
        if w.value < 0.4 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.0
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
        elseif w.value < 0.9 then
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
        else
          self.cloudsOpacityTarget.l1 = 0.3
          self.cloudsOpacityTarget.l2 = 0.3
          self.cloudsOpacityTarget.l3 = 0.0
          self.cloudsOpacityTarget.l4 = 0.0
          self.weatherIntensityTarget = 0.1
        end
      end
    end
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

    if not game.isWorldScreen() then
      self.weatherAnims.init = true
    end

    if game.transitioning then
      if game.transitioning.firstFrame then
        -- Create weather effects
        if game.transitioning.type == "whiteScreen" then
          -- if game.isWorldScreen() then
          --   self:createClouds()
          -- end
        elseif game.transitioning.type == "scrolling" then
          -- self.outgoingClouds = self.clouds

          local side = game.transitioning.side

          -- if game.isWorldScreen() then
          --   self:createClouds({side = side})
          -- end

          -- Check if outgoing clouds are in bounds of the new
          -- screen and if yes add them to new cloud layers

          -- local dx, dy = 0, 0
          -- if side == "left" then
          --   dx = game.room.width
          -- elseif side == "right" then
          --   dx = -game.prevRoom.width
          -- elseif side == "up" then
          --   dy = game.room.height
          -- elseif side == "down" then
          --   dy = -game.prevRoom.height
          -- end

          -- local ls = self:getOutgoingCloudLayers()
          -- for layerName, l in pairs(ls) do
          --   for i, cloud in ipairs(l.clouds) do
          --     local newX, newY = cloud.x + dx, cloud.y + dy
          --     local outOfBounds = newX + cloud.w * 0.5 < 0 or
          --       newY + cloud.h * 0.5 < 0 or
          --       newX - cloud.w * 0.5 > game.room.width or
          --       newY - cloud.h * 0.5 > game.room.height
          --     if not outOfBounds then
          --       if not self.clouds[layerName] then self.clouds[layerName] = {clouds = {}, opacity = l.opacity, heightFactor = l.heightFactor} end
          --       if not self.clouds[layerName].clouds then self.clouds[layerName].clouds = {} end
          --       local newCloud = u.deep_copy(cloud)
          --       newCloud.x, newCloud.y = newX, newY
          --       if not self.clouds[layerName].clouds[i] then
          --         table.insert(self.clouds[layerName].clouds, newCloud)
          --       else
          --         self.clouds[layerName].clouds[i] = newCloud
          --       end
          --     end
          --   end
          -- end

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

    -- Refresh areas weather
    for _,v in pairs(self.weatherAnims.areas) do
      v.duration = v.duration - session.delta_hours
      if v.duration <= 0 then
        v.value = love.math.random()
        v.duration = 1 + love.math.random() * 24
      end
    end

    self:updateWeather()

    -- -- Gradually move to new cloud opacity
    -- for l, c in pairs(self.clouds) do
    --   local target = self.cloudsOpacityTarget[l]
    --   if type(target) == 'number' then
    --     if c.opacity > target then
    --       c.opacity = c.opacity - session.delta_hours
    --       if c.opacity < target then
    --         c.opacity = target
    --       end
    --     elseif c.opacity < target then
    --       c.opacity = c.opacity + session.delta_hours
    --       if c.opacity > target then
    --         c.opacity = target
    --       end
    --     end
    --   end
    -- end

    -- Gradually move to rain/snow intensity
    local biome = self:getBiome()
    local rit = biome == 'snowy' and 0 or self.weatherIntensityTarget
    local sit = biome ~= 'snowy' and 0 or self.weatherIntensityTarget
    if self.rainIntensity > rit then
      self.rainIntensity = self.rainIntensity - session.delta_hours
      if self.rainIntensity < rit then
        self.rainIntensity = rit
      end
    elseif self.rainIntensity < rit then
      self.rainIntensity = self.rainIntensity + session.delta_hours
      if self.rainIntensity > rit then
        self.rainIntensity = rit
      end
    end
    if self.snowIntensity > sit then
      self.snowIntensity = self.snowIntensity - session.delta_hours
      if self.snowIntensity < sit then
        self.snowIntensity = sit
      end
    elseif self.snowIntensity < sit then
      self.snowIntensity = self.snowIntensity + session.delta_hours
      if self.snowIntensity > sit then
        self.snowIntensity = sit
      end
    end

    local vx = self:getWindVelocity()

    -- -- Clouds
    -- for _, l in pairs(self:getCloudLayers()) do
    --   for _, cloud in ipairs(l.clouds) do
    --     -- Move clouds
    --     cloud.x = cloud.x + vx * dt / l.heightFactor
    --     cloud.y = cloud.y + vy * dt / l.heightFactor

    --     -- Loop out of bounds clouds
    --     if cloud.x + cloud.w * 0.5 < 0 then
    --       cloud.x = game.room.width + cloud.w * 0.5
    --     end
    --     if cloud.y + cloud.h * 0.5 < 0 then
    --       cloud.y = game.room.height + cloud.h * 0.5
    --     end
    --     if cloud.x - cloud.w * 0.5 > game.room.width then
    --       cloud.x = -cloud.w * 0.5
    --     end
    --     if cloud.y - cloud.h * 0.5 > game.room.height then
    --       cloud.y = -cloud.h * 0.5
    --     end
    --   end
    -- end

    --Rain

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
          if math.random() < self.rainIntensity then
            rainSplash()
            if math.random() < 0.15 * self.rainIntensity then rainSplash() end
          end
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

    -- drawNoise()

    -- local ls = self:getCloudLayers()
    -- for _, l in pairs(ls) do
    --   for _, cloud in ipairs(l.clouds) do
    --     for _, part in ipairs(cloud.shape) do
    --       drawCloud(l, cloud, cloud.x + part.x, cloud.y + part.y)
    --     end
    --   end
    -- end

    local vx = self:getWindVelocity()

    prevCaml = caml
    prevCamt = camt
    prevCamw = camw
    prevCamh = camh

    -- Rain
    love.graphics.push("all")
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
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.line(drop.x, drop.y, drop.x - dropWidth, drop.y - raindropHeight)
      end
    end
    love.graphics.pop()
  end,

  ---@param self WeatherType
  trans_draw = function(self)

    -- if (game.wasWorldScreen() and game.isWorldScreen()) then
    --   drawNoise(nil)
    -- elseif (game.wasWorldScreen() and not game.isWorldScreen()) then
    --   drawNoise(1 - game.transitioning.progress)
    -- elseif (not game.wasWorldScreen() and game.isWorldScreen()) then
    --   drawNoise(game.transitioning.progress)
    -- end

    if game.wasWorldScreen() then
      -- local ls = self:getOutgoingCloudLayers()
      -- for _, l in pairs(ls) do
      --   for _, cloud in ipairs(l.clouds) do
      --     for _, part in ipairs(cloud.shape) do
      --       local x, y = cloud.x + part.x, cloud.y + part.y
      --       x, y = transitions.transform(x, y)
      --       drawCloud(l, cloud, x, y)
      --     end
      --   end
      -- end

      -- Rain
      for _, drop in ipairs(self.outgoingRaindrops) do
        if drop.active then

          local vx = self:getWindVelocity()

          local dropWidth = vx * 10 / raindropYSpeed

          -- Draw
          local resetCol = u.storeColour()
          love.graphics.setColor(1, 1, 1, 0.5)
          local x, y = transitions.transform(drop.x, drop.y)
          love.graphics.line(x, y, x - dropWidth, y - raindropHeight)
          resetCol()
        end
      end
    end

    if not game.isWorldScreen() then return end

    -- local ls = self:getCloudLayers()
    -- for _, l in pairs(ls) do
    --   for _, cloud in ipairs(l.clouds) do
    --     for _, part in ipairs(cloud.shape) do
    --       local x, y = cloud.x + part.x, cloud.y + part.y
    --       x, y = transitions.transform(x, y, true)
    --       drawCloud(l, cloud, x, y)
    --     end
    --   end
    -- end

    -- Rain
    for _, drop in ipairs(self.raindrops) do
      if drop.active then

        local vx = self:getWindVelocity()

        local dropWidth = vx * 10 / raindropYSpeed

        -- Draw
        local resetCol = u.storeColour()
        love.graphics.setColor(1, 1, 1, 0.5)
        local x, y = transitions.transform(drop.x, drop.y, true)
        love.graphics.line(x, y, x - dropWidth, y - raindropHeight)
        resetCol()
      end
    end
  end
}

---@class WeatherType : WeatherMethods
-- -@field clouds table<string, CloudLayer>
---@field cloudsOpacityTarget CloudsOpacityTarget
-- -@field outgoingClouds table<string, CloudLayer> | nil
---@field windDir number | nil
---@field windSpeed number | nil
---@field rTimer number | nil
---@field raindrops table<number, Raindrop>
---@field outgoingRaindrops table<number, Raindrop>
---@field rainIntensity number
---@field snowIntensity number
---@field weatherIntensityTarget number
---@field weatherAnims WeatherAnims

---@class CloudsOpacityTarget
---@field l1 number between 0 - 1
---@field l2 number between 0 - 1
---@field l3 number between 0 - 1
---@field l4 number between 0 - 1

---@class Area
---@field value number random between 0 - 1, determines weather
---@field duration number number of in game hours current weather lasts

---@class Areas
---@field overworld Area
---@field grassland Area
---@field snowy Area
---@field tropical Area

---@class WeatherAnims
---@field areas Areas
---@field init? boolean if true area values will be initialized by current clouds opacity

-- -@class CloudLayer
-- -@field clouds Cloud[]
-- -@field opacity number
-- -@field heightFactor number

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
