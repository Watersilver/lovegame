local tch = {}

function tch.playerDieDrownPlummet(instance, trig, myside, dt)
  if trig.noHealth then
    instance.animation_state:change_state(instance, dt, "downdie")
    return true
  elseif instance.overGap then
    instance.animation_state:change_state(instance, dt, "plummet")
    return true
  elseif instance.inDeepWater then
    instance.animation_state:change_state(instance, dt, "downdrown")
    return true
  elseif trig.damaged then
    if not myside then myside = "down" end
    instance.animation_state:change_state(instance, dt, myside .. "damaged")
    return true
  end
  return false
end

return tch
