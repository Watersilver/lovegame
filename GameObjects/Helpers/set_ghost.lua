local sg = {}

function sg.setGhost (instance, ghostStatus)
  instance.ghost = ghostStatus
  if ghostStatus then
    instance.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
  else
    instance.fixture:setMask(instance.currentMasks or {})
    instance.fixture:setMask(SPRITECAT, instance.fixture:getMask())
  end
end

return sg
