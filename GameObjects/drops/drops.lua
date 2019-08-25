local o = require "GameObjects.objects"
local Heart = require "Gameobjects.drops.heart"
local Rupee = require "Gameobjects.drops.rupee"
local Rupee5 = require "Gameobjects.drops.rupee5"
local Rupee20 = require "Gameobjects.drops.rupee20"
local Fairy = require "Gameobjects.drops.fairy"

local drops = {}

function drops.cheapest(x, y)
  local dropNumber = love.math.random()

  local heartChance = 0.02
  local rupeeChance = 0.02
  local fairyChance = 0.002

  if dropNumber < heartChance then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupeeChance + heartChance then
    local drop = Rupee:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < fairyChance + rupeeChance + heartChance then
    local drop = Fairy:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.cheap(x, y)
  local dropNumber = love.math.random()

  local heartChance = 0.03
  local rupeeChance = 0.05
  local rupee5Chance = 0.02
  local rupee20Chance = 0.0025
  local fairyChance = 0.003

  if dropNumber < heartChance then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupeeChance + heartChance then
    local drop = Rupee:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee5Chance + heartChance + rupeeChance then
    local drop = Rupee5:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Rupee20:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < fairyChance + rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Fairy:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.normal(x, y)
  local dropNumber = love.math.random()

  local heartChance = 0.06
  local rupeeChance = 0.12
  local rupee5Chance = 0.08
  local rupee20Chance = 0.01
  local fairyChance = 0.005

  if dropNumber < heartChance then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupeeChance + heartChance then
    local drop = Rupee:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee5Chance + heartChance + rupeeChance then
    local drop = Rupee5:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Rupee20:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < fairyChance + rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Fairy:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

function drops.rich(x, y)
  local dropNumber = love.math.random()

  local heartChance = 0.06
  local rupeeChance = 0.03
  local rupee5Chance = 0.10
  local rupee20Chance = 0.05
  local fairyChance = 0.005

  if dropNumber < heartChance then
    local drop = Heart:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupeeChance + heartChance then
    local drop = Rupee:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee5Chance + heartChance + rupeeChance then
    local drop = Rupee5:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Rupee20:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  elseif dropNumber < fairyChance + rupee20Chance + heartChance + rupeeChance + rupee5Chance then
    local drop = Fairy:new{xstart = x, ystart = y, zvel = 100}
    o.addToWorld(drop)
  end
end

return drops
