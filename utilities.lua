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

function u.projection2d(x, y, xdir, ydir)
  -- local projectionMagnitude = (x*xdir + y*ydir) / u.magnitude2d(xdir, ydir)
  -- local uvx, uvy = u.normalize2d(xdir, ydir)
  local uvx, uvy = u.normalize2d(xdir, ydir)
  local projectionMagnitude = (x*uvx + y*uvy)
  return projectionMagnitude * uvx, projectionMagnitude * uvy
end

function u.polarToCartesian(r, th)
  return r * cos( th ), r * sin( th )
end

function u.cartesianToPolar(x, y)
  return sqrt(x*x + y*y), atan2(y, x)
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
function u.newQueue()
  return {
    first = 0,
    last = -1,
    length = 0,
    add = function (self, value)
      self.last = self.last + 1
      self[self.last] = value
      self.length = self.length + 1
    end,
    remove = function (self)
      local first = self.first
      if first > self.last then error("queue is empty") end
      local value = self[first]
      self[first] = nil        -- to allow garbage collection
      self.first = first + 1
      self.length = self.length - 1
      return value
    end
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

return u
