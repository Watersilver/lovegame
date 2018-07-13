local u = require "utilities"

local o = {}

o.identified = {} -- These can be referred to by name
o.updaters = {role = "updater"} -- List of object with update functions
o.colliders = {role = "collider"} -- List of objects that can collide
o.persistents = {role = "persistent"} -- List of objects that survive room trans
o.draw_layers = {} -- List of layers(Lists of objects to be drawn)

-- Table to hold objects pending to be deleted from the world
o.to_be_deleted = {}
-- Function to delete them
function o.to_be_deleted:remove_all()
  if not self[1] then return end
  for _, object in ipairs(self) do
    if object.body then object.body:destroy() end
    if object.updater then
      u.free(o.updaters, object.updater)
      object.updater = nil
    end
    if object.collider then
      u.free(o.colliders, object.collider)
      object.collider = nil
    end
    if object.drawable then
      u.free(o.draw_layers[object.layer], object.drawable)
      object.drawable = nil
    end
    if object.identifiable then
      -- Free for ALL ids
      for id, index_in_identified_table in pairs(object.identifiable) do
        -- Can't use free function, because "identifiable" is more than a number
        local array, index = o.identified[id], index_in_identified_table
        array[index], array[#array] = array[#array], array[index]
        -- Teach the array's element its new index
        array[index].identifiable[id] = index
        table.remove(array)
        if #array == 0 then o.identified[id] = nil end
      end
      object.identifiable = nil
    end
    if object.sprite_info then object:unload_sprites() end
    if object.delete and not object.persistent then object:delete() end
    if object.imdying then object.imdying = nil end
  end
  o.to_be_deleted = {remove_all = o.to_be_deleted.remove_all}
end
-- Adds object to to_be_deleted table, ensuring it happens only once
function o.removeFromWorld(object)
  if not object then return end
  if not object.imdying then object.imdying = u.push(o.to_be_deleted, object) end
end

-- Table to hold objects pending to be added to the world
o.to_be_added = {}
-- Function to add them
function o.to_be_added:add_all()
  for _, object in ipairs(self) do
    -- Add to persistents if persistent and if not already there
    if object.persistent and not type(object.persistent) == "number" then
      object[o.persistents.role] = u.push(o.persistents, object)
    end
    -- Add to identified if has id and if not already there
    if object.ids[1] and not object.identifiable then
      -- Prepare table, it will be indexed
      object.identifiable = {}
      -- Put in identified for every id
      for _, id in ipairs(object.ids) do
        if not o.identified[id] then o.identified[id] = {role = "identifiable"} end
        object.identifiable[id] = u.push(o.identified[id], object)
      end
    end
    -- Add to colliders if has physical_properties and if not already there
    if object.physical_properties and not object.collider then
      object:build_body()
      if object.body then object[o.colliders.role] = u.push(o.colliders, object) end
    end
    -- Load sprites and build spritefixture if applicable
    if object.sprite_info then
      object:load_sprites()
      if object.sprite_info.spritefixture_properties then
        object:build_spritefixture()
      end
    end
    -- Add to updaters if updater and if not already there
    if object.update and not object.updater then
      object[o.updaters.role] = u.push(o.updaters, object)
    end
    -- Add to objects that will be drawn if not already there
    if object.draw and not object.drawable then
      -- Make sure it has a layer
      if not object.layer then object.layer = 1 end
      local layer = object.layer
      -- ensure important drawing stuff won't be nil if object is visible
      if not object.image_index then object.image_index = 0 end
      if not object.image_speed then object.image_speed = 1 end
      -- Check if all layers up to this one exist, if not, make them
      for i=1, layer do
        if not o.draw_layers[i] then o.draw_layers[i] = {role = "drawable"} end
      end
      -- Add it to the appropriate layer in the draw_layers table
      object[o.draw_layers[layer].role] = u.push(o.draw_layers[layer], object)
    end
    -- Run its load function if existent
    if object.load then object:load(); object.load = nil end
    if object.gettingAdded then object.gettingAdded = nil end
  end
  -- Clear the table; everything has been added
  o.to_be_added = {add_all = o.to_be_added.add_all}
end
-- Adds object to to_be_added table, ensuring it happens only once
function o.addToWorld(object)
  if not object then return end
  if not object.gettingAdded then object.gettingAdded = u.push(o.to_be_added, object) end
end

return o