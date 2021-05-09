local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local snd = require "sound"
local game = require "game"

local function instructionDone(self)
  if self.xClose then
    local low = math.min(self.xClose, self.xOpen)
    local high = math.max(self.xClose, self.xOpen)
    if self.x > high or self.x < low then return true end
  elseif self.yClose then
    local low = math.min(self.yClose, self.yOpen)
    local high = math.max(self.yClose, self.yOpen)
    if self.y > high or self.y < low then return true end
  end
  return false
end

local DungeonDoor = {}

function DungeonDoor.initialize(instance)
  instance.sprite_info = im.spriteSettings.door
  instance.physical_properties = {
    bodyType = "kinematic",
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1,
    mass = 40,
    linearDamping = 40,
    restitution = 0,
  }
  instance.ballbreaker = true
  instance.image_index = 0
  instance.pushback = true
  instance.layer = 13
  instance.forceSwordSound = true
  instance.yToClose = 0
  instance.xToClose = 0
  instance.doorSound = glsounds.dungeonDoor
  instance.instructions = {}
  instance.currentInstruction = nil
  instance.visible = false
  instance.speed = 180
  instance.ids[#instance.ids+1] = "DunDoor"
end

DungeonDoor.functions = {
  load = function (self)
    local side = self.side
    if side == "up" then
      self.yToClose = 1
      self.yClose = 8
      self.yOpen = - 9
      self.y = self.yOpen + 1
      self.image_index = 1
    elseif side == "down" then
      self.yToClose = -1
      self.yClose = game.room.height - 8
      self.yOpen = game.room.height + 9
      self.y = self.yOpen - 1
      self.image_index = 2
    elseif side == "left" then
      self.xToClose = 1
      self.xClose = 8
      self.xOpen = - 9
      self.x = self.xOpen + 1
      self.image_index = 0
    elseif side == "right" then
      self.xToClose = -1
      self.xClose = game.room.width - 8
      self.xOpen = game.room.width + 9
      self.x = self.xOpen - 1
      self.image_index = 3
    end
    self.body:setPosition(self.x, self.y)

    self:close()
  end,

  close = function(self)
    table.insert(self.instructions, "close")
  end,

  open = function(self)
    table.insert(self.instructions, "open")
  end,

  update = function(self, dt)
    self.x, self.y = self.body:getPosition()
    local frames = self.sprite.frames
    if self.image_index >= frames then
      self.image_index = frames - 0.1
    end

    self.prevInstruction = self.currentInstruction
    if #self.instructions ~= 0 then
      self.currentInstruction = self.instructions[1]
      table.remove(self.instructions, 1)
    end
    local newInst = self.prevInstruction ~= self.currentInstruction

    -- Follow opening or closing instructions
    if self.currentInstruction then
      if self.currentInstruction == "close" then
        if newInst then
          self.body:setLinearVelocity(self.xToClose * self.speed, self.yToClose * self.speed)
          -- become tangible when closing
          self.ballbreaker = true
          self.pushback = true
          self.forceSwordSound = true
          self.unpushable = false

          self.visible = true
        end
        if instructionDone(self) then
          self.x = self.xClose or self.x
          self.y = self.yClose or self.y
          self.body:setLinearVelocity(0, 0)
          self.body:setPosition(self.x, self.y)
          self.currentInstruction = nil
          snd.play(glsounds.dungeonDoor)
        end
      elseif self.currentInstruction == "open" then
        if newInst then
          self.body:setLinearVelocity(-self.xToClose * self.speed, -self.yToClose * self.speed)
        end
        if instructionDone(self) then
          self.x = self.xOpen or self.x
          self.y = self.yOpen or self.y
          self.body:setLinearVelocity(0, 0)
          self.body:setPosition(self.x, self.y)
          self.currentInstruction = nil
          snd.play(glsounds.dungeonDoor)
          -- Become intangible when open
          self.ballbreaker = false
          self.pushback = false
          self.forceSwordSound = false
          self.unpushable = true

          self.visible = false
        end
      end
    end
  end,

  draw = function (self, td)
    if not self.visible then return end

    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,
}

function DungeonDoor:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DungeonDoor, instance, init) -- add own functions and fields
  return instance
end

return DungeonDoor
