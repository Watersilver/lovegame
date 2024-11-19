---@type ConversationData
local saveconvo = {
  id = 'saveconvo',
  participants = {'saver'},
  startNodeData = {id = 'ask'},
  options = {
    onInterrupt = function (_, _)
      return 'cancel'
    end
  },
  nodes = {
    {
      id = 'ask',
      text = '{ev:wake}Save game?',
      choices = {
        {id = 'yes', text = 'Yes', onChoose = {id = 'saved', events = {'save'}}},
        {id = 'no', text = 'No', onChoose = {id = 'cancel'}},
      },
      options = {
        staysOnScreen = true
      }
    },
    {
      id = 'saved',
      text = "Saved!"
    },
    {
      id = 'cancel',
      text = "{ev:sleep}...",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    }
  },
}

return saveconvo