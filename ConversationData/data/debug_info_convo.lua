---@type ConversationData
local debugconvo = {
  id = 'debugconvo',
  participants = {'debug_info'},
  startNodeData = {id = 'greeting'},
  options = {
    onInterrupt = function (_, reason)
      return reason
    end
  },
  choices = {
    {
      id = 'howto_firstboss',
      text = 'How to fight the puppet boss?',
      onChoose = {id = 'firstboss_desc'},
    },
    {
      id = 'howto_secondboss',
      text = 'How to fight the giant boss?',
      onChoose = {id = 'secondboss_desc'},
    },
    {
      id = 'howto_thirdboss',
      text = 'How to fight the dragon boss?',
      onChoose = {id = 'thirdboss_desc'},
    },
    {
      id = 'howto_fourthboss',
      text = 'How to fight the knight boss?',
      onChoose = {id = 'fourthboss_desc'},
    },
    {
      id = 'howto_fifthboss',
      text = 'How to fight the incomplete boss?',
      onChoose = {id = 'fifthboss_desc'},
    },
    {
      id = 'bye',
      text = 'Bye',
      onChoose = {id = 'bye'},
    },
  },
  nodes = {
    {
      id = 'greeting',
      text = 'Here for gossip?',
      choices = {'howto_firstboss', 'howto_secondboss', 'howto_thirdboss', 'howto_fourthboss', 'howto_fifthboss', 'bye'}
    },
    {
      id = 'firstboss_desc',
      text = 'You need to grab the little totems and throw them to the boss to win.',
      onEnd = {id = 'anything_else'}
    },
    {
      id = 'secondboss_desc',
      text = 'Avoid the bullets and shoot the eyes with missiles. Focus on one at a time or the remaining one will be powered up when you destroy one. Then cut the hands.',
      onEnd = {id = 'anything_else'}
    },
    {
      id = 'thirdboss_desc',
      text = 'Throw bombs at it.',
      onEnd = {id = 'anything_else'}
    },
    {
      id = 'fourthboss_desc',
      text = 'Find a chance to grab the ball away from it and then release it to smash the shield. Then attack with everything you have.',
      onEnd = {id = 'anything_else'}
    },
    {
      id = 'fifthboss_desc',
      text = 'TODO',
      onEnd = {id = 'anything_else'}
    },
    {
      id = 'anything_else',
      text = 'Anything else?',
      choices = {'howto_firstboss', 'howto_secondboss', 'howto_thirdboss', 'howto_fourthboss', 'howto_fifthboss', 'bye'}
    },
    {
      id = 'bye',
      text = 'You too!',
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'far-distance',
      text = "You're too far away!{delay:0.3} {delay:-1}I don't want to have to shout.{delay:0.3} {delay:-1}Come closer if you want to talk.",
      autoProgress = true,
      options = {
        uninterruptible = true,
        delay = 0.03
      }
    },
    {
      id = 'wrong-facing',
      text = "...",
      autoProgress = true,
      onEndDelay = 1,
      options = {
        uninterruptible = true
      }
    },
    {
      id = 'cancel-choice',
      text = "Bye then!",
      autoProgress = true,
      options = {
        uninterruptible = true
      }
    }
  },
}

return debugconvo