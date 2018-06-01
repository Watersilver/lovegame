-- removes scaled sprite blurriness
love.graphics.setDefaultFilter("nearest")

-- tables that contain existing objects depending on their function
-- table of objects with AIs that can "sense" environments
sentients = {}
-- table of objects that can collide
collidables = {}
-- table of objects that check for collisions
colliders = {}
-- table of tables of objects to be drawn. Each of the tables signifies layer
visibles = {}
-- table of objects that update
updaters = {}
-- table of objects that update after collisions have been resolved
late_updaters = {}

-- number of layers
layers = 1

-- table that assigns properties of individual objects (e.g. late_update)
-- to the tables the correstond to (e.g. late_updaters)
-- *visibles is a table of tables so it's not here
hypertable = {
  sentient = sentients,
  mask = collidables,
  collide = colliders,
  update = updaters,
  late_update = late_updaters
}

-- Pushes thing on table as if table is stack
-- only use on tables that are sequences
local function push(table, thing)
  local new_index = #table + 1
  table[new_index] = thing
  return new_index
end

-- Removes from table at index == thing[keyname]
-- and gives its place to the last table element
local function remove(table, thing, key_name)
  -- ensure the thing is a table; store index for performance
  local index
  if type(thing) == 'table' then
    index = thing[key_name]
  end
  -- ensure index exists and that it's an index of table
  if index and table[index] then
    -- store the index of the last element of table
    local border = #table
    -- store the element to be removed from table
    local removed = table[index]
    -- swap places of the element to be removed with the last element
    -- (does nothing if they are the same)
    table[index] = table[border]
    -- update the key name of the swapped element
    table[index][key_name] = index
    -- delete last element
    table[border] = nil
  end
  -- if nil, the table or key name was invalid (or something else went wrong)
  return removed
end

-- Add an instance to the appropriate tables
function addToWorld(instance)
  -- if it has a sprite, add to visibles
  if instance.draw and not instance.visibles_index then
    layer = instance.layer or 1
    if not visibles[layer] then visibles[layer] = {} end
    instance.visibles_index = push(visibles[layer], instance)
  end
  -- if it has a mask, add to collidables
  if instance.mask and not instance.collidables_index then
    instance.collidables_index = push(collidables, instance)
  end
  -- if it has an update function, add to updaters
  if instance.update and not instance.updaters_index then
    instance.updaters_index = push(updaters, instance)
  end
end

-- Remove an instance from the appropriate tables
function removeFromWorld(instance)
  if type(instance) == 'table' then
    remove(visibles[instance.layer or 1], instance, 'visibles_index')
    remove(updaters, instance, 'updaters_index')
    remove(collidables, instance, 'collidables_index')
  end
end
