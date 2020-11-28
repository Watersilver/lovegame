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

quests.main = {
  title = GCON.shidun,
  description = {
    stage1 = "A mage northeast of "..GCON.lakeVillage.."\n\z
    may know how I ended\nup here."
  }
}

return quests
