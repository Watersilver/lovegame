local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local lighting = require "ScreenEffects.lighting.lighting"
local o = require "GameObjects.objects"
local text = require "text"

local TextFloating = {}

function TextFloating.initialize(instance)
  instance.text = love.graphics.newText(instance.font or text.font.tiny, instance.content)
  instance.lifetime = 0
  instance.opacity = instance.opacity or 1
  instance.layer = 30
  instance.draw_type = instance.draw_type or 'normal'
end

TextFloating.functions = {
  removeFromWorld = function(self)
    o.removeFromWorld(self)
  end,

  getLifetime = function(self)
    return self.lifetime
  end,

  unstoppable_update = function (self, dt)
    self.lifetime = self.lifetime + dt

    if self.movement then
      self.x = self.x + dt * self.movement.vx
      self.y = self.y + dt * self.movement.vy
    end

    local x, y = self.x, self.y

    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.moving_objects_coords(self)
    end

    if self.onUnstoppableUpdate then
      self:onUnstoppableUpdate(dt, x, y)
    end
  end,

  ---@param self TextFloatingObject
  ---@param td boolean
  draw = function(self, td)
    if self.draw_type == 'overlay' then return end

    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(1,1,1,self.opacity)
    love.graphics.draw(self.text, x, y, self.angle, self.x_scale, self.y_scale, self.text:getWidth() * 0.5, self.text:getHeight() * 0.5)
    love.graphics.setColor(r,g,b,a)
  end,

  --- There's currently an issue. If you draw overlay after scrolling the screen the coordinates get messed up.
  ---@param self TextFloatingObject
  ---@param td boolean
  draw_overlay = function(self, td)
    if self.draw_type == 'normal' then return end

    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(1,1,1,self.opacity)
    love.graphics.draw(self.text, x, y, self.angle, self.x_scale, self.y_scale, self.text:getWidth() * 0.5, self.text:getHeight() * 0.5)
    love.graphics.setColor(r,g,b,a)
  end,

  trans_draw = function(self)
    local dt = self.draw_type
    self.draw_type = 'normal'
    self:draw(true)
    self.draw_type = dt
  end,
}

function TextFloating:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(TextFloating, instance) -- add own functions and fields
  return instance
end

---@class TextFloatingObject: TextFloatingSettings
---@field text love.Text
---@field removeFromWorld fun(self)
---@field getLifetime fun(self): number counts seconds of existence (even when paused)
---@field opacity number range is [0,1]
---@field layer number
---@field draw_type 'overlay' | 'normal'

---@class TextFloatingSettings
---@field x number
---@field y number
---@field content string
---@field draw_type? 'overlay' | 'normal' (default: normal)
---@field angle? number radians
---@field x_scale? number
---@field y_scale? number
---@field opacity? number
---@field movement? {vx: number, vy: number}
---@field font? love.Font
---@field onUnstoppableUpdate? fun(self: TextFloatingObject, dt:number, trans_x: number, trans_y: number)
---@field layer? number

---@param settings TextFloatingSettings
function TextFloating:addNew(settings)
  local newtf = TextFloating:new(settings)
  o.addToWorld(newtf)
  return newtf
end

return TextFloating
