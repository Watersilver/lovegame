local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local im = require "image"
local trans = require "transitions"
local o = require "GameObjects.objects"
local snd = require "sound"
local drops = require "GameObjects.drops.drops"
local FM = require ("GameObjects.FloorDetectors.floorMarker")

local dc = require "GameObjects.Helpers.determine_colliders"

local rt = {}

local sprite_info = {im.spriteSettings.liftableRock}

function rt.initialize(instance)
  instance.sprite_info = sprite_info
  instance.physical_properties = {
    shape = ps.shapes.circleAlmost1,
    masks = {PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
  }
  instance.pushback = true
  instance.ballbreaker = true
end

rt.functions = {
  load = function (self)
    self.image_speed = 0
    local x, y = self.body:getPosition()
    local myFm = FM:new{x = x, y = y}
    o.addToWorld(myFm)
  end,

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
}

function rt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(rt, instance, init) -- add own functions and fields
  return instance
end

return rt
