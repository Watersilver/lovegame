local Playa = {}

local function update(self, dt)
  local _, gravity = physWorld:getGravity()
  self.body:applyForce((pl1in.right-pl1in.left)*500,pl1in.down-pl1in.up*gravity*2)
  if not self.jumplimit then self.jumplimit = 0 end
  if self.jumplimit == 0 then
    -- self.body:applyLinearImpulse(0, -pl1in.up*200)
    if pl1in.up == 1 then self.jumplimit = 100 end
  end
  self.jumplimit = self.jumplimit - 1
  if self.jumplimit < 1 then self.jumplimit = 0 end

  self.sprite.rot = self.sprite.rot --+ 0.01
end

local function draw(self)
  local pos = self.position
  pos.x, pos.y = self.body:getPosition()
  local sprite = self.sprite
  self.image_index = (self.image_index + self.image_speed) % sprite.frames
  local frame = sprite[math.floor(self.image_index)]
  love.graphics.draw(
  sprite.img, frame, pos.x, pos.y, sprite.rot,
  sprite.res_x_scale*sprite.sx, sprite.res_y_scale*sprite.sy,
  sprite.ox, sprite.oy)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end

local function load_sprites()
  load_sprite{
    'GuyWalk', 4, width = 16, height = 16
  }
  load_sprite{
    'Test', 1, padding = 0
  }

  load_sprite{
    'Plrun_strip12', 12, padding = 0, width = 16, height = 16
  }
  return sprites['Test']
end

local function on_load(self)
  self.image_speed = 0.1
  self.sprite = load_sprites()
  local pos = self.position
  self.body = love.physics.newBody(physWorld, pos.x, pos.y, "dynamic")
  self.body:setFixedRotation(true)
  self.body:setMass(50)
  self.shape = Rect16
  -- local vertices = almostRectangle(16, 16)
  -- self.shape = love.physics.newPolygonShape(vertices)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(0)
  self.fixture:setUserData(self)
end

local function postSolve(self, a, b, coll, normalimpulse, tangentimpulse)
  fuck = normalimpulse
  debugtxt = tangentimpulse
end

function Playa:new()
  local instance = {}
  instance.on_load = on_load
  instance.position = {x = 0, y = 0}
  instance.update = update
  instance.collide = collide
  instance.draw = draw
  instance.postSolve = postSolve
  return instance
end

return Playa
