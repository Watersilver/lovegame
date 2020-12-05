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
    "A mage living northeast\n\z
    of "..GCON.lakeVillage.." may know\n\z
    how I ended up here."
  }
}

quests.mainQuest2 = {
  title = GCON.shidun,
  description = {
    stage1 =
    "There was no one but a\n\z
    skelleton in the mage's\n\z
    lab...\n\zI think it was the mage."
  }
}

quests.mainQuest3 = {
  title = GCON.shidun,
  description = {
    stage1 =
    "The mage summoned me here\n\z
    so I can cast the 'Seal'\n\z
    in the Shrine of Secrets.\n\z
    I need the Nine Mystical\n\z
    Spells to do that."
  }
}

return quests
