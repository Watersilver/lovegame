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

-- Add an instance to the appropriate tables
function addToWorld(instance)
  -- if it has a sprite, add to visibles
  if instance.sprite then
    layer = instance.layer or 1
    if not visibles[layer] then visibles[layer] = {} end
    table.insert(visibles[layer], instance)
  end
  -- if it has a mask, add to collidables
  if instance.mask then table.insert(collidables, instance) end
end
