local p = require "GameObjects.prototype"
local im = require "image"
local o = require "GameObjects.objects"

local NoBody = require "GameObjects.noBody"

local function draw(spritename, parent)
  local sprite = im.sprites["Bosses/boss2/" .. spritename]
  local frame = sprite[0]
  love.graphics.draw(
  sprite.img, frame, parent.x, parent.y, parent.angle,
  sprite.res_x_scale * parent.x_scale, sprite.res_y_scale * parent.y_scale,
  sprite.cx, sprite.cy)
end

local Boss2Decorations = {}

function Boss2Decorations.initialize(instance)
  instance.sprite_info = im.spriteSettings.boss2
end

Boss2Decorations.functions = {
  late_update = function (self)
    if self.parent and self.parent.exists then
      o.change_layer(self, self.parent.layer + 1)
    else
      o.removeFromWorld(self)
    end
  end,

  draw = function (self)
    local parent = self.parent
    if parent and parent.exists then
      local worldShader = love.graphics.getShader()
      love.graphics.setShader(self.myShader)
      -- draw('beads', parent)
      -- draw('crown', parent)
      -- draw('eyegemsl', parent)
      -- draw('eyegemsr', parent)
      -- draw('facering', parent)
      -- draw('faceringholders', parent)
      -- draw('faceringholders2', parent)
      -- draw('gems', parent)
      -- draw('goldtoothl', parent)
      -- draw('goldtoothr', parent)
      draw('hornll', parent)
      draw('hornl', parent)
      draw('hornm', parent)
      draw('hornr', parent)
      draw('hornrr', parent)
      -- draw('nosechainl', parent)
      draw('earingl', parent)
      -- draw('noseringl', parent)
      -- draw('nosechainr', parent)
      -- draw('earingr', parent)
      -- draw('noseringr', parent)
      -- draw('shinytiara', parent)
      -- draw('symbol', parent)
      -- draw('thintiara', parent)
      -- draw('warriorcrown', parent)
      love.graphics.setShader(worldShader)
    end
  end,
}

function Boss2Decorations:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(NoBody, instance, init) -- add own functions and fields
  p.new(Boss2Decorations, instance, init) -- add own functions and fields
  return instance
end

return Boss2Decorations
