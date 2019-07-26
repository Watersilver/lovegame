local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local im = require "image"
local trans = require "transitions"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"
local snd = require "sound"

local lp = love.physics

local rt = {}

local sprite_info = {im.spriteSettings.liftableRock}

local explosion_sprite = im.spriteSettings.rockDestruction
local explosion_sound = {"Effects/Oracle_Rock_Shatter"}

local function throw_collision(self)
  expl.commonExplosion(self)
end

function rt.initialize(instance)
  instance.sprite_info = sprite_info
  instance.contacts = 0
  instance.physical_properties = {
    shape = ps.shapes.circleAlmost1,
  }
  instance.layer = 15
  instance.liftable = true
  instance.pushback = true
  instance.ballbreaker = true
  instance.image_index = 0
  instance.throw_collision = throw_collision
end

rt.functions = {
  draw = function (self)
    local x, y = self.xstart, self.ystart
    local sprite = self.sprite
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function (self)
    local xtotal, ytotal = trans.still_objects_coords(self)

    local sprite = self.sprite
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  load = function(self)
    self.image_speed = 0
  end,

  beginContact = function(self, a, b, coll)
    self.contacts = self.contacts + 1
  end,

  endContact = function(self, a, b, coll)
    self.contacts = self.contacts - 1
  end,
}

function rt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(rt, instance, init) -- add own functions and fields
  return instance
end

return rt
