u = require "utilities"

local ps = {}

love.physics.setMeter(16)

ps.pw = love.physics.newWorld(0, 280)

ps.shapes = {
  rect1x1 = love.physics.newRectangleShape(16, 16),
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
    u.push(instance.fixtures, love.physics.newFixture(instance.body, shape))
    -- instance.fixtures[i]:setUserData(instance)
    u.push(instance.shapes, shape)
    i = i + 1
  end
end

return ps
