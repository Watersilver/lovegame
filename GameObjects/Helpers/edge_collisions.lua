local ps = require "physics_settings"

local abs = math.abs

local ec = {}

-- "below*Edge" functions check if "other" is on the low side of the edge
function ec.belowDownEdge(edge, other)
  return false
end

function ec.belowRightEdge(edge, other)
  local oLeftSide = other.body:getPosition() - other.width * 0.5
  if oLeftSide > edge.xstart + 8 then return true end
  return false
end

function ec.belowLeftEdge(edge, other)
  local oRightSide = other.body:getPosition() + other.width * 0.5
  if oRightSide < edge.xstart - 8 then return true end
  return false
end

-- "fallFrom*Edge" functions check if "other" will fall
function ec.wentOverDownEdge(sx, sy, ex, ey)
if abs(sy - ey) > 1 then return true end
return false
end

function ec.wentOverRightEdge(sx, sy, ex, ey)
if abs(sx - ex) > 1 then return true end
return false
end

function ec.wentOverLeftEdge(sx, sy, ex, ey)
if abs(sx - ex) > 1 then return true end
return false
end


function ec.isOnEdge(edge, other)
  if edge.side == "down" then
    return true
  elseif edge.side == "right" then
    return not ec.belowRightEdge(edge, other)
  else
    return not ec.belowLeftEdge(edge, other)
  end
end

return ec
