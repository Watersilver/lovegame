local u = {}

-- A push operation that returns the new_index
function u.push(table, thing)
  local new_index = #table + 1
  table[new_index] = thing
  return new_index
end

-- Quickly free any position of the table if you don't care about its order
function u.free(table, index)
  table[index], table[#table] = table[#table], table[index]
  -- Teach the table's element its new index
  table[index][table.role] = index

  return table.remove(table)
end

-- Swap elements in one of the objects tables while teaching them their new indices
function u.swap(table, index1, index2)
  local inin = table[index1][table.role]
  -- Swap
  table[index1], table[index2] = table[index2], table[index1]
  -- Teach
  table[index1][table.role], table[index2][table.role] =
  table[index2][table.role], table[index1][table.role]
end

function u.normalize2d(x, y)
  local invmagn = math.sqrt(x*x + y*y)
  invmagn = invmagn>0 and 1/invmagn or 1
  return x*invmagn, y*invmagn
end

function u.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

return u
