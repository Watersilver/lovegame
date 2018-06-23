local ps = require "physics_settings"

local lp = love.physics

local p = {}

p.functions = {
  build_body = function(self)
    local pp = self.physical_properties
    if not pp then return end

    --Check if tile
    if pp.tile then
      ps.shapes.edgeToTiles(self, pp.edgetable)
    -- If not tile build normally
    else
      if not self.body then self.body = lp.newBody(ps.pw, self.xstart or 0, self.ystart or 0) end
      local body = self.body
      if pp.bodyType then body:setType(pp.bodyType) end
      if pp.fixedRotation then body:setFixedRotation(pp.fixedRotation) end
      if pp.mass then body:setMass(pp.mass) end
      body:setUserData(self)
      if pp.shape then
        self.shape = pp.shape
        if self.fixture then self.fixture:destroy() end
        self.fixture = love.physics.newFixture(self.body, self.shape)
      end
      if pp.restitution then self.fixture:setRestitution(pp.restitution) end
    end
    self.physical_properties = nil
  end
}

function p.initialize(instance)
end

function p:new(instance, init)
  if not instance then instance = {} end
  if self.initialize then self.initialize(instance) end
  for funcname, func in pairs(self.functions) do
    instance[funcname] = func
  end
  if init then
    for key, value in pairs(init) do
      instance[key] = value
    end
  end
  return instance
end

return p
