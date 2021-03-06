local input = require "input"
local snd = require "sound"
local bubble = require "GameObjects.DialogueBubble.DialogueBubble"
local cl = require "GameObjects.DialogueBubble.ChoiceList"
local u = require "utilities"

local cd = {}

local closeEnoughToPlayer = function (self)
  if not (pl1 and pl1.exists) then return end
  local playa = pl1
  if u.distance2d(playa.x, playa.y, self.x, self.y + (self.yProxOffset or 0)) < (self.closenessThresh or 22) then
    return true
  end
end

local plHasCorrectFacing = function (self)
  if self.forceFacing then
    if pl1 and pl1.exists then
      if pl1:getFacing() ~= self.forceFacing then return false end
    end
  end
  return true
end

local determinePosFromPlayer = function (self)
  if pl1 and pl1.exists then
    if pl1.y < self.y then
      return "down"
    else
      return "up"
    end
  end
end

local private = {}

private.singleSimpleBubbleTemplate = function(settings)
  settings = settings or {}
  local interactive, noSound, stopWhenFar, waitOnEnd =
    settings.interactive or settings[1], settings.noSound or settings[2],
    settings.stopWhenFar or settings[3], settings.waitOnEnd or settings[4]

  return function(dlgControl, dt)
    if not dlgControl.speechBubble then
      local options = {} or settings.options
      local startingPos = determinePosFromPlayer(dlgControl)
      if startingPos then options.position = startingPos end
      if dlgControl.ssbPosition then options.position = dlgControl.ssbPosition end
      if dlgControl.nossbTriangle then options.noTriangle = true end
      if dlgControl.ssbStayOnScreen then options.staysOnScreen = true end
      if dlgControl.ssbColor then options.color = dlgControl.ssbColor end
      if dlgControl.ssbRGBA then options.textRGBA = dlgControl.ssbRGBA end
      dlgControl.speechBubble = bubble.addNew(dlgControl:getDlg(), dlgControl, options)
      local inst = dlgControl.speechBubble
      inst.timeBetweenLetters = 0.055
      inst.timer = inst.timeBetweenLetters
      inst.persistence = dlgControl.persistence or 1.5
    else
      local instance = dlgControl.speechBubble
      if instance.nextTextDelay and instance.nextTextDelay > 0 then
        instance.nextTextDelay = instance.nextTextDelay - dt
        return
      end

      instance.position = determinePosFromPlayer(dlgControl) or instance.position
      if dlgControl.ssbPosition then instance.position = dlgControl.ssbPosition end

      if instance.writable then
        if not instance.scrollingUp and (instance.content:getNextVisibleHeight() > instance.content:getHeight()) then
          instance.waitForKeyPress = true
        end
        if instance.waitForLastKeyPress then
          if not waitOnEnd then
            if interactive then instance.finishExists = true
            else instance.persistence = instance.persistence - dt end
            if (interactive and input.enterPressed) or (not interactive and instance.persistence < 0) then
              if interactive and input.enterPressed then
                snd.play(glsounds.textDone)
                instance.enterPressed = true
              end
              -- Disable hook
              dlgControl.updateHook = nil
              -- Set return value
              dlgControl.textReturn = instance.string
              dlgControl.hookReturn = "ssbDone"
            end
          else
            -- Disable hook
            dlgControl.updateHook = nil
            -- Set return value
            dlgControl.textReturn = instance.string
            dlgControl.hookReturn = "ssbWaiting"
          end
        elseif instance.waitForKeyPress then
          instance.nextExists = true
          if input.enter or not interactive then
            instance.nextExists = nil
            instance.waitForKeyPress = nil
            instance.scrollingUp = true
            if interactive then snd.play(glsounds.textDone) end
          end
        elseif instance.scrollingUp then
          instance.content:setYOffset(instance.content.yOffset + 25 * dt)
          if instance.content:getNextVisibleHeight() <= instance.content:getHeight() then
            instance.content:setYOffset(instance.content:getOffsetAfterScrollingOneLine())
            instance.scrollingUp = nil
          end
        else
          if instance.timer < 0 then
            local prevLength = instance.content:getLength()
            local added = instance.content:updateLength(instance.content:getLength() + 1)
            instance.content:updateHeightTextLength(instance.content:getLength() + 2)
            instance.timer = instance.timeBetweenLetters
            if (not noSound) and added ~= " " and prevLength < instance.content:getLength() then
              snd.play(glsounds.letter)
            end
          end
          instance.timer = instance.timer - dt
          if instance.content:getLength() >= instance.content:getMaxLength() then
            instance.waitForLastKeyPress = true
          else
            instance.waitForLastKeyPress = nil
          end
        end
      end
    end

    if stopWhenFar then
      cd.closenessChecker(dlgControl)
      cd.facingChecker(dlgControl)
    end

  end
end

cd.cleanSsb = function (dlgControl)
  if not dlgControl.speechBubble then return end
  dlgControl.speechBubble:remove()
  dlgControl.speechBubble = nil
end

