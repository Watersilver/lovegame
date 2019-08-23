local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local dc = require "GameObjects.Helpers.determine_colliders"
local trans = require "transitions"
local snd = require "sound"

local DungeonEdge = {}

-- All this chaos here exists because I'm a fucking asshole
-- Timer will delay jump a little and make sure all touched objects are taken into account
-- They must be taken into account to avoid jumping while also touching a wall and falling into it

local speed = 50

local plVelocity = {
  down = {0, speed},
  up = {0, -speed},
  left = {-speed, 0},
  right = {speed, 0},
}

function DungeonEdge.initialize(instance)
  instance.image_speed = 0
  instance.image_index = 0
  instance.playerContacts = 0
  instance.physical_properties = {
    bodyType = "static",
  }
  instance.ballbreaker = true
  instance.side = "down"
  instance.dungeonEdge = true
  instance.touchTimer = 0
  instance.touchDuration = 4
end

DungeonEdge.functions = {
  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if not otherF:isSensor() and myF == self.topFixture and other.player then
      self.touchTimer = 0
    end

  end,

  preSolve = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if not otherF:isSensor() and myF == self.topFixture and other.player and not other.dungeonJumping and other.input[self.side] == 1 and other.zo == 0 then
      local skipJump
      for _, touchedOb in ipairs(other.sensors[self.side .. "TouchedObs"]) do
        if not touchedOb.dungeonEdge then skipJump = true end
      end
      if not skipJump then
        self.touchTimer = self.touchTimer + 1
        if self.touchTimer >= self.touchDuration then
          snd.play(other.sounds.jump)
          coll:setEnabled(false)
          other.zvel = 90
          other.dungeonJumping = plVelocity[self.side]
        end
      else
        self.touchTimer = 0
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
    if self.side == "left" then
      self.topFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.r)
      self.topFixture:setMask(SPRITECAT)
      local otherFixture
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.u)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.d)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.l)
      otherFixture:setMask(SPRITECAT)
    elseif self.side == "right" then
      self.topFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.l)
      self.topFixture:setMask(SPRITECAT)
      local otherFixture
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.u)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.d)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.r)
      otherFixture:setMask(SPRITECAT)
    elseif self.side == "up" then
      self.topFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.d)
      self.topFixture:setMask(SPRITECAT)--, PLAYERATTACKCAT)
      local otherFixture
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.u)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.l)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.r)
      otherFixture:setMask(SPRITECAT)
    else
      self.topFixture = love.physics.newFixture(self.body, ps.shapes.edgeRectHalfxHalf.u)
      self.topFixture:setMask(SPRITECAT)
      local otherFixture
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.d)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.l)
      otherFixture:setMask(SPRITECAT)
      otherFixture = love.physics.newFixture(self.body, ps.shapes.edgeRect1x1.r)
      otherFixture:setMask(SPRITECAT)
    end
  end
}

function DungeonEdge:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DungeonEdge, instance, init) -- add own functions and fields
  return instance
end

return DungeonEdge
