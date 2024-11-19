local utf8 = require("utf8")

local u = {}

local random = love.math.random
local remove = table.remove
local sqrt = math.sqrt
local cos, sin = math.cos, math.sin
local atan2 = math.atan2
local abs = math.abs

function u.emptyFunc()
end

-- initializes table t with values from init
function u.initializeTable(t, init)
  for key, v in pairs(init) do
    if t[key] == nil then t[key] = v end
  end
  return t
end

-- Round to closest int
function u.round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- linear interpolation
function u.lerp(a, b, t)
  return a + (b - a) * t
end

-- Returns a value for undefined values
-- such as 0 / 0 or x / 0 etc.
function u.defineUndefined(val, fallback)
  if val ~= val or val == math.huge or val == -math.huge then return fallback end
  return val
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
  if math.abs(xcurrent - xtarget) < .0000000000000004 then return xtarget end
  as = as or 15
  -- adjustment speed can't be more than 30
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

---@param r any
---@param th any
---@return number
---@return number
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

---@alias ChanceTable {chance: number, value: any}[]

---Will work correctly only if sum of chances is <= 1
---By design. Might be a stupid design
---@param cTbl ChanceTable
function u.chooseFromChanceTable(cTbl)
  local choiceNumber = random()
  for _, valChanceTbl in pairs(cTbl) do
    if choiceNumber < valChanceTbl.chance then return valChanceTbl.value end
    choiceNumber = choiceNumber - valChanceTbl.chance
  end
  return nil
end

---@alias WeightTable {weight: number, value: any}[]

---@param wTbl WeightTable
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
end

---@param wTbl WeightTable
function u.weightTableToChanceTable(wTbl)
  local totalWeight = 0
  for _, v in ipairs(wTbl) do
    totalWeight = totalWeight + v.weight
  end

  ---@type ChanceTable
  local cTbl = {}
  for _, v in ipairs(wTbl) do
    table.insert(cTbl, {value = v.value, chance = v.weight / totalWeight})
  end
  return cTbl
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

function u.randomPointFromEllipse(width, height, perimeter)
  -- if not give height, this is a circle
  if type(height) ~= "number" then
    perimeter = height
    height = width
  end
  if perimeter then
    local phi = math.random() * math.pi * 2
    return 1 * cos(phi) * width * .5,
           1 * sin(phi) * height * .5
  else
    local rho, phi = love.math.random(), math.random() * math.pi * 2
    return sqrt(rho) * cos(phi) * width * .5,
           sqrt(rho) * sin(phi) * height * .5
  end
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

function u.findIndex(list, value, predicate)
  if predicate then
    for i, v in pairs(list) do
      if predicate(v) then return i end
    end
  else
    for i, v in pairs(list) do
      if v == value then return i end
    end
  end
  return nil
end

