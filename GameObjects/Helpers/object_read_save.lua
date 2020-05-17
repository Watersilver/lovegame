local ors = {}

ors.player = function (instance)
  instance.maxHealth =
    (session.save.playerMaxHealth or 3) +
    math.floor((session.save.piecesOfHeart or 0) / 4)
  instance.health = session.save.playerHealth or instance.maxHealth or 3
  instance:insertToSpellSlot(session.save.hasSword, session.save.swordKey)
  instance:insertToSpellSlot(session.save.hasJump, session.save.jumpKey)
  instance:insertToSpellSlot(session.save.hasMissile, session.save.missileKey)
  instance:insertToSpellSlot(session.save.hasMark, session.save.markKey)
  instance:insertToSpellSlot(session.save.hasRecall, session.save.recallKey)
  instance:insertToSpellSlot(session.save.hasGrip, session.save.gripKey)
  instance:insertToSpellSlot(session.save.hasBomb, session.save.bombKey)

  --debug
  -- instance:insertToSpellSlot("sword", session.save.swordKey)
  -- instance:insertToSpellSlot("jump", session.save.jumpKey)
  -- instance:insertToSpellSlot("missile", session.save.missileKey)
  -- instance:insertToSpellSlot("mark", session.save.markKey)
  -- instance:insertToSpellSlot("recall", session.save.recallKey)
  -- instance:insertToSpellSlot("grip", session.save.gripKey)
end

return ors
