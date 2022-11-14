local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local nii = require "GameObjects.abstract.normalisedImageIndex"
local o = require "GameObjects.objects"
local si = require "sight"
local u = require "utilities"

local directionToFacing = {
  "down",
  "left",
  "up",
  "right"
}

local obj = {}

function obj.initialize(instance)
  -- If I want it to have some sprite
  instance.sprite_info = im.spriteSettings.boss5
  instance.layer = pl1.layer

  instance.direction = 1

  instance.lookFor = si.lookFor

  instance.faceRGBA = u.colorTable(0.729 * COLORCONST, 0.361 * COLORCONST, 0.04 * COLORCONST, COLORCONST)
  instance.stemRGBA = u.colorTable(0.18 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
  instance.darkRGBA = u.colorTable(1 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
  instance.lightRGBA = u.colorTable(1 * COLORCONST, 0.839 * COLORCONST, 0.549 * COLORCONST, COLORCONST)
  instance.insideRGBA = u.colorTable(0, 0, 0, COLORCONST)
end

obj.functions = {
  load = function(self)
    self:setFPS(0, 8)
    self:setII(2, 1)
  end,

  update = function (self, dt)
    if not self.parent.exists then o.removeFromWorld(self) return end

    self.x = self.anchor and self.anchor.x or self.parent.x
    self.y = self.anchor and self.anchor.y or self.parent.y

    if math.abs(self.parent.vx) > math.abs(self.parent.vy) then
      if self.parent.vx > 0 then
        self:lookRight()
      else
        self:lookLeft()
      end
    else
      if self.parent.vy >= 0 then
        self:lookDown()
      else
        self:lookUp()
      end
    end
    self:colorTrans(dt)

    self.facing = self:getFacing()

    -- Objects I can see through
    local seethroughobjs = {self.parent}
    if self.anchor and self.anchor.exists then table.insert(seethroughobjs, self.anchor) end
    -- Get tricked by decoy
    self.target = session.decoy or pl1
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(self.target, {ignore = seethroughobjs}) end

    if self.direction == 4 then
      self.x_scale = -1
      self:setIIx(1)
    else
      self.x_scale = 1
      self:setIIx(self.direction - 1)
    end
  end,

  colorTrans = function (self, dt)
    self.faceRGBA.t = self.faceRGBA.t + dt
    self.stemRGBA.t = self.stemRGBA.t + dt
    self.darkRGBA.t = self.darkRGBA.t + dt
    self.lightRGBA.t = self.lightRGBA.t + dt
    self.insideRGBA.t = self.insideRGBA.t + dt

    -- Toggle lit state every 5 secs
    if not self.litcounter then self.litcounter = 0 end
    if self.lit == nil then self.lit = false end
    local prevlc = self.litcounter
    self.litcounter = (self.litcounter + dt) % 5
    if self.litcounter < prevlc then
      if self.lit then
        self.faceRGBA:setTarget(0.729 * COLORCONST, 0.361 * COLORCONST, 0.04 * COLORCONST, COLORCONST)
        self.stemRGBA:setTarget(0.18 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
        self.darkRGBA:setTarget(1 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
        self.lightRGBA:setTarget(1 * COLORCONST, 0.839 * COLORCONST, 0.549 * COLORCONST, COLORCONST)
        self.insideRGBA:setTarget(0, 0, 0, COLORCONST)
      else
        self.faceRGBA:setTarget(1 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
        self.stemRGBA:setTarget(0.11 * COLORCONST, 0.377 * COLORCONST, 0.11 * COLORCONST, COLORCONST)
        self.darkRGBA:setTarget(0.729 * COLORCONST, 0.361 * COLORCONST, 0.04 * COLORCONST, COLORCONST)
        self.lightRGBA:setTarget(1 * COLORCONST, 0.427 * COLORCONST, 0.18 * COLORCONST, COLORCONST)
        self.insideRGBA:setTarget(COLORCONST, 0, 0, COLORCONST)
      end
      self.lit = not self.lit
    end
  end,

  getFacing = function (self)
    return directionToFacing[self.direction]
  end,

  lookUp = function (self)
    self.direction = 3
  end,

  lookDown = function (self)
    self.direction = 1
  end,

  lookLeft = function (self)
    self.direction = 2
  end,

  lookRight = function (self)
    self.direction = 4
  end,

  drawSprite = function (self, sprite, frame, x, y, color)
    local resetColor = u.storeColour()
    if color then love.graphics.setColor(color) end
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    self.x_scale * sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    resetColor()
  end,

  -- Used by draw and trans_draw
  customDraw = function (self, frame, x, y)
    self:drawSprite(im.sprites["Bosses/boss5/headBackground"], frame, x, y, self.insideRGBA:getTable())
    self:drawSprite(im.sprites["Bosses/boss5/headOutline"], frame, x, y)
    self:drawSprite(im.sprites["Bosses/boss5/headStem"], frame, x, y, self.stemRGBA:getTable())
    self:drawSprite(im.sprites["Bosses/boss5/headShadows"], frame, x, y, self.darkRGBA:getTable())
    self:drawSprite(im.sprites["Bosses/boss5/headHighlights"], frame, x, y, self.lightRGBA:getTable())
    self:drawSprite(im.sprites["Bosses/boss5/headFeatures"], frame, x, y, self.faceRGBA:getTable())
  end,
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(nii, instance) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
