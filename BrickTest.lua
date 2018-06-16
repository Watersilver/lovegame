local Brick = {}

local function draw(self)
  local pos = self.position
  local sprite = self.sprite
  self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, pos.x, pos.y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.ox, sprite.oy)
  if self.body then
    for i, shape in ipairs(self.shapes) do
      love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
    end
  end
end
local function on_load(self)
  self.image_speed = 0
  self.image_index = 2
  self.sprite = load_sprite{'Brick', 2, 2, dontinit = true}
  -- self.shape = love.physics.newRectangleShape(15, 15)
  -- local vertices = almostRectangle(15, 15)
  -- self.shape = love.physics.newPolygonShape(vertices)
  edgeToTiles(self, EdgeBrick16)
end

function Brick:new()
  local instance = {}
  instance.on_load = on_load
  instance.alt_on_load = alt_on_load
  instance.position = {x = 0, y = 0}
  instance.draw = draw
  instance.tile = true
  return instance
end

return Brick
