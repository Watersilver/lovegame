---@type ConversationData
local test1convo = {
  id = 'test1convo',
  participants = {'test1convonpc', 'test2convonpc'},
  startNodeData = {id = 'greeting'},
  options = {
    onInterrupt = function (_, reason)
      return reason
    end
  },
  choices = {{
    id = 'bye',
    text = 'Goodbye',
    onChoose = {id = 'bye'}
  }},
  nodes = {
    {
      id = 'greeting',
      text = 'Hey there friend.',
      onEnd = {id = 'greeting2'},
      options = {
        proximityRequired = 'none',
        staysOnScreen = true
      }
    },
    {
      id = 'greeting2',
      text = 'Greeetings!',
      anchor = 'test2convonpc',
      onEnd = {id = 'pretalk'}
    },
    {
      id = 'pretalk',
      text = 'Got nothing to say?',
      choices = {{id = 'hi', text = 'Hello', onChoose = {id = 'talk'}}, 'bye'}
    },
    {
      id = 'bye',
      text = 'Bye bye!',
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'talk',
      text = 'So, conversations are now {ev:jump}{col:#0ff}easier{col:default} to{delay:0.5} {ev:twirl}{delay:0}write{delay:reset} and text can also change {col:#fac}colour{col:default}. They can also support multiple participants!',
      onEnd = {id = 'talk2'},
    },
    {
      id = 'talk2',
      text = 'Yeah, what he said.',
      anchor = 'test2convonpc',
    },
    {
      id = 'far-distance',
      text = "Where are you going??",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'wrong-facing',
      text = "You're looking at it all wrong ya know!",
      autoProgress = true,
      onEndDelay = 1,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'cancel-choice',
      text = "Strong silent type huh?",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    }
  },
}

return test1convo