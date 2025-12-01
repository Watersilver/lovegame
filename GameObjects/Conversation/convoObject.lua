local p = require "GameObjects.prototype"
local u = require 'utilities'
local o = require 'GameObjects.objects'
local DialogueBubble = require 'GameObjects.DialogueBubble.DialogueBubble'
local input = require "input"
local snd = require "sound"
local ChoiceList = require "GameObjects.DialogueBubble.ChoiceList"

---@alias UnknownGameObject unknown

local Conversation = {}

local function playLetterSound(instance, source)
  if instance.letterSoundCooldown > 0 then return end
  snd.play(source)
  instance.letterSoundCooldown = 0.07
end

--- returns first object that contains given id
local function getObjFromId(self, id)
  if self.idMaps[id] then
    if self.idMaps[id].exists then
      return self.idMaps[id]
    end
  end
  if o.identified[id] then
    return o.identified[id][1]
  end
  return nil
end

---@param listType 'activator' | 'proximityRequirement'
local getClosest = function(self, listType)
  if not (pl1 and pl1.exists) then return nil, true end

  ---@type ConversationData
  local data = self.data
  ---@type DlgOptions
  local dlgOptions = self.dlgOptions

  local list = (
    listType == 'activator'
    and data.activators
    or dlgOptions.proximityRequired
  )
  or data.participants

  ---@type UnknownGameObject[] | nil
  local possibles
  if type(list) == 'table' then
    for _,a in ipairs(list) do
      local ided = getObjFromId(self, a)
      if ided then
        possibles = possibles or {}
        table.insert(possibles, ided)
      end
    end
  end

  if possibles then
    for _,po in ipairs(possibles) do
      local x = (po.x or 0) + (po.dlgAnchorOffsetX or 0)
      local y = (po.y or 0) + (po.dlgAnchorOffsetY or 0)
      if u.distance2d(pl1.x, pl1.y, x, y) < 22 then
        return po, list == 'none'
      end
    end
  end

  return nil, list == 'none'
end

local determinePosFromPlayer = function (obj)
  if obj and pl1 and pl1.exists then
    if pl1.y < obj.y then
      return "down"
    else
      return "up"
    end
  end
  return nil
end

---@param reason string
---@param dlgOptions DlgOptions
local function handleInterrupt(reason, dlgOptions, self)
  local onInterrupt = dlgOptions.onInterrupt or nil
  local nextId
  if type(onInterrupt) == 'function' then
    nextId = onInterrupt(self, reason)
  else
    nextId = onInterrupt
  end
  if nextId then
    self:setNext(nextId)
  else
    self.active = false
  end
end

---@param dlgOptions DlgOptions
local function computeDlgOptions(instance, dlgOptions)
  local bubbleOpts = {
    -- widthDelayMod = 0.125,
    -- noXOffset = true,
    -- duration = 0.2,
    timeBetweenLetters = dlgOptions.delay or GPAR.default_dlg_letter_delay,
    staysOnScreen = dlgOptions.staysOnScreen,
    noTriangle = dlgOptions.noSpeechBubbleTail,
    -- color = unknown,
    -- textRGBA = unknown
  }
  if dlgOptions.forceBubblePosition then
    bubbleOpts.position = dlgOptions.forceBubblePosition
  end

  local parsed = instance:getCurrentNodeParsedText()
  bubbleOpts.markup = parsed.markup
  return {
    bubbleOpts = bubbleOpts,
    parsed = parsed
  }
end

function Conversation.initialize(instance)
  instance.active = false
  instance.hasStartedOnce = false
  instance.currentNode = nil
  instance.closestActivator = nil
  instance.interactiveIndicator = nil
  instance.speechBubble = nil
  instance.choiceList = nil
  instance.currentChoices = nil
  instance.letterSoundCooldown = 0.0

  instance.nodeIdHistory = {}
  instance.choiceHistory = {}

  instance.idMaps = {}

  instance.eventHandlers = {}

  instance.dlgOptions = {}
  setmetatable(instance.dlgOptions, {
    __index = function(_, k)
      if instance.currentNode and instance.currentNode.options then
        if instance.currentNode.options[k] then
          return instance.currentNode.options[k]
        elseif instance.data and instance.data.options and instance.data.options[k] then
          return instance.data.options[k]
        end
      else
        if instance.data and instance.data.options and instance.data.options[k] then
          return instance.data.options[k]
        end
      end
    end
  })
