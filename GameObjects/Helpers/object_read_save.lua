local ors = {}

ors.player = function (instance)
  instance.mobility = session.save.playerMobility or 300 -- 600
  instance.brakes = session.save.playerBrakes or 3 -- 6
  instance.maxHealth = session.save.playerMaxHealth or 3
  instance.maxspeed = session.save.playerMaxSpeed or 100
  instance.walkOnWater = session.save.walkOnWater
end

return ors
