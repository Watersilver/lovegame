local fsc = {}

-- Find which fixture belongs to whom
function fsc.determine_colliders(self, aob, bob, a, b)
  local myF
  local otherF
  local other
  if self == aob then
    myF = a
    otherF = b
    other = bob
  else
    myF = b
    otherF = a
    other = aob
  end
  return other, myF, otherF
end

return fsc
