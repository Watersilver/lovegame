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

function si.lookFor(seer, target, options)
  if not options then options = {} end
  -- Return if I don't have to cast ray
  if not target then return false end
  if not options.seeDead then
    if target.deathState then return false end
  end
  local sd = seer.sightDistance or dsg
  local sw = seer.sightWidth or dsw
  local sx, sy, tx, ty = seer.x, seer.y, target.x, target.y + 0.5 * ps.shapes.plshapeHeight
  -- If target isn't close enough, don't see target
  if u.distanceSqared2d(sx, sy, tx, ty) > sd*sd then return false end
  -- If target isn't in the direction you're looking for, don't see target
  if seer.facing then
    if seer.facing == "up" then
      if not (sy > ty and math.abs(sx - tx) < sw) then return false end
    elseif seer.facing == "down" then
      if not (sy < ty and math.abs(sx - tx) < sw) then return false end
    elseif seer.facing == "left" then
      if not (sx > tx and math.abs(sy - ty) < sw) then return false end
    elseif seer.facing == "right" then
      if not (sx < tx and math.abs(sy - ty) < sw) then return false end
    else
      -- Check all four directions at the same time
      if not (sy > ty and math.abs(sx - tx) < sw) and
        not (sy < ty and math.abs(sx - tx) < sw) and
        not (sx > tx and math.abs(sy - ty) < sw) and
        not (sx < tx and math.abs(sy - ty) < sw) then
          return false
      end
    end
  end
  if seer.canSeeThroughWalls then return true end
  -- If there are obstacles between self and target, don't see target
  ps.pw:rayCast(sx, sy, tx, ty, control)

  if options.ignore then
    local ignoredIndexes = {}
    for o in ipairs(options.ignore) do
      for i in ipairs(seenObjs) do
        if options.ignore[o] == seenObjs[i] then
          table.insert(ignoredIndexes, i)
        end
      end
    end

    for j = #ignoredIndexes, 1, -1 do
      local i = ignoredIndexes[j]
      seenObjs[i].seen = nil
      table.remove(seenObjs, i)
    end
  end

  local seenObjsNum = #seenObjs
  -- empty seen objs
  for i in ipairs(seenObjs) do
    seenObjs[i].seen = nil
    seenObjs[i] = nil
  end
  -- To ensure there are no obstacles between me and my target:
  -- If target is a physical object and has a body,
  -- the seenobjs must be one because I can see the target's body.
  -- If the target is just coordinates, the seen objects must be zero
  if seenObjsNum == ((target.body and not target.seeThrough) and 1 or 0) then return true else return false end
end

function si.drawRay(seer, target)
  if not target then return end
  love.graphics.circle("line", seer.x, seer.y, seer.sightDistance or dsg)
  love.graphics.line(seer.x, seer.y, target.x, target.y + 0.5 * ps.shapes.plshapeHeight)
end

return si
