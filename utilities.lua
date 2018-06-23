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

return u