-- Splits a given string
function u.split(str, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( str, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( str, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( str, delimiter, from  )
  end
  table.insert( result, string.sub( str, from  ) )
  return result
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
      return self[self.first + (index % self.length)]
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
---@param body love.Body
function u.obliterateBody(body)
  for _, fixture in pairs(body:getFixtures()) do
    fixture:setUserData(nil)
    fixture:destroy()
    -- fixture:release()
  end
  for _, joint in pairs(body:getJoints()) do
    joint:setUserData(nil)
    joint:destroy()
    -- joint:release()
  end
  body:setUserData(nil)
  body:destroy()
  -- body:release()
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
  white = {r = 1, g = 1, b = 1},
  red = {r = 1, g = 0, b = 0},
  black = {r = 0, g = 0, b = 0}
}

---@param cTable {r: number, g: number, b: number, a: number}|{[1]: 'white'|'black'|'red'}|{colour: 'white'|'black'|'red'}
function u.changeColour(cTable)
  local colour = cTable.colour or cTable[1]
  local rgb = colour and coloursEnum[colour] or cTable
  love.graphics.setColor(rgb.r, rgb.g, rgb.b, cTable.a)
end

function u.getComplementaryColourList(cTable)
  local colour = cTable.colour or cTable[1]
  local rgb = colour and coloursEnum[colour] or cTable
  return {1 - rgb.r, 1 - rgb.g, 1 - rgb.b, cTable.a or 1}
end

function u.storeColour()
  local r, g, b, a = love.graphics.getColor()
  local prevColour = { r = r, g = g, b = b, a = a }
  return function() u.changeColour(prevColour) end
end

function u.get_line_count(str)
  local lines = 1
  for i = 1, #str do
      local c = str:sub(i, i)
      if c == '\n' then lines = lines + 1 end
  end

  return lines
end

local mt = {
  __newindex = function(t, k, v)
    if k == "t" and type(v) == "number" then
      v = u.clamp(0, t, 1)
    end
    t[k] = v
  end
}
function u.colorTable(r,g,b,a)
  local start = {r,g,b,a}
  local target = {r,g,b,a}
  local getVal = function(i, t)
    t = u.clamp(0, t, 1)
    return u.lerp(start[i], target[i] - start[i], t)
  end
  local t = {
    -- values between 0 and 1 (forced via metatable)
    t = 1,
    setTarget = function (self, rc,gc,bc,ac)
      start[1] = self:getRed()
      start[2] = self:getGreen()
      start[3] = self:getBlue()
      start[4] = self:getAlpha()
      self.t = 0
      target[1] = rc
      target[2] = gc
      target[3] = bc
      target[4] = ac
    end,
    set = function (self, rc,gc,bc,ac)
      self:setTarget(rc,gc,bc,ac)
      self.t = 1
    end,
    getRed = function (self) return getVal(1, self.t) end,
    getGreen = function (self) return getVal(2, self.t) end,
    getBlue = function (self) return getVal(3, self.t) end,
    getAlpha = function (self) return getVal(4, self.t) end,
    getTable = function (self)
      return {
        self:getRed(),
        self:getGreen(),
        self:getBlue(),
        self:getAlpha()
      }
    end
  }
  setmetatable(t, mt)
  return t
end

local function printPropsRecursive(obj, path, maxDepth, printed, tab)
  path = path or "root"
  printed = printed or {}
  tab = tab or ""
  printed[path] = obj

  if type(obj) ~= "table" then
    printPropsRecursive({[path] = obj})
    return
  end

  for key, value in pairs(obj) do
    local tv = type(value)
    if tv == "function" or tv == "thread" or tv == "userdata" then
      print(tab .. key .. ": unprintable type '" .. tv .. "'")
    elseif tv == "table" then
      local alreadyPrintedPath = ""

      for n, o in pairs(printed) do
        if o == value then
          alreadyPrintedPath = n
          break
        end
      end

      if alreadyPrintedPath ~= "" then
        print(tab .. key .. ": table already printed at path '" .. alreadyPrintedPath .. "'")
      elseif maxDepth and maxDepth == 0 then
        print(tab .. key .. ": table")
      else
        print(tab .. key .. ":")
        printPropsRecursive(value, path .. "." .. key, maxDepth - 1, printed, tab .. " ")
      end
    elseif tv == "string" then
      print(tab .. key .. ': "' .. value .. '"')
    elseif tv == "boolean" then
      print(tab .. key .. ': ' .. (value and "true" or "false"))
    elseif tv == "nil" then
      print(tab .. key .. ': nil')
    else
      print(tab .. key .. ': ' .. value)
    end
  end
end
---@param id string
---@param obj table
---@param maxDepth number
function u.printTable(id, obj, maxDepth)
  print("=== Start printing table " .. id .. "===")
  printPropsRecursive(obj, id, maxDepth)
  print("=== Finish printing table " .. id .. "===")
end

-- condition and v1 or v2 doesn't work for falsy values. Use this func instead.
function u.ternaryOp(condition, valIfTrue, valIfFalse)
  if condition then return valIfTrue else return valIfFalse end
end

---@param a number
---@param b number
---@param progress number
---@return number
function u.lerp2(a, b, progress)
  if b > a then
    local diff = b - a
    return a + diff * progress
  else
    local diff = a - b
    return a - diff * progress
  end
end

--- Lerps color a to color b (except a which doesn't need to be provided but is returned as forth value = 1)
---@param a {r: number[], g: number[], b: number[]}
---@param b {r: number[], g: number[], b: number[]}
---@param t number
---@return {r: number[], g: number[], b: number[]}
function u.rgbLerp(a, b, t)
  return {
    r = {
      u.lerp2(a.r[1], b.r[1], t),
      u.lerp2(a.r[2], b.r[2], t),
      u.lerp2(a.r[3], b.r[3], t),
      1
    },
    g = {
      u.lerp2(a.g[1], b.g[1], t),
      u.lerp2(a.g[2], b.g[2], t),
      u.lerp2(a.g[3], b.g[3], t),
      1
    },
    b = {
      u.lerp2(a.b[1], b.b[1], t),
      u.lerp2(a.b[2], b.b[2], t),
      u.lerp2(a.b[3], b.b[3], t),
      1
    }
  }
end

-- Converts an RGB color value to HSL. Conversion formula
-- adapted from http://en.wikipedia.org/wiki/HSL_color_space.
-- Assumes r, g, and b are contained in the set [0, 1] and
-- returns h, s, and l in the set [0, 1].
--
---@param r number The red color value
---@param g number The green color value
---@param b number The blue color value
---@return number h
---@return number s
---@return number l
function u.rgbToHsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local mid = (max + min) / 2
  local h, s, l = mid, mid, mid

  if max == min then
    -- achromatic
    h, s = 0, 0
  else
    local d = max - min;
    s = (l > 0.5) and (d / (2 - max - min)) or (d / (max + min))

    if max == r then
      h = (g - b) / d + ((g < b) and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    else
      h = h / 6
    end
  end

  return h, s, l;
end

local function hue2rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

-- Converts an HSL color value to RGB. Conversion formula
-- adapted from http://en.wikipedia.org/wiki/HSL_color_space.
-- Assumes h, s, and l are contained in the set [0, 1] and
-- returns r, g, and b in the set [0, 1].
--
---@param h number The hue
---@param s number The saturation
---@param l number The lightness
---@return number r
---@return number g
---@return number b
function u.hslToRgb(h, s, l)
  ---@type number, number, number
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s;
    local p = 2 * l - q;
    r = hue2rgb(p, q, h + 1/3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1/3);
  end

  return r, g, b;
end

---@param str string
---@param ending string
---@return boolean
function u.ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function u.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

local function deep_copy(t, copied)
  local t2 = {}
  for k,v in pairs(t) do
    if type(v) == "table" and not copied[v] then
      copied[v] = true
      t2[k] = deep_copy(v, copied)
    else
      t2[k] = v
    end
  end
  return t2
end

function u.deep_copy(t)
  return deep_copy(t, {})
end

-- split functions found here: http://lua-users.org/wiki/SplitJoin

--- Patterns work as outlined here: https://www.lua.org/manual/5.2/manual.html 6.4.1 – Patterns
---@param str string
---@param tokens string[]
---@param max? number
---@return string[]
function u.splitTokens(str, tokens, max)
  for i,t in ipairs(tokens) do
    tokens[i] = '^.-()' .. t
  end

  -- Now the actual loop to split the first string parameter
  local t, n, p = {}, 1, 1
  while n ~= max do
    -- locate the nearest subpatterns that match a separator in str:sub(p);
    -- if two subpatterns match at same nearest position, keep the longest one
    local first, last = nil, nil
    for _, token in ipairs(tokens) do
      local q, r, s = str:find(token, p)
      if q then
        -- A possible token (not necessarily the neareast) was found in str:sub(s, r)
        -- Here: q~=nil, r~=nil, s~=nil, q==p <= s <= r)
        if not first or s < first then
          first, last = s, r -- this also overrides any longer pattern, but located later
        elseif r > last then
          last = r -- prefer the longest pattern at the same position
        end
      end
    end
    if not first then break end
    -- The nearest token (with the longest length) was found in str:sub(first, last).
    -- Store the non-token part (possibly empty) at odd position, and the token at the next even position
    t[n], t[n + 1], n, p = str:sub(p, first - 1), str:sub(first, last), n + 2, last + 1
  end
  t[n] = str:sub(p) -- Store the last non-token (possibly empty) at odd position
  return t
end

---@param image_index number
---@param num_frames number
---@param alpha_table {[number]: number, first?: number, last?: number, relative?: {[number]: number}}
---@param onPreviousRoom boolean | nil
---@param transitioning nil | {progress: number}
---@return number
function u.compute_alpha_from_table(image_index, num_frames, alpha_table, onPreviousRoom, transitioning)
  local min = {val = alpha_table.first or 0, frame = -1}
  local max = {val = alpha_table.last or 0, frame = num_frames}
  for k, v in pairs(alpha_table) do
    if type(k) == 'number' then
      if k <= image_index and k >= min.frame then
        min.val = v
        min.frame = k
      elseif k > image_index and k <= max.frame then
        max.val = v
        max.frame = k
      end
    end
  end
  if alpha_table.relative then
    for k, v in pairs(alpha_table.relative) do
      k = k * (num_frames - 1)
      if k <= image_index and k >= min.frame then
        min.val = v
        min.frame = k
      elseif k > image_index and k <= max.frame then
        max.val = v
        max.frame = k
      end
    end
  end
  local x = image_index - min.frame
  local y = max.frame - min.frame
  local a = u.lerp(min.val, max.val, x / y)

  if transitioning then
    if onPreviousRoom then
      a = a * (1 - transitioning.progress)
    else
      a = a * transitioning.progress
    end
  end

  return a
end

---@param n number
---@return number
u.getDecimal = function(n)
  return abs(n)%1
end

return u