end

---@class ConversationObject
Conversation.functions = {
  start = function(self)
    ---@type ConversationData
    local data = self.data

    self.active = true

    self.nodeIdHistory = {}
    self.choiceHistory = {}
  end,

  ---@param event string
  ---@param handler fun(payload?: string)
  listen = function (self, event, handler)
    if not self.eventHandlers[event] then
      self.eventHandlers[event] = {}
    end
    table.insert(self.eventHandlers[event], handler)
  end,

  ---@param event string
  ---@param payload? string
  fire = function (self, event, payload)
    local l = self.eventHandlers[event]
    if l then
      for _, h in ipairs(l) do
        h(payload)
      end
    end
  end,

  --- Sets ID encountered in conversation to object provided
  --- If this function is not used conversation id corresponds to normal object id
  ---@param id string
  setIdToObject = function(self, id, obj)
    self.idMaps[id] = obj
  end,

  ---@param nodeId string
  setNext = function(self, nodeId)

    ---@type ConversationData
    local data = self.data
    ---@type DlgOptions
    local dlgOptions = self.dlgOptions

    -- The object that spoke the last dlg node
    local prevAnchor = self.currentNode and getObjFromId(self, self.currentNode.anchor or data.participants[1])

    for _, node in ipairs(data.nodes) do
      if node.id == nodeId then
        self.currentNode = node
      end
    end

    if not self.currentNode then return end

    -- The object that will speak the dlg node of the givent nodeId parameter of this function
    local anchor = getObjFromId(self, self.currentNode.anchor or data.participants[1])

    self.active = true

    -- Create dialogue bubble if it doesn't exist
    if not self.speechBubble then
      local opts = computeDlgOptions(self, dlgOptions)
      local bubbleOpts = opts.bubbleOpts
      local parsed = opts.parsed
      if not dlgOptions.forceBubblePosition then
        local startingPos = determinePosFromPlayer(anchor)
        if startingPos then bubbleOpts.position = startingPos end
      end
      self.speechBubble = DialogueBubble.addNew(
        parsed.text,
        anchor,
        bubbleOpts
      )
    -- Handle existing dlg bubble
    elseif self.prevNodeId ~= self.currentNode.id then
      if anchor ~= prevAnchor then
        -- Speaker changed so delete dlg bubble and call this method again
        o.removeFromWorld(self.speechBubble)
        self.speechBubble = nil
        self:setNext(self.currentNode.id)
        return
      else
        local opts = computeDlgOptions(self, dlgOptions)
        local bubbleOpts = opts.bubbleOpts
        local parsed = opts.parsed

        local speechBubble = self.speechBubble
        speechBubble:setContent{string = parsed.text}
        speechBubble.reachedVisibleEnd = nil
        speechBubble.reachedEnd = nil
        speechBubble.nextExists = nil
        speechBubble.finishExists = nil
        speechBubble.scrollingUp = nil
        -- Make stable to do proper blobby effect
        speechBubble.stable = true
        -- Flat delay to next text rendering
        -- speechBubble.nextTextDelay = 0.5

        for option, value in pairs(bubbleOpts) do
          speechBubble[option] = value
        end
      end
    end

    if self.prevNodeId ~= self.currentNode.id then

      table.insert(self.nodeIdHistory, nodeId)

      -- Determine choices
      if self.choiceList then
        self.choiceList:remove()
        self.choiceList = nil
      end
      self.currentChoices = nil
      if self.currentNode.choices then
        for _, choice in ipairs(self.currentNode.choices) do
          -- If choice is just an id match it to global choice it represents
          if type(choice) == 'string' and data.choices then
            for _,globalChoice in ipairs(data.choices) do
              if globalChoice.id == choice then
                choice = globalChoice
                break
              end
            end
          end
          -- Choice is available if availability check doesn't exist or if availabilty check succeeds
          if type(choice) == 'table' and not choice.available or choice.available(self) then
            self.currentChoices = self.currentChoices or {}
            local text
            local textGetter = choice.text
            if type(textGetter) == 'function' then
              text = textGetter(self)
            else
              text = textGetter
            end
            table.insert(self.currentChoices, {
              id = choice.id,
              onChoose = choice.onChoose,
              text = text,
              events = choice.events
            })
          end
        end
      end
    end

    self.prevNodeId = self.currentNode.id
  end,

  getNodeIdHistory = function(self)
    return self.nodeIdHistory
  end,

  getChoiceHistory = function(self)
    return self.choiceHistory
  end,

  getCurrentNodeRawText = function(self)
    if not self.currentNode then return nil end
    ---@type TextGetter
    local currentNodeText = self.currentNode.text
    if type(currentNodeText) == 'function' then
      return currentNodeText(self)
    else
      return currentNodeText
    end
  end,

  getCurrentNodeParsedText = function(self)
    local txt = self:getCurrentNodeRawText()
    if not txt then return {text = ''} end
    local partitioned = u.splitTokens(txt, {'{.-}'})
    local plainTxt = {}
    local markup = {}
    local currentLength = 0
    for _, part in ipairs(partitioned) do
      if u.utf8_sub(part,1,1) ~= '{' then
        if part ~= '' then
          currentLength = currentLength + #part
          table.insert(plainTxt, part)
        end
      else
        table.insert(markup, {
          token = string.gsub(part, "[{}]", ""),
          atLength = currentLength + 1
        })
      end
    end

    return {
      text = table.concat(plainTxt),
      markup = markup
    }
  end,

  update = function(self, dt)
    ---@type ConversationData
    local data = self.data
    ---@type DlgOptions
    local dlgOptions = self.dlgOptions

    local interactive = data.activators ~= 'none'

    self.letterSoundCooldown = self.letterSoundCooldown - dt

    self.closestActivator = getClosest(self, 'activator')

    -----------------------------------------------
    -- Handle dialogue interactiveness indicator --
    if not self.active and interactive then
      if not self.interactiveIndicator and self.closestActivator then
        self.interactiveIndicator = DialogueBubble.addNew(
          "...",
          self.closestActivator,
          {
            widthDelayMod = 0.125,
            noXOffset = true,
            ellipse = true,
            duration = 0.2,
            timeBetweenLetters = 0.5,
            timeTillNextLetter = 0.1
          }
        )
      end
    end

    if self.interactiveIndicator then
      local cont = self.interactiveIndicator.content
      self.interactiveIndicator.timeTillNextLetter = self.interactiveIndicator.timeTillNextLetter - dt
      if self.interactiveIndicator.timeTillNextLetter < 0 then
        self.interactiveIndicator.timeTillNextLetter = self.interactiveIndicator.timeTillNextLetter + self.interactiveIndicator.timeBetweenLetters
        if cont:getLength() < cont:getMaxLength() then
          cont:updateLength(cont:getLength() + 1)
        else
          cont:updateLength(1)
        end
      end

      -- Update anchor
      if self.closestActivator then
        self.interactiveIndicator.anchor = self.closestActivator
      end
    end

    if (not self.closestActivator or self.active) and self.interactiveIndicator then
      self.interactiveIndicator:remove()
      self.interactiveIndicator = nil
    end
    -- End handle dialogue interactiveness indicator --
    ---------------------------------------------------

    ------------------------------------
    -- Handle Speech bubble lifecycle --
    if not self.active and self.closestActivator and interactive then
      if input.enterPressed then
        self:start()
      end
    end

    -- Choose starting node if dialogue is active but node hasn't been selected
    if self.active and not self.currentNode then
      local startNodeData = data.startNodeData
      local nodeData
      if type(startNodeData) == 'function' then
        nodeData = startNodeData(self)
      else
        nodeData = startNodeData
      end
      if nodeData then
        if nodeData.events then
          for _, ev in ipairs(nodeData.events) do
            local split = u.split(ev, ':')
            self:fire(split[1], split[2])
          end
        end

        for _, node in ipairs(data.nodes) do
          if node.id == nodeData.id then
            self.currentNode = node
          end
        end
      end
    end

    if self.currentNode and self.active then
      -- and self.currentNode.id ~= self.prevNodeId
      self:setNext(self.currentNode.id)
    end
    local choicesAvailable = not not self.currentChoices

    local nonAuto = self.currentNode and (not self.currentNode.autoProgress or choicesAvailable)

    if self.speechBubble then
      local dlgBubble = self.speechBubble
      if dlgBubble.nextTextDelay and dlgBubble.nextTextDelay > 0 then
        dlgBubble.nextTextDelay = dlgBubble.nextTextDelay - dt
        return
      end

      dlgBubble.position = determinePosFromPlayer(dlgBubble.anchor) or dlgBubble.position
      if dlgOptions.forceBubblePosition then
        dlgBubble.position = dlgOptions.forceBubblePosition
      end

      if dlgBubble.writable then
        if not dlgBubble.scrollingUp and (dlgBubble.content:getNextVisibleHeight() > dlgBubble.content:getHeight()) then
          dlgBubble.reachedVisibleEnd = true
        end
        if dlgBubble.reachedEnd then
          -- Set end delay if needed
          if self.currentNode then
            local oed = self.currentNode.onEndDelay
            if oed and not dlgBubble.endDelay then
              if type(oed) == 'number' then
                dlgBubble.endDelay = oed
              else
                dlgBubble.endDelay = oed(self)
              end
            end

            -- Default value for end delay for auto dialogues
            if not nonAuto and not dlgBubble.endDelay then
              dlgBubble.endDelay = 1.5
            end
          end

          -- Mark when delay allows us to proceed
          local canProceed = not dlgBubble.endDelay or dlgBubble.endDelay < 0

          -- Allow next step when delays are done
          if canProceed then

            ---@param onEnd DlgNextNodeDataGetter | nil
            local function handleNextGetter(onEnd)
              local next
              if type(onEnd) == 'function' then
                next = onEnd(self)
              else
                next = onEnd
              end

              if next and next.events then
                for _, ev in ipairs(next.events) do
                  local split = u.split(ev, ':')
                  self:fire(split[1], split[2])
                end
              end

              if
                not next
                or not next.id
              then
                if not next or (
                  next
                  and not next.keepConversationAlive
                  or not next.keepConversationAlive.keepTextBubbleAlive
                ) then
                  self.active = false
                end
              else
                self:setNext(next.id)
              end
            end

            if choicesAvailable then
              -- Create choice list
              if self.currentChoices and self.speechBubble and not self.choiceList then
                self.choiceList = ChoiceList.addNew(self.currentChoices, self.speechBubble)
              end

              if input.escapePressed or input.backspacePressed then
                handleInterrupt('cancel-choice', dlgOptions, self)
              end

              -- Check if cc exists because if user mashes enter it might not exist yet resulting in crash
              local cc = self.choiceList and self.choiceList:getCurrentChoice()
              if input.enterPressed and cc then
                snd.play(glsounds.select)
                table.insert(self.choiceHistory, cc.id)
                if cc.events then
                  for _, ev in ipairs(cc.events) do
                    local split = u.split(ev, ':')
                    self:fire(split[1], split[2])
                  end
                end
                handleNextGetter(cc.onChoose)
              end
            else
              -- Show end button when bubble is nonAuto and there are no choices
              if nonAuto then
                dlgBubble.finishExists = true
              end

              -- proceed to next dialogue, end dialogue, wait for choice or just wait
              if (not nonAuto or input.enterPressed) then
                if nonAuto and input.enterPressed then
                  snd.play(glsounds.textDone)
                end

                local onEnd = self.currentNode.onEnd
                handleNextGetter(onEnd)
              end
            end
          end

          -- update end delay
          if dlgBubble.endDelay then
            dlgBubble.endDelay = dlgBubble.endDelay - dt
          end
        elseif dlgBubble.reachedVisibleEnd then
          dlgBubble.nextExists = true
          if input.enter or not nonAuto then
            dlgBubble.nextExists = nil
            dlgBubble.reachedVisibleEnd = nil
            dlgBubble.scrollingUp = true
            if not self.currentNode.autoProgress then
              snd.play(glsounds.textNext)
            end
          end
        elseif dlgBubble.scrollingUp then
          dlgBubble.content:setYOffset(dlgBubble.content.yOffset + GPAR.dlg_scroll_speed_factor * dt)
          if dlgBubble.content:getNextVisibleHeight() <= dlgBubble.content:getHeight() then
            dlgBubble.content:setYOffset(dlgBubble.content:getOffsetAfterScrollingOneLine())
            dlgBubble.scrollingUp = nil
          end
        else

          local zeroDelay = false
          if not dlgBubble.currentTimeBetweenLetters then
            local ld = dlgBubble.content:getLetterDelay()
            dlgBubble.currentTimeBetweenLetters = ld < 0 and dlgBubble.timeBetweenLetters or ld

            if ld == 0 then
              dlgBubble.currentTimeBetweenLetters = -1
              zeroDelay = true
            end
          end

          if not dlgBubble.timeTillNextLetter then
            dlgBubble.timeTillNextLetter = dlgBubble.currentTimeBetweenLetters
          end
          dlgBubble.timeTillNextLetter = dlgBubble.timeTillNextLetter - dt

          if dlgBubble.timeTillNextLetter < 0 then
            local prevLength = dlgBubble.content:getLength()

            -- Determine number of letters to add
            local numberOfLettersToAdd = 1
            if zeroDelay then
              numberOfLettersToAdd = dlgBubble.content:getNextNonZeroDelayPosition() - prevLength
            end

            -- handle tokens (other than text colour and delay)
            if dlgBubble.content.options.markup then
              for _, v in ipairs(dlgBubble.content.options.markup) do
                -- Check if token falls between newly added length
                if v.atLength > prevLength and v.atLength <= prevLength + numberOfLettersToAdd then

                  -- Quest tokens
                  if u.utf8_sub(v.token,1,1) == 'q' then
                    local questName = u.utf8_sub(v.token,3)
                    session.startQuest(questName)
                  end

                  -- Event tokens
                  if u.utf8_sub(v.token,1,2) == 'ev' then
                    -- fire
                    local split = u.split(v.token, ':')
                    self:fire(split[2], split[3])
                  end
                end
              end
            end

            local added = dlgBubble.content:updateLength(prevLength + numberOfLettersToAdd)

            dlgBubble.content:updateHeightTextLength(prevLength + numberOfLettersToAdd + 1)
            dlgBubble.timeTillNextLetter = nil
            dlgBubble.currentTimeBetweenLetters = nil
            if dlgOptions.letterSound ~= 'none' and added ~= " " and prevLength < dlgBubble.content:getLength() then
              local src = dlgOptions.letterSound
              if type(src) == 'function' then
                src = src(self)
              end
              playLetterSound(self, src or glsounds.letterTypeA)
            end
          end

          if dlgBubble.content:getLength() >= dlgBubble.content:getMaxLength() then
            dlgBubble.reachedEnd = true
          else
            dlgBubble.reachedEnd = nil
          end
        end
      end
    end

    -- Handle interruptions
    if self.active and not dlgOptions.uninterruptible then

      local closestProxReq, proxDoesntInterrupt = getClosest(self, 'proximityRequirement')
      if
        not proxDoesntInterrupt
        and not closestProxReq
      then
        handleInterrupt('far-distance', dlgOptions, self)
      end

      if
        dlgOptions.facingRequired
        and pl1
        and pl1:getFacing() ~= dlgOptions.facingRequired
      then
        handleInterrupt('wrong-facing', dlgOptions, self)
      end
    end

    -- Delete speech bubble if inactive
    if not self.active and self.speechBubble then
      o.removeFromWorld(self.speechBubble)
      self.speechBubble = nil
      self.currentNode = nil
    end
  end,
}

---@return ConversationObject
function Conversation:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Conversation, instance, init) -- add own functions and fields
  return instance
end

-- Creates new Conversation obect and adds it to world
---@param data ConversationData
---@param options? unknown
function Conversation.addNew(data, parent, options)
  local c = Conversation:new({data = data, parent = parent, options = options})
  if parent then
    c.x = parent.x or parent.xstart
    c.y = parent.y or parent.ystart
    c.xstart = c.x
    c.ystart = c.y
  end
  o.addToWorld(c)
  return c
end

return Conversation
