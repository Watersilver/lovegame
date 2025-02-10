local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local im = require "image"
local dc = require "GameObjects.Helpers.determine_colliders"
local sh = require "GameObjects.shadow"
local zAxis = (require "movement").top_down.zAxis
local u = require "utilities"
local magic_dust_effects = require "GameObjects.Helpers.magic_dust_effects"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"

local o = require "GameObjects.objects"

local Drop = {}

local spriteInfo = {
  {'Drops/nothing', padding = 0, width = 7, height = 7},
}

local pp = {
  bodyType = "static",
  fixedRotation = true,
  shape = ps.shapes.circleHalf,
  masks = {FLOORCOLLIDECAT},
  categories = {DEFAULTCAT, ROOMEDGECOLLIDECAT}
}

local function onPlayerTouch()
end

function Drop.initialize(instance)
  instance.physical_properties = pp
  instance.sprite_info = spriteInfo
  instance.onPlayerTouch = onPlayerTouch
  instance.image_speed = 0
  instance.seeThrough = true
  instance.layer = 21
  instance.unpushable = true
  instance.x_scale = 1
  instance.y_scale = 1
  instance.zo = 0
  instance.zvel = 75
  instance.gravity = 400
  instance.notSolidStatic = true
  instance.notSolid = true
  instance.bounceOnce = true
  instance.thrownGoesThrough = true
  instance.attackDodger = true
  instance.frame_speed_mods = {}
  instance.isDrop = true
  instance.shadowHeightMod = 0

  session.setInstanceId(instance, 'drop:' .. instance.data.id)
end

Drop.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart

    ---@type CollectableData
    local data = self.data
    if data.load then
      data.load(self)
    end

    -- There can only be one piece of heart drop
    if data.id == "piece_of_heart" and #o.identified["drop:piece_of_heart"] > 1 then
      -- Will be removed after all load functions run, befor updates draws and collisions
      o.removeFromWorld(self)
    end
  end,

  [GCON.md.choose] = function ()
    return u.chooseFromChanceTable{
      -- chance of freezing
      {value = GCON.md.reaction.ice, chance = 0.02},
      -- chance of vanishing
      {value = GCON.md.reaction.disappear, chance = 0.73},
      -- If none of the above happens, nothing happens
      {value = GCON.md.reaction.nothing, chance = 1},
    }
  end,

  [GCON.md.reaction.ice] = function (self)
    magic_dust_effects.createFrozenBlock(self)
  end,

  [GCON.md.reaction.disappear] = function (self)
    magic_dust_effects.disappearEffect(self)
    o.removeFromWorld(self)
  end,

  update = function (self, dt)
    self.x, self.y = self.body:getPosition()

    ---@type CollectableData
    local data = self.data

    zAxis(self, dt)
    if self.bounceOnce and self.zo == 0 then
      self.zvel = 50
      self.zo = -0.0001
      self.bounceOnce = nil
    end
    if self.zo == 0 then o.change_layer(self, 19) end

    sh.handleShadow(self)

    if not self.touched and self.touchedBySword and self.zo == 0 and self.touchedBySword.creator and not self.touchedBySword.creator.triggers.posingForItem then
      self.touched = true
      o.removeFromWorld(self)
      self.touchedBySword.creator.triggers.posingForItem = true
      if data.dropTriggersFanfare == 'always' or (data.dropTriggersFanfare == 'once' and not session.save['dropfanfare_'..data.id]) then
        itemGetPoseAndDlg:fromData(data)
      else
        if data.nonFanfareEffect then data.nonFanfareEffect(self) end
        data.effect(self)
      end
      return
    end

    self.image_index = (self.image_index + dt*60*self.image_speed*(self.frame_speed_mods[math.floor(self.image_index)] or 1))
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end

    if data.update then
      data.update(self, dt)
    end
    if data.both_update then
      data.both_update(self, dt)
    end
  end,

  unstoppable_update = function (self, dt)
    ---@type CollectableData
    local data = self.data;

    if data.unstoppable_update then
      data.unstoppable_update(self, dt)
    end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.immasword then
      self.touchedBySword = other
    end

    -- Determine if I'm at the room edge. If not and I'm flying, skip.
    if other.roomEdge then
      self.edgeSide = other.roomEdge
      self.avoidDir = other.roomEdge
    else
      self.edgeSide = nil
      self.avoidDir = nil
    end
  end,

  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.immasword then
      self.touchedBySword = nil
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)

    ---@type CollectableData
    local data = self.data

    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    coll:setEnabled(false)
    if not otherF:isSensor() then
      if not self.touched and other.player and not other.triggers.posingForItem and (self.zo ~= 0 or other.zo == 0) then
        self.touched = true
        o.removeFromWorld(self)
        other.triggers.posingForItem = true
        if data.dropTriggersFanfare == 'always' or (data.dropTriggersFanfare == 'once' and not session.save['dropfanfare_'..data.id]) then
          itemGetPoseAndDlg:fromData(data)
        else
          if data.nonFanfareEffect then data.nonFanfareEffect(self) end
          data.effect(self)
        end
        return
      end
    end
  end,

  draw = function (self)
    local sprite = self.sprite
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[math.floor(self.image_index)]
    local zo = self.zo or 0
    local xtotal, ytotal = self.x, self.y + zo
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- end
  end,

  trans_draw = function (self)
    local sprite = self.sprite
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[math.floor(self.image_index)]

    local xtotal, ytotal = trans.moving_objects_coords(self)

    love.graphics.draw(
    sprite.img, frame,
    xtotal, ytotal, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   -- draw
    -- end
  end
}

function Drop:new(init)
  local instance = p:new({}, init) -- add parent functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end


---@param data CollectableData
---@param x number
---@param y number
---@param init? any
function Drop.fromData(data, x, y, init)
  local a = {
    xstart = x,
    ystart = y,
    x = x,
    y = y,
    sprite_info = data.sprite_info,
    image_speed = data.image_speed,
    data = data
  }

  if data.frame_speed_mods then
    a.frame_speed_mods = data.frame_speed_mods
  end

  if data.shadowHeightMod then
    a.shadowHeightMod = data.shadowHeightMod
  end

  if init then
    for key, val in pairs(init) do
      a[key] = val
    end
  end

  local newDrop = Drop:new(a)
  o.addToWorld(newDrop)
  return newDrop
end


return Drop
