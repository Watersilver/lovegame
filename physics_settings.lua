local u = require "utilities"

-- Constants
-- Collision Categories
SPRITECAT = 16

local ps = {}

love.physics.setMeter(16)

ps.pw = love.physics.newWorld(0, 280)--280)

ps.shapes = {
  rect1x1 = love.physics.newRectangleShape(16, 16),
  lowr1x1 = love.physics.newPolygonShape(-8,0, 8,0, -8,8, 8,8),
  circle1 = love.physics.newCircleShape(8),
  edgeRect1x1 = {
    u = love.physics.newEdgeShape(-8, -8, 8, -8), -- upper side
    l = love.physics.newEdgeShape(-8, -8, -8, 8), -- left side
    r = love.physics.newEdgeShape(8, -8, 8, 8), -- right side
    d = love.physics.newEdgeShape(-8, 8, 8, 8) -- down side
  }
  -- EdgeBrick16.u:setPreviousVertex(-24, -8)
  -- EdgeBrick16.u:setNextVertex(24, -8)
}

function ps.shapes.edgeToTiles(instance, edgetable)
  local i = 1
  if instance.physical_properties.tile[1] == "none" then return
  end
  instance.body = love.physics.newBody(ps.pw, instance.xstart, instance.ystart)
  instance.body:setUserData(instance)
  instance.fixtures = {}
  instance.shapes = {}
  for _, side in ipairs(instance.physical_properties.tile) do
    local shape = edgetable[side]
    local newf = love.physics.newFixture(instance.body, shape)
    u.push(instance.fixtures, newf)
    newf:setMask(SPRITECAT)
    -- instance.fixtures[i]:setUserData(instance)
    u.push(instance.shapes, shape)
    i = i + 1
  end
end

function ps.getFixtureInfo(fixture)
  local fixtureInfo = {
    categories, mask, group = fixture:getFilterData(),
    restitution = fixture:getRestitution(),
    density = fixture:getDensity(),
    friction = fixture:getFriction(),
    sensor = fixture:isSensor()
  }
  return fixtureInfo
end

function ps.setFixtureInfo(fixture, fixtureInfo, physical_properties)
  local fi = fixtureInfo or {}
  local pp = physical_properties or {}
  -- magic numbers are defaults
  fixture:setFilterData(
  pp.categories or fi.categories or 1,
  pp.mask or fi.mask or 65535,
  pp.group or fi.group or 0)
  fixture:setRestitution(pp.restitution or fi.restitution or 0)
  fixture:setDensity(pp.density or fi.density or 1)
  fixture:setFriction(pp.friction or fi.friction or 0.5)
  fixture:setSensor(pp.sensor or fi.sensor or false)
  fixture:setMask(SPRITECAT, fixture:getMask())
end

return ps
