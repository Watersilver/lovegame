local o = require "GameObjects.objects"
local chooseFromChanceTable = (require "utilities").chooseFromChanceTable
local Heart = require "GameObjects.drops.heart"
local Rupee = require "GameObjects.drops.rupee"
local Rupee5 = require "GameObjects.drops.rupee5"
local Rupee20 = require "GameObjects.drops.rupee20"
local Rupee100 = require "GameObjects.drops.rupee100"
local Rupee200 = require "GameObjects.drops.rupee200"
local pieceOfHeart = require "GameObjects.drops.pieceOfHeart"
local Fairy = require "GameObjects.drops.fairy"

local drops = {}

function drops.custom(x, y, droptable)
  local dropname = chooseFromChanceTable(droptable)
  if dropname then
    local Drop =  require ("GameObjects.drops." .. dropname)
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.cheapest(x, y)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.02},
    {value = Rupee, chance = 0.02},
    {value = Fairy, chance = 0.001},
    {value = pieceOfHeart, chance = session.getPohChance("cheapest")},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.cheap(x, y)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.03},
    {value = Rupee, chance = 0.05},
    {value = Rupee5, chance = 0.02},
    {value = Rupee20, chance = 0.004},
    {value = Fairy, chance = 0.001},
    {value = Rupee100, chance = 0.0005},
    {value = Rupee200, chance = 0.0002},
    {value = pieceOfHeart, chance = session.getPohChance("cheap")},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.normal(x, y)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.06},
    {value = Rupee, chance = 0.12},
    {value = Rupee5, chance = 0.08},
    {value = Rupee20, chance = 0.01},
    {value = Fairy, chance = 0.001},
    {value = Rupee100, chance = 0.0005},
    {value = Rupee200, chance = 0.0002},
    {value = pieceOfHeart, chance = session.getPohChance("normal")},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.rich(x, y)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.06},
    {value = Rupee, chance = 0.05},
    {value = Rupee5, chance = 0.15},
    {value = Rupee20, chance = 0.10},
    {value = Fairy, chance = 0.002},
    {value = Rupee100, chance = 0.0006},
    {value = Rupee200, chance = 0.0003},
    {value = pieceOfHeart, chance = session.getPohChance("rich")},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

return drops
