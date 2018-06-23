local ps = require "physics_settings"
local im = require "image"
local inp = require "input"
local p = require "GameObjects.prototype"

local Playa = {}

local function load_sprites()
  im.load_sprite{
    'GuyWalk', 4, width = 16, height = 16
  }
  im.load_sprite{
    'Test', 1, padding = 0
  }

  im.load_sprite{
    'Plrun_strip12', 12, padding = 0, width = 16, height = 16
  }
  return im.sprites['GuyWalk']
end

function Playa.initialize(instance)
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    mass = 50,
    shape = ps.shapes.rect1x1,
    restitution = 0
  }
end

Playa.functions = {
update = function(self, dt)
  local _, gravity = ps.pw:getGravity()
  local pl1in = inp.current.player1
  self.body:applyForce((pl1in.right-pl1in.left)*500,pl1in.down-pl1in.up*gravity*2)
  if not self.jumplimit then self.jumplimit = 0 end
  if self.jumplimit == 0 then
    -- self.body:applyLinearImpulse(0, -pl1in.up*200)
    if pl1in.up == 1 then self.jumplimit = 100 end
  end
  self.jumplimit = self.jumplimit - 1
  if self.jumplimit < 1 then self.jumplimit = 0 end

  self.sprite.rot = self.sprite.rot --+ 0.01
  self.image_index = (self.image_index + dt*60*self.image_speed) % self.sprite.frames
end,

draw = function(self)
  x, y = self.body:getPosition()
  local sprite = self.sprite
  -- -- make independent of framerate
  -- self.image_index = (self.image_index + self.image_speed) % sprite.frames
  local frame = sprite[math.floor(self.image_index)]
  love.graphics.draw(
  sprite.img, frame, x, y, sprite.rot,
  sprite.res_x_scale*sprite.sx, sprite.res_y_scale*sprite.sy,
  sprite.ox, sprite.oy)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end,

load = function(self)
  self.image_speed = 0.1
  self.sprite = load_sprites()
end,

preSolve = function(self, a, b, coll)
  -- coll:setEnabled(false)
end,

postSolve = function(self, a, b, coll, normalimpulse, tangentimpulse)
  -- fuck = normalimpulse
  debugtxt = tangentimpulse
end
}

function Playa:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Playa, instance, init) -- add own functions and fields
  return instance
end

return Playa
