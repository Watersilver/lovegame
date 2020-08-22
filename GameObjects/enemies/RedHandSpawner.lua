local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local redHand = require "GameObjects.enemies.redHand"

local RHS = {}

function RHS.initialize(instance)
  instance.avgRedHandTime = 3 --sec
  instance.redHands = 1 -- If they die, destroy self.
  instance.layer = 25
end

RHS.functions = {
  resetTimer = function (self, extraTime)
    extraTime = extraTime or 0
    -- +- 20%
    local variance = extraTime + 0.4 * love.math.random() - 0.2
    self.timer = self.avgRedHandTime * (variance + 1)
  end,

  load = function (self)
    self:resetTimer()
    self.landTiles = {}
  end,

  update = function (self, dt)

    if self.redHands < 1 then o.removeFromWorld(self) end
    if self.pause then return end
    self.timer = self.timer - dt
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.timer < 0 then

      if self.target then
        -- Create red hand
        local rh = redHand:new{
          xstart = self.target.x,
          ystart = self.target.y,
          x = self.target.x,
          y = self.target.y,
          layer = self.layer,
          creator = self,
          destination = self.destination, -- Rooms/w100x100.lua for testing
          desx = self.desx, desy = self.desy, -- 257 for testing
          giveChase = self.giveChase
        };
        o.addToWorld(rh)
      end
      self.pause = true
      self:resetTimer()

    end
  end,
}

function RHS:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(RHS, instance, init) -- add own functions and fields
  return instance
end

return RHS
