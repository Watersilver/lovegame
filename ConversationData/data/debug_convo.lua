local u = require 'utilities'

---@param convo ConversationObject
local function popPrevNodeId(convo)
  local c = convo:getNodeIdHistory()
  local prev = c[#c-1]
  table.remove(c)
  table.remove(c)
  return prev
end

---@type ConversationData
local debugconvo = {
  id = 'debugconvo',
  participants = {'debug'},
  startNodeData = {id = 'start'},
  options = {
    onInterrupt = function (convo, reason)
      local c = convo:getNodeIdHistory()
      if reason == 'cancel-choice' and c[#c] ~= 'start' then
        return popPrevNodeId(convo)
      end
      return reason
    end
  },
  nodes = {
    {
      id = 'start',
      text = 'What?',
      options = {
        proximityRequired = 'none',
        staysOnScreen = true
      },
      choices = {
        {
          id = 'goto_firstboss',
          text = 'Take me to the puppet boss',
          onChoose = {id = 'levelchoice'},
          events = {'bosschoice:1'}
        },
        {
          id = 'goto_secondboss',
          text = 'Take me to the undead giant king boss',
          onChoose = {id = 'levelchoice'},
          events = {'bosschoice:2'}
        },
        {
          id = 'goto_thirdboss',
          text = 'Take me to the dragon boss',
          onChoose = {id = 'levelchoice'},
          events = {'bosschoice:3'}
        },
        {
          id = 'goto_fourthboss',
          text = 'Take me to the knight boss',
          onChoose = {id = 'levelchoice'},
          events = {'bosschoice:4'}
        },
        -- TODO: I fucked up by adding this events field as there already was an events field inside the onChoose field. Fix
        {
          id = 'goto_fifthboss',
          text = 'Take me to the incomplete boss',
          onChoose = {id = 'levelchoice'},
          events = {'bosschoice:5'}
        },
        {
          id = 'goto_sidescroll',
          text = "Take me to the Sidescroller testing area",
          onChoose = {events = {'goto_sidescroll'}}
        },
        {
          id = 'abilities',
          text = 'I want to change abilities',
          onChoose = {id = 'abilitychoice'}
        },
      }
    },
    {
      id = 'firstboss_desc',
      text = 'You need to grab the little totems and throw them to the boss to win.',
      onEnd = {id = 'levelchoice'}
    },
    {
      id = 'secondboss_desc',
      text = 'Avoid the bullets and shoot the eyes with missiles. Focus on one at a time or the remaining one will be powered up when you destroy one. Then cut the hands.',
      onEnd = {id = 'levelchoice'}
    },
    {
      id = 'thirdboss_desc',
      text = 'Throw bombs at it.',
      onEnd = {id = 'levelchoice'}
    },
    {
      id = 'fourthboss_desc',
      text = 'Find a chance to grab the ball away from it and then release it to smash the shield. Then attack with everything you have.',
      onEnd = {id = 'levelchoice'}
    },
    {
      id = 'fifthboss_desc',
      text = 'TODO',
      onEnd = {id = 'levelchoice'}
    },
    {
      id = 'levelchoice',
      text = 'Your equipment level',
      choices = {
        {id = 'minimal', text = 'Minimal', onChoose = {id = 'bye'}, events = {'lvlchoice:minimal'}},
        {id = 'decent', text = 'Decent', onChoose = {id = 'bye'}, events = {'lvlchoice:decent'}},
        {id = 'prepared', text = 'Prepared', onChoose = {id = 'bye'}, events = {'lvlchoice:prepared'}},
        {id = 'decked_out', text = 'Decked out', onChoose = {id = 'bye'}, events = {'lvlchoice:decked_out'}},
        {id = 'skip', text = 'Keep current', onChoose = {id = 'bye'}, events = {'lvlchoice:skip'}}
      }
    },
    {
      id = 'abilitychoice',
      text = 'Choose ability type',
      choices = {
        {id = 'spells', text = 'Spells', onChoose = {id = 'spellchoice'}, events = {'type:spell'}},
        {id = 'skills', text = 'Skills', onChoose = {id = 'skillchoice'}, events = {'type:skill'}},
        {id = 'special', text = 'Special', onChoose = {id = 'specialchoice'}, events = {'type:special'}},
        {id = 'life', text = 'Life', onChoose = {id = 'lifechoice'}, events = {'type:life'}},
      }
    },
    {
      id = 'spellchoice',
      text = 'Choose Spell',
      choices = {
        {id = 'sword', text = 'Sword', onChoose = {id = 'togglechoice'}, events = {'ability:sword'}},
        {id = 'jump', text = 'Jump', onChoose = {id = 'togglechoice'}, events = {'ability:jump'}},
        {id = 'missile', text = 'Magic Missile', onChoose = {id = 'togglechoice'}, events = {'ability:missile'}},
        {id = 'markrecall', text = 'Mark/Recall', onChoose = {id = 'togglechoice'}, events = {'ability:markrecall'}},
        {id = 'grip', text = 'Grip', onChoose = {id = 'togglechoice'}, events = {'ability:grip'}},
        {id = 'bomb', text = 'Bomb', onChoose = {id = 'togglechoice'}, events = {'ability:bomb'}},
        {id = 'speed', text = 'Speed', onChoose = {id = 'togglechoice'}, events = {'ability:speed'}},
        {id = 'mystery', text = 'Magic Dust', onChoose = {id = 'togglechoice'}, events = {'ability:mystery'}},
      }
    },
    {
      id = 'specialchoice',
      text = 'Choose Special',
      choices = {
        {id = 'power', text = 'Power', onChoose = {id = 'togglechoice'}, events = {'ability:power'}},
        {id = 'wisdom', text = 'Wisdom', onChoose = {id = 'togglechoice'}, events = {'ability:wisdom'}},
        {id = 'courage', text = 'Courage', onChoose = {id = 'togglechoice'}, events = {'ability:courage'}},
        {id = 'hotkeys', text = 'Hotkeys', onChoose = {id = 'togglechoice'}, events = {'ability:hotkeys'}},
        {id = 'waterwalk', text = 'Water walk', onChoose = {id = 'togglechoice'}, events = {'ability:waterwalk'}},
        {id = 'light', text = 'Light', onChoose = {id = 'togglechoice'}, events = {'ability:light'}},
        {id = 'customize', text = 'Customization', onChoose = {id = 'togglechoice'}, events = {'ability:customize'}},
      }
    },
    {
      id = 'togglechoice',
      text = function (convo)
        local ih = convo:getNodeIdHistory()
        if not ih then return 'node history not found' end
        local ch = convo:getChoiceHistory()
        if not ch then return 'choice history not found' end
        local type = ih[#ih - 1]
        local specific = ch[#ch]
        type = type:gsub("choice", "")
        return type .. ':' .. specific
      end,
      choices = {
        {id = 'enable', text = 'Enable', onChoose = function (convo)
          return {id = popPrevNodeId(convo)}
        end, events = {'value:enable'}},
        {id = 'disable', text = 'Disable', onChoose = function (convo)
          return {id = popPrevNodeId(convo)}
        end, events = {'value:enable'}},
      }
    },
    {
      id = 'skillchoice',
      text = 'Choose Skill',
      choices = {
        {id = 'athlectics', text = 'Athletics', onChoose = {id = 'lvlchoice'}, events = {'ability:athlectics'}},
        {id = 'swordspeed', text = 'Sword speed', onChoose = {id = 'lvlchoice'}, events = {'ability:swordspeed'}},
        {id = 'armor', text = 'Armor', onChoose = {id = 'lvlchoice'}, events = {'ability:armor'}},
        {id = 'missilespeed', text = 'Missile speed', onChoose = {id = 'lvlchoice'}, events = {'ability:missilespeed'}},
      }
    },
    {
      id = 'lvlchoice',
      text = function (convo)
        local ch = convo:getChoiceHistory()
        if not ch then return 'choice history not found' end
        local skill = ch[#ch]
        return "Choose " .. skill .. " level"
      end,
      choices = {
        {id = '0', text = '0', onChoose = {id = 'skillchoice'}, events = {'value:0'}},
        {id = '1', text = '1', onChoose = {id = 'skillchoice'}, events = {'value:1'}},
        {id = '2', text = '2', onChoose = {id = 'skillchoice'}, events = {'value:2'}},
        {id = '3', text = '3', onChoose = {id = 'skillchoice'}, events = {'value:3'}},
      }
    },
    {
      id = 'lifechoice',
      text = 'Amount?',
      choices = {
        {id = "21", text = "21", onChoose = {id = "abilitychoice"}, events = {'value:21'}},
        {id = "20", text = "20", onChoose = {id = "abilitychoice"}, events = {'value:20'}},
        {id = "19", text = "19", onChoose = {id = "abilitychoice"}, events = {'value:19'}},
        {id = "18", text = "18", onChoose = {id = "abilitychoice"}, events = {'value:18'}},
        {id = "17", text = "17", onChoose = {id = "abilitychoice"}, events = {'value:17'}},
        {id = "16", text = "16", onChoose = {id = "abilitychoice"}, events = {'value:16'}},
        {id = "15", text = "15", onChoose = {id = "abilitychoice"}, events = {'value:15'}},
        {id = "14", text = "14", onChoose = {id = "abilitychoice"}, events = {'value:14'}},
        {id = "13", text = "13", onChoose = {id = "abilitychoice"}, events = {'value:13'}},
        {id = "12", text = "12", onChoose = {id = "abilitychoice"}, events = {'value:12'}},
        {id = "11", text = "11", onChoose = {id = "abilitychoice"}, events = {'value:11'}},
        {id = "10", text = "10", onChoose = {id = "abilitychoice"}, events = {'value:10'}},
        {id = "9", text = "9", onChoose = {id = "abilitychoice"}, events = {'value:9'}},
        {id = "8", text = "8", onChoose = {id = "abilitychoice"}, events = {'value:8'}},
        {id = "7", text = "7", onChoose = {id = "abilitychoice"}, events = {'value:7'}},
        {id = "6", text = "6", onChoose = {id = "abilitychoice"}, events = {'value:6'}},
        {id = "5", text = "5", onChoose = {id = "abilitychoice"}, events = {'value:5'}},
        {id = "4", text = "4", onChoose = {id = "abilitychoice"}, events = {'value:4'}},
        {id = "3", text = "3", onChoose = {id = "abilitychoice"}, events = {'value:3'}},
        {id = "2", text = "2", onChoose = {id = "abilitychoice"}, events = {'value:2'}},
        {id = "1", text = "1", onChoose = {id = "abilitychoice"}, events = {'value:1'}},
        {id = "0", text = "0", onChoose = {id = "abilitychoice"}, events = {'value:0'}},
      }
    },
    {
      id = 'bye',
      text = 'Done!',
      autoProgress = true,
      options = {
        uninterruptible = true
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
      onEndDelay = 1,
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

return debugconvo