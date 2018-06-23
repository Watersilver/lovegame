local ps = require "physics_settings"

local lp = love.physics

local bt = {}

bt.functions = {
  update = function(self)
  end
  ,
  draw = function(self)
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
  end
  ,
  load = function(self)
    -- set up physical properties
    self.body = lp.newBody(ps.pw, self.xstart, self.ystart, "dynamic")
    self.body:setUserData(self)
    self.shape = ps.shapes.rect1x1
    self.fixtures = {
      lp.newFixture(self.body, self.shape),
    }
  end
}

bt.fields = {
}

function bt:new(init)
  local instance = {}
  for funcname, func in pairs(self.functions) do
    instance[funcname] = func
  end
  for fieldname, field in pairs(self.fields) do
    instance[fieldname] = field
  end
  if init then
    for name, value in pairs(init) do
      instance[name] = value
    end
  end
  return instance
end

return bt
