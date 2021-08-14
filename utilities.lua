local utf8 = require("utf8")

local u = {}

local random = love.math.random
local remove = table.remove
local sqrt = math.sqrt
local cos, sin = math.cos, math.sin
local atan2 = math.atan2

function u.emptyFunc()
end

function u.getFirstIndexByValue(arr, value)
  for i, v in ipairs(arr) do
    if value == v then return i end
  end
end

function u.tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function u.capitalise(s)
  return s:sub(1,1):upper()..s:sub(2)
end

-- A push operation that returns the new_index
function u.push(array, thing)
  local new_index = #array + 1
  array[new_index] = thing
  return new_index
end

-- Quickly free any position of the array if you don't care about its order
function u.free(array, index)
  array[index], array[#array] = array[#array], array[index]
  -- Teach the array's element its new index
  array[index][array.role] = index

  return remove(array)
end

-- Swap elements in one of the objects tables while teaching them their new indices
function u.swap(otable, index1, index2)
  local inin = otable[index1][otable.role]
  -- Swap
  otable[index1], otable[index2] = otable[index2], otable[index1]
  -- Teach
  otable[index1][otable.role], otable[index2][otable.role] =
  otable[index2][otable.role], otable[index1][otable.role]
end

function u.countIntDigits(num)
  return math.max(math.floor(math.log10(math.abs(num))), 0) + 1;
end

function u.clamp(low, n, high)
  return math.min(math.max(n, low), high)
end

function u.middle2d(x0, y0, x1, y1)
  return (x0 + x1)*0.5, (y0 + y1)*0.5
end

function u.gradualAdjust(dt, xcurrent, xtarget, as)
  -- adjustment speed can't be more than 30
  if math.abs(xcurrent - xtarget) < .0000000000000004 then return xtarget end
  as = as or 15
  if as > 30 then as = 30 end
  as = as * dt
  local dx = (xtarget - xcurrent)
  dx = dx * as
  return xcurrent + dx
end

function u.gradualAdjust2d(dt, xcurrent, ycurrent, xtarget, ytarget, as)
  return u.gradualAdjust(dt, xcurrent, xtarget, as), u.gradualAdjust(dt, ycurrent, ytarget, as)
end

function u.normalize2d(x, y)
  local invmagn = sqrt(x*x + y*y)
  invmagn = invmagn>0 and 1/invmagn or 1
  return x*invmagn, y*invmagn
end

function u.magnitude2d(x, y)
  return sqrt(x*x + y*y)
end

function u.distance2d(x1, y1, x2, y2)
  return u.magnitude2d(x2 - x1, y2 - y1)
end

function u.perpendicularRightTurn2d(x, y)
  return y, -x
end

function u.rotate2d(x, y, radAngle)
  local xrotated, yrotated
  xrotated = x * math.cos(radAngle) - y * math.sin(radAngle);
  yrotated = x * math.sin(radAngle) + y * math.cos(radAngle);
  return xrotated, yrotated;
end

function u.posFromSide(distanceKept, xdiff, ydiff, targetingSide)
  if targetingSide == "up" then
    return xdiff, ydiff - distanceKept, targetingSide
  elseif targetingSide == "down" then
    return xdiff, ydiff + distanceKept, targetingSide
  elseif targetingSide == "left" then
    return xdiff - distanceKept, ydiff, targetingSide
  elseif targetingSide == "right" then
    return xdiff + distanceKept, ydiff, targetingSide
  else
    return xdiff, ydiff, targetingSide
  end
end

function u.realToBinary(index, binArr)
  binArr = binArr or {true, false}
  if index > 0 then
    return binArr[1]
  else
    return binArr[2]
  end
end

function u.getClosePosAndSide(distanceKept, selfx, selfy, targetx, targety)
  local xdiff = targetx - selfx
  local ydiff = targety - selfy
  local targetingSide

  if math.abs(xdiff) > math.abs(ydiff) then
    targetingSide = u.realToBinary(xdiff, {"left", "right"})
  else
    targetingSide = u.realToBinary(ydiff, {"up", "down"})
  end

  return u.posFromSide(distanceKept, xdiff, ydiff, targetingSide)
end

function u.getPosAndSideInFrontOfMovingObj(distanceKept, selfx, selfy, targetx, targety, targetvx, targetvy)

  local targetingSide

  if math.abs(targetvx) > math.abs(targetvy) then
    targetingSide = u.realToBinary(targetvx, {"right", "left"})
  else
    targetingSide = u.realToBinary(targetvy, {"down", "up"})
  end

  local xdiff = targetx - selfx
  local ydiff = targety - selfy

  return u.posFromSide(distanceKept, xdiff, ydiff, targetingSide)
end

function u.projection2d(x, y, xdir, ydir)
  -- local projectionMagnitude = (x*xdir + y*ydir) / u.magnitude2d(xdir, ydir)
  -- local uvx, uvy = u.normalize2d(xdir, ydir)
  local uvx, uvy = u.normalize2d(xdir, ydir)
  local projectionMagnitude = (x*uvx + y*uvy)
  return projectionMagnitude * uvx, projectionMagnitude * uvy
end

function u.polarToCartesian(r, th)
  return r * cos( th ), r * sin( th ) -- x, y
end

function u.cartesianToPolar(x, y)
  return sqrt(x*x + y*y), atan2(y, x) -- r, th
end

function u.findSmallestArc(th, targetTh)
  -- th and targetTh belong to (-pi, pi]
  -- returns the sign that if added to th it will move towards targetTh

  if math.abs(targetTh - th) < math.pi then
    return u.sign(targetTh - th)
  else
    return -u.sign(targetTh - th)
  end
end

function u.distanceSqared2d(x0, y0, x1, y1)
  local xd, yd = x1-x0, y1-y0
  return xd * xd + yd * yd
end

function u.reflect(dx, dy, nx, ny)

  -- How to get reflected vector
  -- r=d−2(d*n)n
  -- (d*n) is dot product
  -- d is pre bounce, n is normal, r is reflected
  local dot = dx * nx + dy * ny
  return dx - 2 * dot * nx, dy - 2 * dot * ny

end

function u.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function u.choose(x, y, chanceToPickX)
  chanceToPickX = chanceToPickX or 0.5
  return random()<chanceToPickX and x or y
end

-- Remember unpack() function when I want to pass table as second arg
-- ... is keys to avoid
function u.chooseKeyFromTable(tbl, ...)
  local returnKey
  local seq = {}
  -- put table keys in sequence (skipping the keys to be avoided)
  for key in pairs(tbl) do
    local skip
    -- google "lua Variable Number of Arguments issue" to understand
    for i = 1, select("#",...) do
      local keyToAvoid = select(i,...)
      if key == keyToAvoid then skip = true end
    end
    if not skip then table.insert(seq, key) end
  end
  -- pick random key from sequence
  local choice = random(#seq)
  for i, value in ipairs(seq) do
    if choice == i then returnKey = seq[i] break end
  end
  return returnKey
end

-- Will work correctly only if sum of chances is <= 1
-- By design. Might be a stupid design
function u.chooseFromChanceTable(cTbl)
  local choiceNumber = random()
  for key, valChanceTbl in pairs(cTbl) do
    if choiceNumber < valChanceTbl.chance then return valChanceTbl.value end
    choiceNumber = choiceNumber - valChanceTbl.chance
  end
  return
end

function u.chooseFromWeightTable(wTbl)
  local totalWeight = 0
  for _, val in ipairs(wTbl) do
    totalWeight = totalWeight + val.weight
  end

  local choiceNumber = random() * totalWeight
  for _, val in ipairs(wTbl) do
    local chance = val.weight
    if choiceNumber < chance then return val.value end
    choiceNumber = choiceNumber - chance
  end
  return
end

function u.shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function u.getTriangleArea(ax, ay, bx, by, cx, cy)
  if type(ax) == "table" then
    ax, ay, bx, by, cx, cy =
    ax[1], ax[2], ax[3], ax[4], ax[5], ax[6]
  end
  return math.abs((ax * (by - cy) + bx * (cy - ay) + cx * (ay - by)) / 2)
end

function u.randomPointFromTriangle(triangle)
  local r1, r2 = love.math.random(), love.math.random();
  return (1 - sqrt(r1)) * triangle[1] + (sqrt(r1) * (1 - r2)) * triangle[3] + (sqrt(r1) * r2) * triangle[5],
         (1 - sqrt(r1)) * triangle[2] + (sqrt(r1) * (1 - r2)) * triangle[4] + (sqrt(r1) * r2) * triangle[6]
end

function u.randomPointFromTriangulatedPolygon(polygon)
  local triangle = u.chooseFromChanceTable(polygon)
  return u.randomPointFromTriangle(triangle)
end

-- Delete "chars" characters from the end of the string. UTF-8 friendly
function u.utf8_backspace(t, chars)
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(t, -chars)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        return string.sub(t, 1, byteoffset - 1)
    end
    return ""
end

-- Queue data structure
function u.newQueue(maxLength)
  return {
    first = 0,
    last = -1,
    length = 0,
    maxLength = maxLength,
    add = function (self, value)
      self.last = self.last + 1
      self[self.last] = value
      self.length = self.length + 1
      if self.maxLength and self.maxLength > 0 and self.length > self.maxLength then
        return self:remove()
      end
    end,
    remove = function (self)
      local first = self.first
      if first > self.last then error("queue is empty") end
      local value = self[first]
      self[first] = nil -- to allow garbage collection
      self.first = first + 1
      self.length = self.length - 1
      return value
    end,
    get = function (self, index)
      return self[self.first + index]
    end,
    getLast = function (self)
      return self[self.last]
    end
  }
end

local fastAccessQueueMethods = {
  add = function (self, value)
    local removedValue = self._queue:add(value)
    if removedValue and self._bag[removedValue] then
      self._bag[removedValue] = nil
    end
    self._bag[value] = true
  end,

  has = function (self, value)
    return self._bag[value]
  end
}
function u.newFastAccessQueue(capacity)
  return {
    _queue = u.newQueue(capacity),
    _bag = {},
    add = fastAccessQueueMethods.add,
    has = fastAccessQueueMethods.has
  }
end

-- Obliterate Body
function u.obliterateBody(body)
  for _, fixture in pairs(body:getFixtureList()) do
    fixture:setUserData(nil)
    fixture:destroy()
  end
  for _, joint in pairs(body:getJointList()) do
    joint:setUserData(nil)
    joint:destroy()
  end
  body:setUserData(nil)
  body:destroy()
end

function u.rememberFloorTile(self, other)
  if other.floor then
    -- old method
    -- other.playerFloorTilesIndex = push(self.floorTiles, other)
    u.push(self.floorTiles, other)
  end
end

function u.forgetFloorTile(self, other)
  if other.floor then
    -- old method
    -- u.free(self.floorTiles, other.playerFloorTilesIndex)
    -- other.playerFloorTilesIndex = nil
    if self.floorTiles then
      for i, floorTile in ipairs(self.floorTiles) do
        if other == floorTile then
          u.free(self.floorTiles, i)
          break
        end
      end
    end

  end
end

function u.isOutsideGamera(position, cam)
  local l,t,w,h = cam:getVisible()
  return (position.x + 8 < l) or (position.x - 8 > l + w)
  or (position.y + 8 < t) or (position.y - 8 > t + h)
end

function u.isOutsideRoom(position, room)
  return (position.x + 8 < 0) or (position.x - 8 > room.width)
  or (position.y < -8) or (position.y + (position.zo or 0) - 8 > room.height)
end

local coloursEnum = {
  white = {r = COLORCONST, g = COLORCONST, b = COLORCONST},
  red = {r = COLORCONST, g = 0, b = 0},
  black = {r = 0, g = 0, b = 0}
}
function u.changeColour(cTable)
  local colour = cTable.colour or cTable[1]
  local rgb = colour and coloursEnum[colour] or cTable
  love.graphics.setColor(rgb.r, rgb.g, rgb.b, cTable.a)
end

function u.getComplementaryColourList(cTable)
  local colour = cTable.colour or cTable[1]
  local rgb = colour and coloursEnum[colour] or cTable
  return {COLORCONST - rgb.r, COLORCONST - rgb.g, COLORCONST - rgb.b, cTable.a or COLORCONST}
end

function u.storeColour()
  local r, g, b, a = love.graphics.getColor()
  local prevColour = { r = r, g = g, b = b, a = a }
  return function() u.changeColour(prevColour) end
end

-- Create a list of triangles that cover the same area as the polygon you are given. If your polygon is convex it is easier, since you can have all triangles share a common vertex. If your polygons are not guaranteed to be convex, then you'll have to find a better polygon triangulation technique. Here's the relevant Wikipedia article. https://en.wikipedia.org/wiki/Polygon_triangulation
--
-- Randomly choose which triangle to use, weighted by its area. So if triangle A is 75% of the area and triangle B is 25% of the area, triangle A should be picked 75% of the time and B 25%. This means find the fraction of the total area that each triangle takes up, and store that in a list. Then generate a random double number from 0 - 1 (Math.random() does this), and subtract each value in the list until the next subtraction would make it negative. That will pick a triangle at random with the area weights considered.
--
-- Randomly pick a point within the chosen triangle. You can use this formula : sample random point in triangle.


-- you can generate a random point, P, uniformly from within triangle ABC by the following convex combination of the vertices:
--
-- P = (1 - sqrt(r1)) * A + (sqrt(r1) * (1 - r2)) * B + (sqrt(r1) * r2) * C
--
-- where r1 and r2 are uniformly drawn from [0, 1], and sqrt is the square root function.

return u
