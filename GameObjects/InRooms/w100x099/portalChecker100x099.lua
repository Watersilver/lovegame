local game = require "game"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"

local PC = {}

function PC.initialize(instance)
  instance.roomTarget = "Rooms/w100x098b.lua"
  instance.xmod = -112
  instance.ymod = 0
end

PC.functions = {
load = function (self)
  if pl1 and pl1.x and pl1.y then
    self.plxprev = pl1.x
    self.plyprev = pl1.y
  end
  self.side = "top"
  self.turnDirection = nil
  self.timer = 0
  self.timerLim = 1.2
  self.timesCircled = 0
end,

update = function (self, dt)
  self.timer = self.timer + dt
  if pl1 and pl1.x and pl1.y and not self.portalOpen then
    if self.plxprev and self.plyprev then
      if not self.turnDirection then
        if pl1.y < self.y and self.plxprev > self.x and pl1.x < self.x then
          self.turnDirection = "ccw"
          self.side = "left"
          self.timer = 0
        elseif pl1.y < self.y and self.plxprev < self.x and pl1.x > self.x then
          self.turnDirection = "cw"
          self.side = "right"
          self.timer = 0
        end
      else
        if self.side == "top" then
          if self.turnDirection == "cw" and
          pl1.y < self.y and
          self.plxprev < self.x and pl1.x > self.x
          then
            self.side = "right"
            self.timer = 0
            self.timesCircled = self.timesCircled + 1
          elseif self.turnDirection == "ccw" and
          pl1.y < self.y and
          self.plxprev > self.x and pl1.x < self.x
          then
            self.side = "left"
            self.timer = 0
            self.timesCircled = self.timesCircled + 1
          end
        elseif self.side == "right" then
          if self.turnDirection == "cw" and
          pl1.x > self.x and
          self.plyprev < self.y and pl1.y > self.y
          then
            self.side = "bottom"
            self.timer = 0
          elseif self.turnDirection == "ccw" and
          pl1.x > self.x and
          self.plyprev > self.y and pl1.y < self.y
          then
            self.side = "top"
            self.timer = 0
          end
        elseif self.side == "bottom" then
          if self.turnDirection == "cw" and
          pl1.y > self.y and
          self.plxprev > self.x and pl1.x < self.x
          then
            self.side = "left"
            self.timer = 0
          elseif self.turnDirection == "ccw" and
          pl1.y > self.y and
          self.plxprev < self.x and pl1.x > self.x
          then
            self.side = "right"
            self.timer = 0
          end
        elseif self.side == "left" then
          if self.turnDirection == "cw" and
          pl1.x < self.x and
          self.plyprev > self.y and pl1.y < self.y
          then
            self.side = "top"
            self.timer = 0
          elseif self.turnDirection == "ccw" and
          pl1.x < self.x and
          self.plyprev < self.y and pl1.y > self.y
          then
            self.side = "bottom"
            self.timer = 0
          end
        end
      end
    end

    if self.timer > self.timerLim then
      self.side = "top"
      self.turnDirection = nil
      self.timesCircled = 0
    end

    self.plxprev = pl1.x
    self.plyprev = pl1.y

    if self.timesCircled > 2 then
      self.portalOpen = true
      local transToChange = game.room.upTrans[2]
      transToChange.roomTarget = self.roomTarget
      transToChange.xmod = self.xmod
      transToChange.ymod = self.ymod
      o.removeFromWorld(self)
    end
  end
end
}

function PC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(PC, instance, init) -- add own functions and fields
  return instance
end

return PC