private.ssbChange = function (contentFunc, updateHook)
  return function (dlgControl)
    local instance = dlgControl.speechBubble
    local newContent = dlgControl[contentFunc](dlgControl)
    dlgControl.updateHook = cd[updateHook]
    instance:setContent{string = newContent}
    instance.waitForKeyPress = nil
    instance.waitForLastKeyPress = nil
    instance.nextExists = nil
    instance.finishExists = nil
    instance.scrollingUp = nil
    -- Make stable to do proper blobby effect
    instance.stable = true
  end
end

cd.ssbInterrupted = private.ssbChange("getInterruptedDlg", "singleSimpleSelfPlayingBubble")
cd.ssbToNib = private.ssbChange("getDlg", "nearInteractiveBubble")
cd.ssbToSsspb = private.ssbChange("getDlg", "singleSimpleSelfPlayingBubble")

cd.ssbChange = function (dlgControl)
  local instance = dlgControl.speechBubble
  local newContent = dlgControl:getDlg()
  instance:setContent{string = newContent}
  instance.waitForKeyPress = nil
  instance.waitForLastKeyPress = nil
  instance.nextExists = nil
  instance.finishExists = nil
  instance.scrollingUp = nil
  -- Make stable to do proper blobby effect
  instance.stable = true
  instance.nextTextDelay = 0.5
end

private.proximityTriggerTemplate = function (interactive)

  return function(dlgControl, dt)
    dlgControl.indicatorCooldown = dlgControl.indicatorCooldown - dt
    if closeEnoughToPlayer(dlgControl) and plHasCorrectFacing(dlgControl) then
      if not interactive or input.enterPressed then
        dlgControl.updateHook = nil
        dlgControl.hookReturn = "ptTriggered"
        if dlgControl.speechIndicator then
          dlgControl.speechIndicator:remove()
          dlgControl.speechIndicator = nil
        end
      elseif not dlgControl.speechIndicator then
        if dlgControl.indicatorCooldown < 0 then
          dlgControl.speechIndicator = bubble.addNew("...", dlgControl, {widthDelayMod = 0.125, noXOffset = true, ellipse = true, duration = 0.2})
          dlgControl.speechIndicator.timeBetweenLetters = 0.5
          dlgControl.speechIndicator.timer = 0.1
        end
      else
        local cont = dlgControl.speechIndicator.content
        dlgControl.speechIndicator.timer = dlgControl.speechIndicator.timer - dt
        if dlgControl.speechIndicator.timer < 0 then
          dlgControl.speechIndicator.timer = dlgControl.speechIndicator.timer + dlgControl.speechIndicator.timeBetweenLetters
          if cont:getLength() < cont:getMaxLength() then
            cont:updateLength(cont:getLength() + 1)
          else
            cont:updateLength(1)
          end
        end
      end
    else
      if dlgControl.speechIndicator then
        dlgControl.speechIndicator:remove()
        dlgControl.speechIndicator = nil
      end
    end
  end

end

cd.closenessChecker = function (dlgControl)
  if not closeEnoughToPlayer(dlgControl) then
    local instance = dlgControl.speechBubble
    if instance then
      dlgControl.textReturn = instance.string
    else
      dlgControl.textReturn = nil
    end
    dlgControl.hookReturn = "ssbFar"
    dlgControl.updateHook = nil
  end
end

cd.facingChecker = function (dlgControl)
  if not plHasCorrectFacing(dlgControl) then
    local instance = dlgControl.speechBubble
    if instance then
      dlgControl.textReturn = instance.string
    else
      dlgControl.textReturn = nil
    end
    dlgControl.hookReturn = "ssbLookedAway"
    dlgControl.updateHook = nil
  end
end

cd.choiceChecker = function (dlgControl)
  local instance = dlgControl.speechBubble
  if not instance.choiceList then
    instance.choiceList = cl.addNew(dlgControl:getChoices(), instance)
  end
  if input.escapePressed then
    dlgControl.hookReturn = "ssbFar"
    dlgControl.updateHook = nil
  end
  if input.enterPressed then
    snd.play(glsounds.select)
    dlgControl.choiceReturn = {
      q = instance.string,
      a = instance.choiceList.choices[instance.choiceList.cursor]
    }
    dlgControl.hookReturn = "ssbChose"
    dlgControl.updateHook = nil
  end
  cd.closenessChecker(dlgControl)
  cd.facingChecker(dlgControl)
  if not dlgControl.updateHook then
    instance.choiceList:remove()
  end
end

cd.singleSimpleInteractiveBubble = private.singleSimpleBubbleTemplate({true})
cd.nearInteractiveBubble = private.singleSimpleBubbleTemplate({true, false, true})
cd.nearInteractiveChoiceBubble = private.singleSimpleBubbleTemplate({true, false, true, true})
cd.singleSimpleSelfPlayingBubble = private.singleSimpleBubbleTemplate({false, true})
cd.interactiveProximityTrigger = private.proximityTriggerTemplate(true)

cd.ssb = {
  auto = {
    sound = {
      func = private.singleSimpleBubbleTemplate()
    }
  }
}

return cd
