local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local shdrs = require "Shaders.shaders"
local u = require "utilities"

local Mark = {}

local floor = math.floor

local image_indexProgress = 0
local image_indexProgressDirection = 1

function Mark.initialize(instance)
  instance.sprite_info = {im.spriteSettings.mark}
  image_indexProgress = 0
  image_indexProgressDirection = 1
  instance.image_index = image_indexProgress
  instance.seeThrough = true
  instance.used = 0
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
  if session.canTeleport() then instance.transPersistent = true end
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

    -- Add effect if mark is capable of producing sword slice
    if self:canSlice() then
      if self.sliceCounter == nil then self.sliceCounter = 0 end
      self.sliceCounter = self.sliceCounter + dt
      if self.sliceCounter > .05 then
        self.sliceCounter = 0
        local dx, dy = u.randomPointFromEllipse(16, 8, true)
        session.particles:addSpark{x = self.xstart + dx, y = self.ystart+6 + dy}
      end
    end
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
    -- local sprite = self.sprite
    -- local frame = sprite[self.image_index]
    --
    -- local xtotal, ytotal = trans.still_objects_coords(self)
    --
    -- local worldShader = love.graphics.getShader()
    -- love.graphics.setShader(self.myShader)
    -- love.graphics.draw(
    -- sprite.img, frame,
    -- xtotal, ytotal+2, 0,
    -- sprite.res_x_scale, sprite.res_y_scale,
    -- sprite.cx, sprite.cy)
    -- love.graphics.setShader(worldShader)
  end,

  delete = function (self)
    if self.creator.mark == self then self.creator.mark = nil end
  end,

  canSlice = function (self)
    return self.creator and self.creator.exists and
    session.ringRecallSlice ~= nil and
    session.ringRecallSlice > self.used and
    self.roomName == session.latestVisitedRooms:getLast() and
    -- within slashing distance
    u.distance2d(self.xstart, self.ystart, self.creator.x, self.creator.y) < 200
  end,
}

function Mark:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Mark, instance, init) -- add own functions and fields
  return instance
end

return Mark
