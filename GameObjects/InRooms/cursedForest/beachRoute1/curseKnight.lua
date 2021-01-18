local u = require "utilities"
local game = require "game"
local ds = require "GameObjects.delayedSound"
local o = require "GameObjects.objects"

local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local parent = require "GameObjects.enemies.knight"

local Knight = {}

function Knight.initialize(instance)
end

Knight.functions = {
  die = function (self)
    if parent.functions.die then parent.functions.die(self)
    else et.functions.die(self) end
    game.room.downTrans = {
      {
        roomTarget = "Rooms/cursedForest/beachRoute2.lua",
        xleftmost = 0, xrightmost = 520,
        xmod = 0, ymod = 0
      }
    }
    local wayOpenFanfare = ds:new{delay = 0.4}
    o.addToWorld(wayOpenFanfare)
  end,
}

function Knight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(parent, instance) -- add parent functions and fields
  p.new(Knight, instance, init) -- add own functions and fields
  return instance
end

return Knight
