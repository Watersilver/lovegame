local GameObject = {}

-- We'll see... Probably for AI to make decisions before update
GameObject.sentient = nil
-- Can it move?
GameObject.mobile = nil
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


function GameObject:new()

  -- Object to be returned
  local NewObject = {}

  self.__newindex = function(table, key, value)
    -- Make sue the object can be accessed through its collision mask
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

function GameObject:instance()

  -- Make sure drawing layer exists, if not, create
  if not visibles[self.layer] then visibles[self.layer] = {} end

  -- Insert self in the correct layer of the table of visibles if appropriate
  if self.draw then table.insert(visibles[self.layer] ,self) end

  -- Insert self to appropriate tables
  for name, key in pairs(hypertable) do
    if self[name] then
      table.insert(key, self)
    end
  end

end


return GameObject
