local o = require "GameObjects.objects"
local Heart = require "Gameobjects.drops.heart"
local Rupee = require "Gameobjects.drops.rupee"

local drops = {}

function drops.cheapest(x, y)
  local drop = Rupee:new{
    xstart = x,
    ystart = y,
    zvel = 100
  }
  o.addToWorld(drop)
end

function drops.cheap(x, y)
  local drop = Rupee:new{
    xstart = x,
    ystart = y,
    zvel = 100
  }
  o.addToWorld(drop)
end

function drops.normal(x, y)
  local drop = Rupee:new{
    xstart = x,
    ystart = y,
    zvel = 100
  }
  o.addToWorld(drop)
end

function drops.rich(x, y)
  local drop = Rupee:new{
    xstart = x,
    ystart = y,
    zvel = 100
  }
  o.addToWorld(drop)
end

return drops
