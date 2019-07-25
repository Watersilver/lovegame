local ps = require "physics_settings"
local p = require "GameObjects.prototype"

local lp = love.physics

local bt = {}

function bt.initialize(instance)
  instance.mycolour = 255
  instance.contacts = 0
  instance.physical_properties = {
    bodyType = "dynamic",
    density = 40,
    gravityScaleFactor = 0,
    shape = ps.shapes.rect1x1,
    restitution = 0,
    linearDamping = 40,
    fixedRotation = true,
  }
  instance.layer = 15
  -- instance.liftable = true
end

bt.functions = {
  update = function(self)
    self.mycolour = self.contacts>0 and 0 or COLORCONST
    -- self.mycolour = self.mycolour>254 and 255 or self.mycolour+1
  end
  ,
  draw = function(self)
    love.graphics.setColor(COLORCONST, self.mycolour, self.mycolour, COLORCONST)
    love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  end
  ,
  load = function(self)
    -- set up physical properties
  end,

  beginContact = function(self, a, b, coll)
    self.contacts = self.contacts + 1
  end,

  endContact = function(self, a, b, coll)
    self.contacts = self.contacts - 1
  end,

  preSolve = function(self, a, b, coll)
    -- if coll:isTouching() then self.mycolour = 0 end
  end,
}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
