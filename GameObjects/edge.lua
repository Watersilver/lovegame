local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"
local trans = require "transitions"
local game = require "game"

-- WARNING: NEVER make adjacent edges!!!
local Edge = {}

function Edge.initialize(instance)
  instance.image_speed = 0
  instance.image_index = 0
  instance.playerContacts = 0
  instance.physical_properties = {
    bodyType = "static",
  }
  instance.edge = true
  instance.ballbreaker = true
end

Edge.functions = {

beginContact = function(self, a, b, coll, aob, bob)
  local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

  if other.player and not otherF:isSensor() and self.side ~= "down" then

    -- Will be used to check if player goes over edge
    self.playerContactX = other.body:getPosition()

    -- Keep track of how many player fixtures touch me
    self.playerContacts = self.playerContacts + 1
  end
end,

endContact = function(self, a, b, coll, aob, bob)
  if self.side == "down" then return end
  local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

  if other.player and not otherF:isSensor() then

    if self:wentOverEdge(other) then
      if not other.edgeFall then
        other.edgeFall = {height = self.height, side = self.side}
      end
    end

    -- Keep track of how many player fixtures touch me
    self.playerContacts = self.playerContacts - 1
    if self.playerContacts == 0 then
      -- if this was last fixture ending contact, delete variables
      self.playerContactX = nil
    end
  end
end,

preSolve = function(self, a, b, coll, aob, bob)
  local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

  if other.player then
    coll:setEnabled(self:belowEdge(other))
  end
  if self.side == "down" then

    if other.player and not otherF:isSensor() then
      if self:wentOverEdge(other) then
        if not other.edgeFall then
          other.edgeFall = {height = self.height, side = self.side}
        end
      end
    end

  end
end,

draw = function (self)
  local sprite = self.sprite
  if sprite then
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, self.xstart, self.ystart, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end
  -- if self.body then
  --   local shape = self.fixture:getShape()
  --   love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  -- end
end,

trans_draw = function (self)
  local sprite = self.sprite
  if sprite then
    local xtotal, ytotal = trans.still_objects_coords(self)
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end
  -- if self.body then
  --   local shape = self.fixture:getShape()
  --   love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  -- end
end,

load = function (self)
  self.image_speed = 0
  if not self.height then
    love.errhand("No height set: Edge at " .. self.x .. "/" .. self.y)
    self.height = 0
  end
  if self.side == "left" then
    self.fixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.l)
    self.belowEdge = ec.belowLeftEdge
    self.wentOverEdge = ec.wentOverLeftEdge
    self.fixture:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)
  elseif self.side == "right" then
    self.fixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.r)
    self.belowEdge = ec.belowRightEdge
    self.wentOverEdge = ec.wentOverRightEdge
    self.fixture:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)
  else
    self.fixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.d2)
    -- self.fixture = love.physics.newFixture(self.body, ps.shapes.edgeDown)
    self.belowEdge = ec.belowDownEdge
    self.wentOverEdge = ec.wentOverDownEdge
    self.fixture:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)--, PLAYERATTACKCAT)
    self.height = self.height + ps.shapes.plshapeHeight - 8
  end
end
}

function Edge:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Edge, instance, init) -- add own functions and fields
  return instance
end

return Edge
