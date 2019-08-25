local o = require "GameObjects.objects"
local game = require "game"
local ps = require "physics_settings"
local u = require "utilities"


local emptyFunc = u.emptyFunc


local trans = {}

function trans.remove_from_world_previous_room()
  for _, object in ipairs(o.updaters) do o.transRemoveFromWorld(object) end
  for _, object in ipairs(o.earlyUpdaters) do o.transRemoveFromWorld(object) end
  for _, object in ipairs(o.lateUpdaters) do o.transRemoveFromWorld(object) end
  for _, object in ipairs(o.colliders) do o.transRemoveFromWorld(object) end
  for _, layer in ipairs(o.draw_layers) do
    for _, object in ipairs(layer) do
      o.transRemoveFromWorld(object)
      object.onPreviousRoom = true
      -- if replacing object.destroy here is not enough, also replace it in the trans coords funcs
      object.destroy = object.trans_destroy or emptyFunc
    end
  end

  game.transitioning.startedTransition = true
end

function trans.determine_coordinates_transformation()
  local side = game.transitioning.side

  if side == "left" then
    trans.xtransform = game.transitioning.progress * trans.camw
    trans.ytransform = 0
    trans.xadjust = ps.shapes.plshapeWidth
    trans.yadjust = 0
    trans.xdisplacement = -game.room.width
    trans.ydisplacement = 0
  elseif side == "right" then
    local xtrans = game.room.width - game.room.prevWidth
    trans.xtransform = xtrans-game.transitioning.progress * trans.camw
    trans.ytransform = 0
    trans.xadjust = -ps.shapes.plshapeWidth
    trans.yadjust = 0
    trans.xdisplacement = game.room.prevWidth
    trans.ydisplacement = 0
  elseif side == "up" then
    trans.xtransform = 0
    trans.ytransform = game.transitioning.progress * trans.camh
    trans.xadjust = 0
    trans.yadjust = ps.shapes.plshapeHeight * 2
    trans.xdisplacement = 0
    trans.ydisplacement = -game.room.height
  elseif side == "down" then
    local ytrans = game.room.height - game.room.prevHeight
    trans.xtransform = 0
    trans.ytransform = ytrans-game.transitioning.progress * trans.camh
    trans.xadjust = 0
    trans.yadjust = -ps.shapes.plshapeHeight * 2
    trans.xdisplacement = 0
    trans.ydisplacement = game.room.prevHeight
  end
end

function trans.player_target_coords(plax, play)
  local side = game.transitioning.side
  local xtarget
  local ytarget

  if side == "left" then
    xtarget = game.room.width - ps.shapes.plshapeWidth * 0.5 + game.transitioning.xmod
    ytarget = play + game.transitioning.ymod
  elseif side == "right" then
    xtarget = ps.shapes.plshapeWidth * 0.5 + game.transitioning.xmod
    ytarget = play + game.transitioning.ymod
  elseif side == "up" then
    xtarget = plax + game.transitioning.xmod
    ytarget = game.room.height - ps.shapes.plshapeHeight + game.transitioning.ymod
  elseif side == "down" then
    xtarget = plax + game.transitioning.xmod
    ytarget = ps.shapes.plshapeHeight + game.transitioning.ymod
  end

  return xtarget, ytarget
end

function trans.camera_modification()
  local side = game.transitioning.side
  local camxtmod, camytmod = 0, 0

  if side == "left" then
    camxtmod = 0
    camytmod = 0
  elseif side == "right" then
    camxtmod = game.room.width
    camytmod = 0
  elseif side == "up" then
    camxtmod = 0
    camytmod = 0
  elseif side == "down" then
    camxtmod = 0
    camytmod = game.room.height
  end

  return camxtmod, camytmod
end

function trans.still_objects_coords(instance)
  local xtotal, ytotal
  local zo = instance.zo or 0

  if instance.onPreviousRoom then
    xtotal = instance.xstart + trans.xtransform
    ytotal = instance.ystart + zo + trans.ytransform
  else
    xtotal = instance.xstart + trans.xtransform
      - game.transitioning.xmod + trans.xdisplacement
    ytotal = instance.ystart + zo + trans.ytransform
      - game.transitioning.ymod + trans.ydisplacement
  end

  return xtotal, ytotal
end

function trans.moving_objects_coords(instance)
  local xtotal, ytotal

  if instance.onPreviousRoom then
    xtotal = instance.x + trans.xtransform
    ytotal = instance.y + trans.ytransform
  else
    xtotal = instance.x + trans.xtransform
      - game.transitioning.xmod + trans.xdisplacement
    ytotal = instance.y + trans.ytransform
      - game.transitioning.ymod + trans.ydisplacement
  end

  return xtotal, ytotal
end

return trans
