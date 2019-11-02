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

function drops.cheapest(x, y)
  local rpoh = (session.save.randomPiecesOfHeart or 0)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.02},
    {value = Rupee, chance = 0.02},
    {value = Fairy, chance = 0.002},
    {value = pieceOfHeart, chance = rpoh < 1 and 0.00001 or 0},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.cheap(x, y)
  local rpoh = (session.save.randomPiecesOfHeart or 0)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.03},
    {value = Rupee, chance = 0.05},
    {value = Rupee5, chance = 0.02},
    {value = Rupee20, chance = 0.004},
    {value = Fairy, chance = 0.002},
    {value = Rupee100, chance = 0.0005},
    {value = Rupee200, chance = 0.0002},
    {value = pieceOfHeart, chance = rpoh < 2 and 0.00003 or 0},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.normal(x, y)
  local rpoh = (session.save.randomPiecesOfHeart or 0)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.06},
    {value = Rupee, chance = 0.12},
    {value = Rupee5, chance = 0.08},
    {value = Rupee20, chance = 0.01},
    {value = Fairy, chance = 0.002},
    {value = Rupee100, chance = 0.0005},
    {value = Rupee200, chance = 0.0002},
    {value = pieceOfHeart, chance = rpoh < 4 and 0.00005 or 0},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

function drops.rich(x, y)
  local rpoh = (session.save.randomPiecesOfHeart or 0)
  local Drop = chooseFromChanceTable{
    {value = Heart, chance = 0.06},
    {value = Rupee, chance = 0.05},
    {value = Rupee5, chance = 0.15},
    {value = Rupee20, chance = 0.10},
    {value = Fairy, chance = 0.003},
    {value = Rupee100, chance = 0.0006},
    {value = Rupee200, chance = 0.0003},
    {value = pieceOfHeart, chance = rpoh < 4 and 0.0005 or 0},
  }
  if Drop then
    o.addToWorld(Drop:new{xstart = x, ystart = y, zvel = 100})
  end
end

return drops
