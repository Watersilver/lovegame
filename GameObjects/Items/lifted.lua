local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local o = require "GameObjects.objects"
local ps = require "physics_settings"

local floor = math.floor

local endOffset = {x = 0, y = -0.6 * ps.shapes.plshapeHeight}
local offsets = {
  down = {
    {x = 0, y = 3 * ps.shapes.plshapeHeight},
    {x = 0, y = 2.5 * ps.shapes.plshapeHeight},
    {x = 0, y = 1.5 * ps.shapes.plshapeHeight},
    endOffset
  },
  right = {
    {x = 1.5 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = 0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = 0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    endOffset
  },
  left = {
    {x = -1.5 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = -0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = -0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    endOffset
  },
  up = {
    {x = 0, y = 0},
    {x = 0, y = -0.1 * ps.shapes.plshapeHeight},
    {x = 0, y = -0.3 * ps.shapes.plshapeHeight},
    endOffset
  }
}

local Lifted = {}

function Lifted.initialize(instance)
  instance.sprite_info = {im.spriteSettings.testlift}
end

Lifted.functions = {
  update = function(self, dt)
    local cr = self.creator

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end
    local xoff, yoff

    -- Determine offset due to lifting stage
    if not self.lifted then
      local stage = floor(cr.liftingStage)
      local offs = offsets[self.side][stage]
      xoff, yoff = offs.x, offs.y
      if stage == 4 then
        self.xoff, self.yoff = xoff, yoff
        o.change_layer(self, cr.layer+1)
        self.lifted = true
      end
    else
      xoff, yoff = self.xoff, self.yoff
      -- Bobbing
      if floor(cr.image_index) == 1 then
        yoff = yoff + 1
        if self.side == "up" or self.side == "down" then
          self.angle = 0.1
          xoff = xoff + 1
          yoff = yoff + 0.5
        else
          self.angle = 0
        end
      elseif floor(cr.image_index) == 3 then
        yoff = yoff + 1
        if self.side == "up" or self.side == "down" then
          self.angle = - 0.1
          xoff = xoff - 1
          yoff = yoff + 0.5
        else
          self.angle = 0
        end
      else
        self.angle = 0
      end
    end

    -- Set position
    local creatorx, creatory = cr.body:getPosition()
    local x, y = creatorx + xoff, creatory + yoff - cr.height + cr.zo + fy

    self.x, self.y = x, y
  end,

  draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, self.x, self.y, self.angle,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local xtotal, ytotal = trans.still_objects_coords(self)

    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  delete = function (self)
  end
}

function Lifted:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Lifted, instance, init) -- add own functions and fields
  return instance
end

return Lifted
