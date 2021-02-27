local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"

local Curse = {}

function Curse.initialize(instance)
end

Curse.functions = {

  update = function (self, dt)
    if not self.TransRanAtLeastOnce then self:trans_draw() end
    self.transRan = false
  end,

  draw = function (self)
    -- transdraw doesn't run if draw doesnt exist, so add this here
  end,

  -- not for drawing in this case but it's the
  -- only one that only runs durin transition
  trans_draw = function (self)
    self.TransRanAtLeastOnce = true
    if self.transRan then return end
    self.transRan = true

    if not pl1 or not pl1.exists then return end

    local rightRoom = "Rooms/cursedForest/Crossroads.lua"
    local trapRoom = "Rooms/cursedForest/Trap.lua"

    local wentTo = pl1.lastTransSide
    local emergedFrom
    if wentTo == "left" then
      if o.identified.ForestCurse and o.identified.ForestCurse[1].exists then
        rightRoom = o.identified.ForestCurse[1].getFirstRoom()
      end
      emergedFrom = "right"
    elseif wentTo == "right" then
      emergedFrom = "left"
      rightRoom = "Rooms/cursedForest/shrineRoute1.lua"
    elseif wentTo == "up" then
      emergedFrom = "down"
      rightRoom = "Rooms/cursedForest/beachRoute1.lua"
    elseif wentTo == "down" then
      emergedFrom = "up"
      rightRoom = "Rooms/cursedForest/Chess.lua"
    end

    local trapExitIndex
    local rightExitIndex
    if wentTo == "left" or wentTo == "right" then
      local y = pl1.y
      if y > 79 and y < 137 then
        trapExitIndex = 1
        rightExitIndex = 3
      elseif y > 223 and y < 281 then
        trapExitIndex = 2
        rightExitIndex = 2
      elseif y > 367 and y < 425 then
        trapExitIndex = 3
        rightExitIndex = 1
      end
    else
      local x = pl1.x
      if x > 131 and x < 203 then
        trapExitIndex = 1
        rightExitIndex = 2
      elseif x > 307 and x < 380 then
        trapExitIndex = 2
        rightExitIndex = 1
      end
    end

    if not trapExitIndex or not rightExitIndex or not emergedFrom then return end

    game.room[emergedFrom.."Trans"][trapExitIndex].roomTarget = trapRoom
    game.room[wentTo.."Trans"][rightExitIndex].roomTarget = rightRoom

    o.removeFromWorld(self)
  end
}

function Curse:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Curse, instance, init) -- add own functions and fields
  return instance
end

return Curse
