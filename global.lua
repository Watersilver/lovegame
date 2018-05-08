-- removes scaled sprite blurriness
love.graphics.setDefaultFilter("nearest")

-- tables that contain existing objects depending on their function
-- table of objects with AIs that can "sense" environments
sentients = {}
-- table of objects that can collide
colliders = {}
-- table of objects that check for collisions
collision_checkers = {}
-- table of tables of objects to be drawn. Each of the tables signifies layer
visibles = {}
-- table of objects that update
updaters = {}
-- table of objects that update after collisions have been resolved
late_updaters = {}

-- number of layers
layers = 3

-- table that assigns properties of individual objects (e.g. late_update)
-- to the tables the correstond to (e.g. late_updaters)
-- *visibles is a table of tables so it's not here
hypertable = {
  sentient = sentients,
  collider = colliders,
  collision_check = collision_checkers,
  update = updaters,
  late_update = late_updaters
}
