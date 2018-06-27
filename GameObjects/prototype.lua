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
      if pp.gravityScaleFactor then body:setGravityScale(pp.gravityScaleFactor) end
      if pp.fixedRotation then body:setFixedRotation(pp.fixedRotation) end
      if pp.linearDamping then body:setLinearDamping(pp.linearDamping) end
      body:setUserData(self)
      if pp.shape then
        self.shape = pp.shape

        -- Fixture info
        local fi = nil

        -- If fixture exists, save its info and destroy it
        if self.fixture then
          fi = ps.getFixtureInfo(self.fixture)
          self.fixture:destroy()
        end

        -- Make new fixture to attach new shape to body
        self.fixture = love.physics.newFixture(self.body, self.shape)

        -- Make sure to retain deleted fixture properties if
        -- it existed and if not explicitly overriten by new properties
        ps.setFixtureInfo(self.fixture, fi, pp)
        self.body:resetMassData()
      end
      if pp.mass then body:setMass(pp.mass) end
    end
    self.physical_properties = nil
  end,

  build_spritefixture = function(self)
    local sp = self.spritefixture_properties
    if not self.body then self.body = lp.newBody(ps.pw, self.xstart or 0, self.ystart or 0) end
    local body = self.body
    body:setUserData(self)
    self.spritefixture = love.physics.newFixture(body, sp.shape)
    self.spritefixture:setCategory(SPRITECAT)
    self.spritefixture_properties = nil
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
