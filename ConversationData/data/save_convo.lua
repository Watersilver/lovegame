local utilities = require "utilities"

-- ---@type ConversationData
-- local saveconvo = {
--   id = 'saveconvo',
--   participants = {'saver'},
--   startNodeData = {id = 'ask'},
--   options = {
--     onInterrupt = function (_, _)
--       return 'cancel'
--     end
--   },
--   nodes = {
--     {
--       id = 'ask',
--       text = '{ev:wake}Save game?',
--       choices = {
--         {id = 'yes', text = 'Yes', onChoose = {id = 'saved', events = {'save'}}},
--         {id = 'no', text = 'No', onChoose = {id = 'cancel'}},
--       },
--       options = {
--         staysOnScreen = true
--       }
--     },
--     {
--       id = 'saved',
--       text = "Saved!"
--     },
--     {
--       id = 'cancel',
--       text = "{ev:sleep}...",
--       autoProgress = true,
--       options = {
--         uninterruptible = true
--       }
--     }
--   },
-- }

---@type ConversationData
local saveconvo = {
  id = 'saveconvo',
  participants = {'saver'},
  startNodeData = {id = 'save'},
  options = {
    onInterrupt = function (_, _)
      return 'cancel'
    end
  },
  nodes = {
    {
      id = 'save',
      text = function ()
        local gossip = utilities.chooseFromWeightTable{
          {
            weight = 1,
            value = "Train your athletics skill to have better movement control!"
          },
          {
            weight = 1,
            value = "Master swordsmen are said to be able to interrup their own attack midswing to start another one! Neat huh?"
          },
          {
            weight = 1,
            value = "Good day!"
          },
          -- TODO: change this if the curse is lifted
          {
            weight = 1,
            value = "No one who has ever entered " .. GCON.lostWoods() .. " returned!"
          }
        }
        return "{ev:wake}{ev:save}" .. gossip
      end,
      onEnd = {events = {'sleep'}},
      options = {
        staysOnScreen = true,
      }
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