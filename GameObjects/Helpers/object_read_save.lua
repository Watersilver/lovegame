local ors = {}

ors.player = function (instance)
  instance.mobility = session.save.playerMobility or 300 -- 600
  instance.brakes = session.save.playerBrakes or 6
  instance.maxHealth = session.save.playerMaxHealth or 3
  instance.maxspeed = session.save.playerMaxSpeed or 100
  instance.walkOnWater = session.save.walkOnWater
  -- instance:insertToSpellSlot(session.save.hasSword, session.save.swordKey)
  -- instance:insertToSpellSlot(session.save.hasJump, session.save.jumpKey)
  -- instance:insertToSpellSlot(session.save.hasMissile, session.save.missileKey)
  -- instance:insertToSpellSlot(session.save.hasMark, session.save.markKey)
  -- instance:insertToSpellSlot(session.save.hasRecall, session.save.recallKey)
  -- instance:insertToSpellSlot(session.save.hasGrip, session.save.gripKey)

  --debug
  instance:insertToSpellSlot("sword", session.save.swordKey)
  instance:insertToSpellSlot("jump", session.save.jumpKey)
  instance:insertToSpellSlot("missile", session.save.missileKey)
  instance:insertToSpellSlot("mark", session.save.markKey)
  instance:insertToSpellSlot("recall", session.save.recallKey)
  instance:insertToSpellSlot("grip", session.save.gripKey)
end

return ors
