local quests = {}

quests.testq = {
  title = "test quest",
  description = {
    stage1 = "Tis a quest"
  }
}

quests.testq2 = {
  title = "test quest 2",
  description = {
    stage1 = "Rejoice foo'"
  }
}

quests.mysticalSpells1 = {
  title = "Mystical Spells",
  description = {
    stage1 = "There are nine\n\zMystical Spells."
  }
}

quests.mainQuest1 = {
  title = GCON.shidun,
  description = {
    stage1 =
    GCON.npcNames.mage.. " the mage living\n\z
    northeast of "..GCON.lakeVillage.."\n\z
    may know how I\n\z
    ended up here."
  }
}

quests.mainQuest2 = {
  title = GCON.shidun,
  description = {
    stage1 =
    "There was no one but a\n\z
    skelleton in "..GCON.npcNames.mage.."'s\n\z
    lab..."
  }
}

quests.mainQuest3 = {
  title = GCON.shidun,
  description = {
    stage1 =
    GCON.npcNames.mage.." summoned me here\n\z
    so I can cast the 'Seal'\n\z
    in the Shrine of Secrets.\n\z
    I need the Nine Mystical\n\z
    Spells to do that."
  }
}

quests.chessPuzzle1 = {
  title = "Forest Chessboard",
  description = {
    stage1 =
    "A strange chessboard\n\z
    I encountered in the\n\z
    cursed forest:\n\z
    Small case is black\n\z
    Dot is empty square\n\z
    r = rook, b = bishop,\n\z
    h = knight, q = queen,\n\z
    k = king, p = pawn"
  }
}

quests.chessPuzzle2 = {
  title = "Forest Chessboard",
  description = {
    stage1 =
    "r . . q k . h r\n\z
    p p p . p p . p\n\z
    . . h . p . . p\n\z
    . . . . . . . .\n\z
    . . . . . . . .\n\z
    . P . . . . . .\n\z
    H P P P P P P P\n\z
    R . . . K B . R\n\z"
  }
}

return quests
