local o = require "GameObjects.objects"
local Heart = require "Gameobjects.drops.heart"
local Rupee = require "Gameobjects.drops.rupee"
local Rupee5 = require "Gameobjects.drops.rupee5"

local drops = {}

function drops.cheapest(x, y)
  local dropNumber = love.math.random()

  if dropNumber < 0.02 then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < 0.03 + 0.02 then
    local drop = Rupee:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.cheap(x, y)
  local dropNumber = love.math.random()

  if dropNumber < 0.02 then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.normal(x, y)
  local dropNumber = love.math.random()

  if dropNumber < 0.02 then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.rich(x, y)
  local dropNumber = love.math.random()

  if dropNumber < 0.02 then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

return drops
