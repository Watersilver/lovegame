local chooseFromChanceTable = (require "utilities").chooseFromChanceTable
local collectables = require "collectables"

local Drop = require "GameObjects.drops.nothing"

local drops = {}

function drops.custom(x, y, droptable)
  local dropname = type(droptable) == "string" and droptable or chooseFromChanceTable(droptable)
  if dropname then
    if collectables.data[dropname] then
      (require "GameObjects.drops.nothing").fromData(collectables.data[dropname], x, y)
    end
  end
end

function drops.cheapest(x, y)
  ---@type CollectableData | nil
  local d = chooseFromChanceTable{
    {value = collectables.data.heart, chance = 0.02},
    {value = collectables.data.rupee, chance = 0.02},
    {value = collectables.data.fairy, chance = 0.001},
    {value = collectables.data.piece_of_heart, chance = session.getPohChance("cheapest")},
  }
  if d then
    Drop.fromData(d,x,y)
  end
end

function drops.cheap(x, y)
  ---@type CollectableData | nil
  local d = chooseFromChanceTable{
    {value = collectables.data.heart, chance = 0.03},
    {value = collectables.data.rupee, chance = 0.05},
    {value = collectables.data.rupee5, chance = 0.02},
    {value = collectables.data.rupee20, chance = 0.004},
    {value = collectables.data.fairy, chance = 0.001},
    {value = collectables.data.rupee100, chance = 0.0005},
    {value = collectables.data.rupee200, chance = 0.0002},
    {value = collectables.data.piece_of_heart, chance = session.getPohChance("cheap")},
  }
  if d then
    Drop.fromData(d,x,y)
  end
end

function drops.normal(x, y)
  ---@type CollectableData | nil
  local d = chooseFromChanceTable{
    {value = collectables.data.heart, chance = 0.06},
    {value = collectables.data.rupee, chance = 0.12},
    {value = collectables.data.rupee5, chance = 0.08},
    {value = collectables.data.rupee20, chance = 0.01},
    {value = collectables.data.fairy, chance = 0.001},
    {value = collectables.data.rupee100, chance = 0.0005},
    {value = collectables.data.rupee200, chance = 0.0002},
    {value = collectables.data.piece_of_heart, chance = session.getPohChance("normal")},
  }
  if d then
    Drop.fromData(d,x,y)
  end
end

function drops.rich(x, y)
  ---@type CollectableData | nil
  local d = chooseFromChanceTable{
    {value = collectables.data.heart, chance = 0.06},
    {value = collectables.data.rupee, chance = 0.05},
    {value = collectables.data.rupee5, chance = 0.15},
    {value = collectables.data.rupee20, chance = 0.10},
    {value = collectables.data.fairy, chance = 0.002},
    {value = collectables.data.rupee100, chance = 0.0006},
    {value = collectables.data.rupee200, chance = 0.0003},
    {value = collectables.data.piece_of_heart, chance = session.getPohChance("rich")},
  }
  if d then
    Drop.fromData(d,x,y)
  end
end

return drops
