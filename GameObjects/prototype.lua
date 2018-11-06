local ps = require "physics_settings"
local im = require "image"
local u = require "utilities"

local lp = love.physics

local p = {}

p.functions = {
  build_body = function(self)
    local pp = self.physical_properties
    if not pp then return end

    --Check if tile
    if pp.tile then
      ps.shapes.edgeToTiles(self, pp.edgetable)
    --Check if thick wall
    elseif pp.thickWall then
      if not self.body then self.body = lp.newBody(ps.pw, self.xstart or 0, self.ystart or 0) end
      local body = self.body
      body:setUserData(self)
      self.fixtures = {}
      for _, shape in ipairs(pp.thickWall) do
        local newf = love.physics.newFixture(body, shape)
        newf:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)
        u.push(self.fixtures, newf)
      end
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

        -- Fixture info
        local fi = nil

        -- If fixture exists, save its info and destroy it
        if self.fixture then
          fi = ps.getFixtureInfo(self.fixture)
          self.fixture:destroy()
        end

        -- Make new fixture to attach new shape to body
        self.fixture = love.physics.newFixture(self.body, pp.shape)

        -- Make sure to retain deleted fixture properties if
        -- it existed and if not explicitly overriten by new properties
        ps.setFixtureInfo(self.fixture, fi, pp)
        if pp.downSensor then
          self.downfixture = love.physics.newFixture(body, pp.downSensor, 0)
          self.downfixture:setMask(self.fixture:getMask())
          -- self.downfixture:setCategory(self.fixture:getCategory())
          self.downfixture:setSensor(true)
          self.downfixture:setUserData("downTouch")
        end
        if pp.rightSensor then
          self.rightfixture = love.physics.newFixture(body, pp.rightSensor, 0)
          self.rightfixture:setMask(self.fixture:getMask())
          -- self.rightfixture:setCategory(self.fixture:getCategory())
          self.rightfixture:setSensor(true)
          self.rightfixture:setUserData("rightTouch")
        end
        if pp.leftSensor then
          self.leftfixture = love.physics.newFixture(body, pp.leftSensor, 0)
          self.leftfixture:setMask(self.fixture:getMask())
          -- self.leftfixture:setCategory(self.fixture:getCategory())
          self.leftfixture:setSensor(true)
          self.leftfixture:setUserData("leftTouch")
        end
        if pp.upSensor then
          self.upfixture = love.physics.newFixture(body, pp.upSensor, 0)
          self.upfixture:setMask(self.fixture:getMask())
          -- self.upfixture:setCategory(self.fixture:getCategory())
          self.upfixture:setSensor(true)
          self.upfixture:setUserData("upTouch")
        end
        self.body:resetMassData()
      end

      if pp.mass then body:setMass(pp.mass) end

    end

    self.physical_properties = nil
  end,

  build_spritefixture = function(self)
    local sp = self.spritefixture_properties
    if not self.spritebody then self.spritebody = lp.newBody(ps.pw, self.xstart or 0, self.ystart or 0, "dynamic") end
    local body = self.spritebody
    body:setUserData(self)
    body:setGravityScale(0)
    body:setFixedRotation(true)
    self.spritefixture = love.physics.newFixture(body, sp.shape, 0)
    self.spritefixture:setCategory(SPRITECAT)
    self.spritefixture_properties = nil
  end,

  load_sprites = function(self)
    local si = self.sprite_info
    if not si then return end
    local sinum = #si
    for i = 1, sinum do
      im.load_sprite(si[i])
    end
    self.sprite = im.sprites[si[1][1] or si[1][img_name]]
  end,

  unload_sprites = function(self)
    local si = self.sprite_info
    if not si or not self.drawable then return end
    local sinum = #si
    for i = 1, sinum do
      im.unload_sprite(si[i][1] or si[i][img_name])
    end
  end,

  trans_draw = function()
  end
}

function p.initialize(instance)
  instance.ids = {}
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
