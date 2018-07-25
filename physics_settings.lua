local u = require "utilities"

-- Constants
-- Collision Categories
SPRITECAT = 16
PLAYERATTACKCAT = 15
ENEMYATTACKCAT = 14

local ps = {}

love.physics.setMeter(16)

ps.pw = love.physics.newWorld(0, 280)--280)

-- Make shapes
ps.shapes = {
  rect1x1 = love.physics.newRectangleShape(16, 16),
  circle1 = love.physics.newCircleShape(8),
  edgeRect1x1 = {
    u = love.physics.newEdgeShape(-8, -8, 8, -8), -- upper side
    l = love.physics.newEdgeShape(-8, -8, -8, 8), -- left side
    r = love.physics.newEdgeShape(8, -8, 8, 8), -- right side
    d = love.physics.newEdgeShape(-8, 8, 8, 8) -- down side
  },
  swordSprite = love.physics.newRectangleShape(16, 15),
  swordIgniting = love.physics.newRectangleShape(0, 7, 2, 7+7),
  swordSwing = love.physics.newCircleShape(6), -- or rect(12, 13),
  swordStill = love.physics.newRectangleShape(0, 4, 2, 15+7),
  -- EdgeBrick16.u:setPreviousVertex(-24, -8)
  -- EdgeBrick16.u:setNextVertex(24, -8)
}
-- Make player shapes
local width, height = 10, 8
-- Main collision shape
ps.shapes.plshape = love.physics.newRectangleShape(
0, height * 0.5,
width, height
)
-- Directional sensors
local proportion, thickness = 0.95, 0.16
ps.shapes.pldsens = love.physics.newRectangleShape(
0, height,
width * proportion, thickness
)
ps.shapes.plusens = love.physics.newRectangleShape(
0, 0,
width * proportion, thickness
)
ps.shapes.pllsens = love.physics.newRectangleShape(
-width * 0.5, height * 0.5,
thickness, height * proportion
)
ps.shapes.plrsens = love.physics.newRectangleShape(
width * 0.5, height * 0.5,
thickness, height * proportion
)

function ps.shapes.edgeToTiles(instance, edgetable)
  local i = 1
  if instance.physical_properties.tile[1] == "none" then return
  end
  instance.body = love.physics.newBody(ps.pw, instance.xstart, instance.ystart)
  instance.body:setUserData(instance)
  instance.fixtures = {}
  for _, side in ipairs(instance.physical_properties.tile) do
    local shape = edgetable[side]
    local newf = love.physics.newFixture(instance.body, shape)
    u.push(instance.fixtures, newf)
    newf:setMask(SPRITECAT)
    -- instance.fixtures[i]:setUserData(instance)
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

  if pp.masks then
    for _, mask in ipairs(pp.masks) do
      fixture:setMask(mask, fixture:getMask())
    end
  end
end

return ps
