local input = require "input"
local snd = require "sound"
local bubble = require "GameObjects.DialogueBubble.DialogueBubble"
local u = require "utilities"

local cd = {}

local closeEnoughToPlayer = function (self)
  if not (pl1 and pl1.exists) then return end
  local playa = pl1
  if u.distance2d(playa.x, playa.y, self.x, self.y) < (self.closenessThresh or 22) then
    return true
  end
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

private.singleSimpleBubbleTemplate = function(interactive, noSound, stopWhenFar)

  return function(dlgControl, dt)
    if not dlgControl.singleSimpleBubble then
      local options = {}
      local startingPos = determinePosFromPlayer(dlgControl)
      if startingPos then options.position = startingPos end
      dlgControl.singleSimpleBubble = bubble.addNew(dlgControl.content, dlgControl, options)
      local inst = dlgControl.singleSimpleBubble
      inst.timeBetweenLetters = 0.055
      inst.timer = inst.timeBetweenLetters
      inst.persistence = dlgControl.persistence or 1.5
    else
      local instance = dlgControl.singleSimpleBubble

      instance.position = determinePosFromPlayer(dlgControl) or instance.position

      if instance.stable then
        if not instance.scrollingUp and (instance.content:getNextVisibleHeight() > instance.content:getHeight()) then
          instance.waitForKeyPress = true
        end
        if instance.waitForLastKeyPress then
          if interactive then instance.finishExists = true
          else instance.persistence = instance.persistence - dt end
          if (interactive and input.enterPressed) or (not interactive and instance.persistence < 0) then
            if interactive and input.enterPressed then snd.play(glsounds.textDone) end
            dlgControl.singleSimpleBubble:remove()
            dlgControl.singleSimpleBubble = nil
            dlgControl.updateHook = nil
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

    if stopWhenFar and not closeEnoughToPlayer(dlgControl) then
      local instance = dlgControl.singleSimpleBubble
      local newContent = dlgControl:getInterruptedDlg()
      dlgControl.updateHook = cd.singleSimpleSelfPlayingBubble
      instance:setContent{string = newContent}
      instance.waitForKeyPress = nil
      instance.waitForLastKeyPress = nil
      instance.nextExists = nil
      instance.finishExists = nil
      instance.scrollingUp = nil
    end

  end
end

private.proximityTriggerTemplate = function (interactive, triggerType)

  return function(dlgControl, dt)
    dlgControl.indicatorCooldown = dlgControl.indicatorCooldown - dt
    if closeEnoughToPlayer(dlgControl) then
      if not interactive or input.enterPressed then
        dlgControl.updateHook = nil
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

cd.singleSimpleInteractiveBubble = private.singleSimpleBubbleTemplate(true)
cd.closeInteractiveBubble = private.singleSimpleBubbleTemplate(true, false, true)
cd.singleSimpleSelfPlayingBubble = private.singleSimpleBubbleTemplate(false, true)
cd.interactiveProximityTrigger = private.proximityTriggerTemplate(true)

return cd
