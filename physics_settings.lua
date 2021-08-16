local u = require "utilities"

-- Constants
-- Collision Categories
SPRITECAT = 16
PLAYERATTACKCAT = 15
ENEMYATTACKCAT = 14
FLOORCOLLIDECAT = 13
PLAYERJUMPATTACKCAT = 12
PLAYERCAT = 11
ROOMEDGECOLLIDECAT = 10
DEFAULTCAT = 1

local ps = {}

love.physics.setMeter(16)

ps.pw = love.physics.newWorld(0, 280)--280)
ps.pw:setGravity(0, 0)

-- Make shapes
ps.shapes = {
  rect1x1 = love.physics.newRectangleShape(16, 16),
  rectHalfxHalf = love.physics.newRectangleShape(8, 8),
  rectThreeFourths = love.physics.newRectangleShape(12, 12),
  rect13x16 = love.physics.newRectangleShape(13, 16),
  enemySword = love.physics.newRectangleShape(0, -2, 1, 10),
  edge10hor = love.physics.newEdgeShape(0, 0, 160, 0),
  edge10ver = love.physics.newEdgeShape(0, 0, 0, 160),
  -- edge10x10 = love.physics.newRectangleShape(160, 160),
    rect1x1minusinfinitesimal = love.physics.newRectangleShape(15, 15),
  circle1 = love.physics.newCircleShape(8),
  circle2 = love.physics.newCircleShape(16),
  circleThreeFourths = love.physics.newCircleShape(6),
  circleAlmost1 = love.physics.newCircleShape(7),
  circleAlmost2 = love.physics.newCircleShape(0, 8, 3),
  circleHalf = love.physics.newCircleShape(4),
  edgeRect1x1 = {
    u = love.physics.newEdgeShape(-8, -8, 8, -8), -- upper side
    l = love.physics.newEdgeShape(-8, -8, -8, 8), -- left side
    r = love.physics.newEdgeShape(8, -8, 8, 8), -- right side
    d = love.physics.newEdgeShape(-8, 8, 8, 8), -- down side
    d2 = love.physics.newEdgeShape(-8, 0, 8, 0) -- down side for zelda edges
  },
  edgeRectHalfxHalf = {
    u = love.physics.newEdgeShape(-4, -8, 4, -8), -- upper side
    l = love.physics.newEdgeShape(-8, -4, -8, 4), -- left side
    r = love.physics.newEdgeShape(8, -4, 8, 4), -- right side
    d = love.physics.newEdgeShape(-4, 8, 4, 8) -- down side
  },
  thickWallInner = {
    u = love.physics.newEdgeShape(-8, -1, 8, -1), -- upper side
    l = love.physics.newEdgeShape(-1, -8, -1, 8), -- left side
    r = love.physics.newEdgeShape(1, -8, 1, 8), -- right side
    d = love.physics.newEdgeShape(-8, 1, 8, 1) -- down side
  },
  -- Chess spritefixtures
  kingSprite = love.physics.newRectangleShape(16, 41),
  queenSprite = love.physics.newRectangleShape(16, 39),
  rookSprite = love.physics.newRectangleShape(16, 20),
  bishopSprite = love.physics.newRectangleShape(13, 24),

  swordSprite = love.physics.newRectangleShape(16, 15),
  -- swordIgniting = love.physics.newRectangleShape(0, 7, 2, 7+7),
  swordIgniting = love.physics.newRectangleShape(0, -2, 2, 7),
  swordSwing = love.physics.newPolygonShape(-7,-7, 5,-5, -5,5, 6,6),
  -- swordSwingWide = love.physics.newPolygonShape(-14,-9, 5,-5, -10,10, 9,14),
  swordSwingWide = love.physics.newPolygonShape(-12,-10, -12,1, 0,11, 8,11, 4,-4),
  swordStill = love.physics.newRectangleShape(0, 1, 1, 16),
  -- swordStill = love.physics.newRectangleShape(0, 6, 1, 15 + 10),
  swordHeld = love.physics.newRectangleShape(0, -2, 1, 10),
  -- EdgeBrick16.u:setPreviousVertex(-24, -8)
  -- EdgeBrick16.u:setNextVertex(24, -8)
  edgeDown = love.physics.newEdgeShape(-7, 1, 7, 1),
  missile = love.physics.newCircleShape(2),
  point = love.physics.newCircleShape(1),
  -- thrown = love.physics.newRectangleShape(0, 5, 7, 6), -- old plshape
  thrown = love.physics.newRectangleShape(0, 5, 6, 5),
  portal = love.physics.newRectangleShape(8,8),
  bosses = {
    boss1 = {
      sprite = love.physics.newRectangleShape(0, 0, 37*0.5, 61*0.5),
      body = love.physics.newRectangleShape(0, 5, 10, 20),
      laser = love.physics.newRectangleShape(0, 80, 20, 160),
    },
    boss2 = {
      -- head = love.physics.newRectangleShape(0, 0, 37*0.5, 61*0.5),
      head = love.physics.newRectangleShape(0, 3, 89, 48),
      eye = love.physics.newRectangleShape(8,8),
      hand = love.physics.newRectangleShape(36,24),
    },
    boss3 = {
      sprite = love.physics.newRectangleShape(56,68),
      -- body = love.physics.newRectangleShape(0, 24, 46, 20), -- 68
      body = love.physics.newRectangleShape(0, 24, 30, 20),
    },
    boss4 = {
      sprite = love.physics.newRectangleShape(28,29),
      -- body = love.physics.newRectangleShape(20, 24)
      body = love.physics.newCircleShape(12)
    }
  }
}
-- Make player shapes
-- zelda sprite dimensions 9.5, 7.6 -- (10, 8) x 0.95
-- mochi dimentions local width, height = 6.5, 6.8
local width, height = 9.5, 7.6
ps.shapes.plshapeWidth = width
ps.shapes.plshapeHeight = height
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
  local pp = instance.physical_properties
  if pp.tile[1] == "none" then return end
  instance.body = love.physics.newBody(ps.pw, instance.xstart, instance.ystart)
  instance.body:setUserData(instance)
  instance.fixtures = {}
  instance.isTile = true
  for _, side in ipairs(pp.tile) do
    local shape = edgetable[side]
    local newf = love.physics.newFixture(instance.body, shape)
    if pp.restitution then newf:setRestitution(pp.restitution) end
    u.push(instance.fixtures, newf)
    newf:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)
    newf:setUserData(side)
    -- instance.fixtures[i]:setUserData(instance)
    i = i + 1
  end

  -- WARNING: This is here so that walls aren't paper thin. Might want to find better way
  -- WARNING: HATCHET JOB. Don't delete. Will break floor detection
  local shape = ps.shapes.rect1x1minusinfinitesimal
  local newf = love.physics.newFixture(instance.body, shape)
  u.push(instance.fixtures, newf)
  newf:setMask(SPRITECAT, PLAYERJUMPATTACKCAT)
  newf:setCategory(FLOORCOLLIDECAT)
  -- WARNING: HATCHET JOB

  -- if pp.bodyType == "dynamic" then
  if pp.bodyType and pp.bodyType ~= "static" then
    instance.body:setType(pp.bodyType)
    instance.body:setFixedRotation(true)
    instance.body:setMass(pp.mass or 40)
    instance.body:setLinearDamping(pp.linearDamping or 40)
    for _, fixture in ipairs(instance.body:getFixtureList()) do
      fixture:setRestitution(pp.restitution or 0)
    end
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
  pp.category or fi.category or 1,
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

  if pp.categories then
    local firstTime = true
    for _, category in ipairs(pp.categories) do
      if firstTime then
        fixture:setCategory(category)
        firstTime = false
      else
        fixture:setCategory(category, fixture:getCategory())
      end
    end
  end
end

return ps
