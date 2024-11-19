---@type ConversationData
local mage_lab_note_convo = {
  id = 'mage_lab_note_convo',
  participants = {'mage_lab_note'},
  startNodeData = {id = 'dlg'},
  options = {
    onInterrupt = function (_, reason)
      return reason
    end
  },
  nodes = {
    {
      id = 'dlg',
      text = "Finally I created the summoning spell. \z
        It will summon the courageous one from the other world. "..GCON.heroWorld..". \z
        My despair has forced me to resort to abduction but it is the only way. \z
        The outworlder must cast the Seal in the Shrine of Secrets {q:mainQuest3}lest the empire consume all. \z
        However one must have the power of the nine Mystical Spells {q:mysticalSpells1}to cast the Seal. \z
        Most are bound deep in the ancient dungeons of "..GCON.shidun..". One I have here. \z
        I will take the outworlder to the other spells. We must not fail.",
      options = {
        staysOnScreen = true
      }
    },
    {
      id = 'far-distance',
      text = "...",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'wrong-facing',
      text = "...",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'cancel-choice',
      text = "...",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    }
  },
}

return mage_lab_note_convo