local ps = require "physics_settings"
local u = require "utilities"
-- Use this file to try to see the player

local si = {}

--- defaultSightDistance
local dsg = 96
--- defaultSightWidth
local dsw = 48

local self

local seenObjs = {}

local function control(fixture, x, y, xn, yn, fraction)
  if fixture:isSensor() then return 1 end
  local other = fixture:getBody():getUserData()
  if other.seeThrough then return 1 end
  if not other.seen then table.insert(seenObjs, other) end
  other.seen = true
  return 1
end

function si.lookFor(seer, target)
  -- Return if I don't have to cast ray
  if not target then return end
  local sd = seer.sightDistance or dsg
  local sw = seer.sightWidth or dsw
  local sx, sy, tx, ty = seer.x, seer.y, target.x, target.y + 0.5 * ps.shapes.plshapeHeight
  -- If target isn't close enough, don't see target
  if u.distanceSqared2d(sx, sy, tx, ty) > sd*sd then return end
  -- If target isn't in the direction you're looking for, don't see target
  if seer.side then
    if seer.side == "up" then
      if not (sy > ty and math.abs(sx - tx) < sw) then return end
    elseif seer.side == "down" then
      if not (sy < ty and math.abs(sx - tx) < sw) then return end
    elseif seer.side == "left" then
      if not (sx > tx and math.abs(sy - ty) < sw) then return end
    else
      if not (sx < tx and math.abs(sy - ty) < sw) then return end
    end
  end
  -- If there are obstacles between self and target, don't see target
  ps.pw:rayCast(sx, sy, tx, ty, control)
  local seenObjsNum = #seenObjs
  -- empty seen objs
  for i in ipairs(seenObjs) do
    seenObjs[i].seen = nil
    seenObjs[i] = nil
  end
  if seenObjsNum == 1 then return true else return false end
end

function si.drawRay(seer, target)
  if not target then return end
  love.graphics.circle("line", seer.x, seer.y, seer.sightDistance or dsg)
  love.graphics.line(seer.x, seer.y, target.x, target.y + 0.5 * ps.shapes.plshapeHeight)
end

return si
