local GameObject = {}

-- We'll see... Probably for AI to make decisions before update
GameObject.sentient = nil
-- Can it collide?
GameObject.collider = nil
-- Will it check for collisions?
GameObject.collision_check = nil
-- Will it get drawn?
GameObject.draw = nil
-- Will it get drawn?
GameObject.layer = 1
-- Will it update?
GameObject.update = nil
-- Will it late update?
GameObject.late_update = nil

-- Position
GameObject.position = {x = 0, y = 0}

function GameObject:new(initial_values)

  -- Object to be returned
  local NewObject = type(initial_values) == "table" and initial_values or {}

  self.__newindex = function(table, key, value)
    -- Make sure the object can be accessed through its collision mask
    if key == "Mask" then
      if type(value) == "table" then
        value.gameObject = table
      end
    end

    -- Set table[key] = value without invoking metamethod
    rawset(table, key, value)
  end

  self.__index = self

  setmetatable(NewObject, self)

  return NewObject

end

-- Add a gameObject to the world
function GameObject:instantiate()

  -- Make sure drawing layer exists, if not, create
  if not visibles[self.layer] then visibles[self.layer] = {} end

  -- Insert self in the correct layer of the table of visibles if appropriate
  if self.draw then table.insert(visibles[self.layer], self) end

  -- Insert self to appropriate tables
  for name, key in pairs(hypertable) do
    if self[name] then
      table.insert(key, self)
    end
  end

end


return GameObject
