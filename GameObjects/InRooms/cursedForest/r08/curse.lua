local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"

local Curse = {}

function Curse.initialize(instance)
  instance.rightWay = love.math.random() > 0.5 and 1 or 2
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
    if self.transRan then return end
    self.transRan = true
    self.TransRanAtLeastOnce = true

    local bKnights = o.identified.boolKnight
    if bKnights then
      if love.math.random() > 0.5 then
        bKnights[1].liar = true
      else
        bKnights[2].liar = true
      end
      bKnights[1].rightWay = self.rightWay
      bKnights[2].rightWay = self.rightWay
    end

    local rightRoom = "Rooms/w096x102.lua"
    local wrongRoom = "Rooms/cursedForest/Trap.lua"

    game.room.upTrans = {
      {
        roomTarget = self.rightWay == 1 and rightRoom or wrongRoom,
        xleftmost = 0, xrightmost = 264,
        xmod = 0, ymod = 0
      },
      {
        roomTarget = self.rightWay == 2 and rightRoom or wrongRoom,
        xleftmost = 265, xrightmost = 520,
        xmod = 0, ymod = 0
      }
    }
    o.removeFromWorld(self)
  end
}

function Curse:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Curse, instance, init) -- add own functions and fields
  return instance
end

return Curse
