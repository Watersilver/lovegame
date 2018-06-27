local ps = require "physics_settings"
local im = require "image"
local inp = require "input"
local p = require "GameObjects.prototype"
local mo = require "movement"

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
    density = 80,
    shape = ps.shapes.lowr1x1,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0
  }
  instance.spritefixture_properties = {
    shape = ps.shapes.rect1x1
  }
  instance.player = "player1"
  instance.layer = 3
end

Playa.functions = {
update = function(self, dt)

  -- Return movement table based on the long term action you want to take (Npcs)
  -- Return movement table based on the given input (Players)
  self.input = inp.current[self.player]

  -- Apply movement table
  mo.top_down(self, dt)

  -- Figure out what to draw
  self.sprite.rot = self.sprite.rot --+ 0.01
  self.image_index = (self.image_index + dt*60*self.image_speed) % self.sprite.frames
end,

draw = function(self)
  local x, y = self.body:getPosition()
  self.x, self.y = x, y
  local sprite = self.sprite
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
