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
function ec.wentOverDownEdge(edge, other)
  -- oldest
  -- local sx, sy = edge.playerContactX, edge.playerContactY
  -- local ex, ey = other.body:getPosition()
  -- if abs(sy - ey) > 1 then return true end
  -- return false

  -- old
  -- if other.y > edge.ystart then return true end
  -- return false

  return true
end

function ec.wentOverRightEdge(edge, other)
  -- old code
  -- local sx = edge.playerContactX
  -- local ex = other.body:getPosition()
  -- if abs(sx - ex) > 1 then
  --   return true
  -- end
  local contactX = edge.playerContactX
  local selfX = edge.body:getPosition()
  local otherX = other.body:getPosition()
  -- magic number is because otherX is slightly smaller than edge but I won't calculate how much
  if otherX > selfX + 10 and contactX < selfX + 10 then
    return true
  end

  return false
end

function ec.wentOverLeftEdge(edge, other)
  local contactX = edge.playerContactX
  local selfX = edge.body:getPosition()
  local otherX = other.body:getPosition()

  if otherX < selfX - 10 and contactX > selfX - 10 then
    return true
  end
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


function ec.swordBelowEdge(edge, other)
  local otherSide = edge.side
  if otherSide == "right" then
    if ec.belowRightEdge(edge, other) then return true end
  elseif otherSide == "left" then
    if ec.belowLeftEdge(edge, other) then return true end
  end
  return false
end


function ec.belowDungeonEdge(edge, object)
  if edge.side == "up" then
    if object.y > edge.ystart then return false else return true end
  elseif edge.side == "left" then
    if object.x > edge.xstart then return false else return true end
  elseif edge.side == "down" then
    if object.y < edge.ystart then return false else return true end
  else
    if object.x < edge.xstart then return false else return true end
  end
end


return ec
