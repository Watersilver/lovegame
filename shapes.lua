love.physics.setMeter(16)

EdgeBrick16 = {
  u = love.physics.newEdgeShape(-8, -8, 8, -8), -- upper side
  l = love.physics.newEdgeShape(-8, -8, -8, 8), -- left side
  r = love.physics.newEdgeShape(8, -8, 8, 8), -- right side
  d = love.physics.newEdgeShape(-8, 8, 8, 8) -- down side
}

Rect16 = love.physics.newRectangleShape(16, 16)

function edgeToTiles(instance, edgetable)
  local i = 1
  if instance.tile[1] == "none" then return end
  instance.body = love.physics.newBody(physWorld, instance.position.x, instance.position.y)
  instance.fixtures = {}
  instance.shapes = {}
  for _, side in ipairs(instance.tile) do
    local shape = edgetable[side]
    push(instance.fixtures, love.physics.newFixture(instance.body, shape))
    instance.fixtures[i]:setUserData(instance)
    push(instance.shapes, shape)
    i = i + 1
  end
end
