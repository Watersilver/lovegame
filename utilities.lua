local utf8 = require("utf8")

local u = {}

local random = math.random
local remove = table.remove
local sqrt = math.sqrt

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

function u.clamp(low, n, high)
  return math.min(math.max(n, low), high)
end

function u.normalize2d(x, y)
  local invmagn = sqrt(x*x + y*y)
  invmagn = invmagn>0 and 1/invmagn or 1
  return x*invmagn, y*invmagn
end

function u.distanceSqared2d(x0, y0, x1, y1)
  local xd, yd = x1-x0, y1-y0
  return xd * xd + yd * yd
end

function u.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function u.choose(x, y)
  choice = random()
  return choice>0.5 and x or y
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

return u
