local inv = require "inventory"

local asp = {}

function asp.insertToSpellSlot (self, spellName, spellKey)

  -- Check if spell already here
  for _, slot in  ipairs(inv.slots) do
    if slot.item == inv[spellName] then return end
  end

  -- Try to put the spell in the correct position
  if spellKey then
    if not inv.slots[spellKey].item then
      inv.slots[spellKey].item = inv[spellName]
      return -- Success!
    end
  end
  -- Try to put the spell in any position
  for i = #inv.slots, 1, -1 do -- Not using ipairs because I want to iterate in reverse
    if not inv.slots[i].item then
      inv.slots[i].item = inv[spellName]
      return -- Success!
    end
  end
  -- If I reach this point, I've failed
end

function asp.emptySpellSlots()
  for _, slot in ipairs(inv.slots) do
    slot.item = nil
  end
end

return asp
