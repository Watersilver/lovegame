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

function u.normalize2d(x, y)
  local invmagn = sqrt(x*x + y*y)
  invmagn = invmagn>0 and 1/invmagn or 1
  return x*invmagn, y*invmagn
end

function u.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function u.choose(x, y)
  choice = random()
  return choice>0.5 and x or y
end

return u
