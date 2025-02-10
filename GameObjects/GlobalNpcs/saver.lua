local im = require "image"
local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local save = require 'ConversationData.data.save_convo'
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'
local TF = require "GameObjects.TextFloating"
local u = require "utilities"

local NPC = {}

function NPC.initialize(instance)
  ---@type Light[]
  instance.lights = {
    {
      type = "owlStatue",
      rgba = {r = 0, g = 0.5, b = 1, a = 1},
      x = instance.xstart,
      y = instance.ystart
    }
  }
  instance.sprite_info = im.spriteSettings.owlStatue
  instance.awake = false
  instance.image_speed = 0
  instance.image_index = 0
  instance.image_index_prev = 0
  instance.sleep_image_index_direction = 1
  instance.sleep_frame_cooldown = 0.5

  instance.conversation = conv.addNew(save, instance)
  instance.conversation:setIdToObject('saver', instance)
  instance.conversation:listen('wake', function()
    instance.awake = true
    instance.image_index = 0
    instance.image_speed = 0.25
    instance.sprite = im.sprites["NPCs/owlStatue/awake"]
  end)
  instance.conversation:listen('sleep', function()
    instance.awake = false
    instance.sleep_image_index_direction = 1
    instance.sleep_frame_cooldown = 0.5
  end)
  instance.conversation:listen('save', function()
    if pl1 then
      pl1:addHealth(100000)
    end
    session.saveGame()
    local vx = 0
    local vy = -10
    if pl1 then
      local _, dir = u.cartesianToPolar(pl1.x - instance.x, pl1.y - instance.y)
      vx, vy = u.polarToCartesian(-vy, dir)
    end
    TF:addNew{
      x = instance.x,
      y = instance.y - 10,
      content = 'saved',
      movement = {vx = vx, vy = vy},
      onUnstoppableUpdate = function(self)
        local t = self:getLifetime()
        self.opacity = 1 - t * 0.5
        if self.opacity < 0 then
          self:removeFromWorld()
          self.opacity = 0
        end
      end
    }
  end)
end

NPC.functions = {
  update = function (self, dt)
    self.image_index_prev = self.image_index
    npcProt.functions.update(self, dt)

    if not self.awake then
      if self.sprite ~= im.sprites["NPCs/owlStatue/asleep"] then
        if self.image_index_prev > self.image_index then
          self.image_speed = 0
          self.image_index = 0
          self.sprite = im.sprites["NPCs/owlStatue/asleep"]
        end
      else
        self.sleep_frame_cooldown = self.sleep_frame_cooldown - dt
        if self.sleep_frame_cooldown <= 0 then
          self.image_index = (self.image_index + self.sleep_image_index_direction) % 3

          self.sleep_frame_cooldown = 0.5
          if self.image_index == 0 then
            self.sleep_image_index_direction = 1
          elseif self.image_index == 2 then
            self.sleep_image_index_direction = -1
          else
            self.sleep_frame_cooldown = 0.35
          end
        end
      end
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
