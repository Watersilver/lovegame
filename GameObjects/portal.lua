local game = require "game"
local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local trans = require "transitions"
local snd = require "sound"
local nfl = require "GameObjects.nonFlickeringLight"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local Portal = {}

function Portal.initialize(instance)
  instance.sprite_info = {
    {'Tiles/TestTiles', 4, 4}
  }
  instance.physical_properties = {
    bodyType = "static",
    sensor = true,
    shape = ps.shapes.portal,
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT}
  }
  -- instance.destination = "Rooms/room1.lua"
  instance.desx = 55
  instance.desy = 55
  instance.unpushable = true
  -- instance.grounded = true -- can be jumped over
end

Portal.functions = {
  load = function (self)
    if self.light then
      local light = nfl:new{
        xstart = self.xstart, ystart = self.ystart,
        x = self.xstart, y = self.ystart,
      }
      o.addToWorld(light)
    end
  end,

  draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, self.xstart, self.ystart, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    -- if self.body then
    --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- end
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
    -- if self.body then
    --   -- draw
    -- end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.player and self.destination then
      -- allow player to jump over ground portal
      if not game.transitioning and not (self.grounded and other.zo < 0) then
        snd.play(glsounds.stairs)
        game.transition{
          type = "whiteScreen",
          progress = 0,
          roomTarget = self.destination,
          playa = other,
          desx = self.desx,
          desy = self.desy
        }
      end
    end

  end
}

function Portal:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Portal, instance, init) -- add own functions and fields
  return instance
end

return Portal
