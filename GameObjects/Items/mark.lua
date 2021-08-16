local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local shdrs = require "Shaders.shaders"

local Mark = {}

local floor = math.floor

local image_indexProgress = 0
local image_indexProgressDirection = 1

-- TODO items for marking screens of overworld
-- TODO fix trans draw
-- TODO Also a global var that knows if I am able to teleport from this screen to another
function Mark.initialize(instance)
  instance.sprite_info = {im.spriteSettings.mark}
  image_indexProgress = 0
  image_indexProgressDirection = 1
  instance.image_index = image_indexProgress
  instance.seeThrough = true
  if shdrs.markCustomShader and session.save.customMarkAvailable and session.save.customMarkEnabled then
    local secondaryR = 0.65 + session.save.markR * 0.35
    local secondaryG = 0.65 + session.save.markG * 0.35
    local secondaryB = 0.65 + session.save.markB * 0.35
    shdrs.markCustomShader:send("rgb",
    session.save.markR,
    session.save.markG,
    session.save.markB,
    secondaryR, secondaryG, secondaryB,
    1) -- send one extra value to offset bug
    instance.myShader = shdrs.markCustomShader
  else
    if session.save.faroresCourage then instance.myShader = shdrs["itemGreenShader"] end
  end

  -- for teleport between screens
  instance.transPersistent = true
  instance.roomName = session.latestVisitedRooms:getLast()
end

Mark.functions = {
  load = function (self)
    framesSlice = 1/self.sprite.frames
  end,

  update = function (self, dt)
    image_indexProgress = image_indexProgress + dt * image_indexProgressDirection
    if image_indexProgress >= 1 then
      image_indexProgress = 1 - framesSlice
      image_indexProgressDirection = - image_indexProgressDirection
    elseif image_indexProgress < 0 then
      image_indexProgress = framesSlice
      image_indexProgressDirection = - image_indexProgressDirection
    end
    self.image_index = floor(image_indexProgress * self.sprite.frames)
  end,

  draw = function (self)
    if session.latestVisitedRooms:getLast() ~= self.roomName then return end

    local sprite = self.sprite
    local frame = sprite[self.image_index]
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, self.xstart, self.ystart+2, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    if self.body then
      -- draw
    end
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]

    local xtotal, ytotal = trans.still_objects_coords(self)

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal+2, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
  end,

  delete = function (self)
    if self.creator.mark == self then self.creator.mark = nil end
  end
}

function Mark:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Mark, instance, init) -- add own functions and fields
  return instance
end

return Mark
