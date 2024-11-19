local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local lighting = require "ScreenEffects.lighting.lighting"

local NoBody = {}

function NoBody.initialize(instance)
  instance.sprite_info = {
    {'Tiles/TestTiles', 4, 7}
  }
  instance.image_speed = 0
  instance.image_index = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.angle = 0
end

NoBody.functions = {

  unstoppable_update = function (self)
    local xtotal = self.x or self.xstart
    local ytotal = self.y or self.ystart
    if game.transitioning and game.transitioning.type == 'scrolling' then
      xtotal, ytotal = trans.moving_objects_coords(self)
    end

    if self.light then
      if self.light.alpha_table then
        self.light.rgba.a = u.compute_alpha_from_table(self.image_indexfloat or self.image_index, self.sprite.frames, self.light.alpha_table, self.onPreviousRoom, game.transitioning)
      end
      lighting.applyLight({
        type = self.light.type,
        x = xtotal,
        y = ytotal,
        rgba = self.light.rgba
      })
    end
  end,

  draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]
    local r,g,b,a
    if self.rgba then
      r,g,b,a = love.graphics.getColor()
      love.graphics.setColor(self.rgba)
    end
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, self.x or self.xstart, self.y or self.ystart, self.angle,
    sprite.res_x_scale * self.x_scale, sprite.res_y_scale * self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    if r then
      love.graphics.setColor(r,g,b,a)
    end
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local xtotal, ytotal = trans.still_objects_coords(self)

    local r,g,b,a
    if self.rgba then
      r,g,b,a = love.graphics.getColor()
      love.graphics.setColor(self.rgba)
    end
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, self.angle,
    sprite.res_x_scale * self.x_scale, sprite.res_y_scale * self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    if r then
      love.graphics.setColor(r,g,b,a)
    end
  end
}

function NoBody:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NoBody, instance, init) -- add own functions and fields
  return instance
end

return NoBody
