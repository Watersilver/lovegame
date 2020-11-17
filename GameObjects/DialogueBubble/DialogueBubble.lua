local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local u = require "utilities"
local sm = require "state_machine"
local roundedRect = require "GameObjects.DialogueBubble.roundedRect"
local bubbleTriangle = require "GameObjects.DialogueBubble.bubbleTriangle"
local BubbleText = require "GameObjects.DialogueBubble.BubbleText"

local DialogueBubble = {}

function DialogueBubble.addNew(string, anchor, options)
  local init = options or {}
  init.anchor = anchor
  init.string = string
  init.position = init.position or "up"
  init.staysOnScreen = init.staysOnScreen
  init.noXOffset = init.noXOffset
  -- textRGBA
  local newBubble = DialogueBubble:new(init)
  o.addToWorld(newBubble)
  return newBubble
end


local resize = {
  hThenW = function (self, dt)
    -- Will probably take a bit longer than
    -- duration because last height fract
    -- will be bigger than it has to
    local halfDur = self.duration * 0.5
    if self.height == self.targetHeight then
      local wFract = self.targetWidth * dt / halfDur
      self.width = self.width + wFract
      if self.width > self.targetWidth then
        self.width = self.targetWidth
        self.triggers.resizeReady = true
      end
    end
    local hFract = self.targetHeight * dt / halfDur
    self.height = self.height + hFract
    if self.height > self.targetHeight then
      self.height = self.targetHeight
    end
  end,

  blobby = function (self, dt)
    local logthdivdur = math.log(self.targetHeight) / self.duration

    if self.stable then
      -- sqrt(1/x) = 1 / sqrt(x)
      -- Period T = 2 * π * sqrt(m / k)
      -- WTF below?????
      self.timeBeforeWidthVibrates = self.widthDelayMod * 0.125 * math.pi / math.sqrt(logthdivdur)
      if math.abs(self.height - self.targetHeight) >= 0.01 or
      math.abs(self.width - self.targetWidth) >= 0.01 then
        self.stable = false
        self.triggers.resizeReady = nil
        if self.becameUnstableBefore then
          self.stabilizedOnce = true
        end
        self.becameUnstableBefore = true
      end
    else
      self.timeBeforeWidthVibrates = self.timeBeforeWidthVibrates - dt
      if math.abs(self.widthVel) <= 0.1 and
      math.abs(self.widthAcc) <= 0.1 and
      math.abs(self.height - self.targetHeight) < 0.01 and
      math.abs(self.width - self.targetWidth) < 0.01 then
        self.stable = true
        -- self.widthMoveState = "wait"
        self.triggers.resizeReady = true
        self.height = self.targetHeight
        self.width = self.targetWidth
      end
    end

    if math.abs(self.widthVel) < 1 and
    math.abs(self.height - self.targetHeight) < 5 and
    math.abs(self.width - self.targetWidth) < 5 then
      self.writable = true
    else
      self.writable = false
    end

    -- Se duration 1 / k to amplitude tha einai self.targetHeight / e
    -- Thelw Amp < 1
    -- Amp = self.targetHeight * e ^ (-k * dur) =>
    -- Amp = self.targetHeight / e ^ (k * dur) =>
    -- e ^ (k * dur) = self.targetHeight / Amp =>
    -- k * dur = ln(self.targetHeight / Amp) =>
    -- k = ln(self.targetHeight / Amp) / dur =>
    -- An Amp = 1 tote:
    -- k = ln(self.targetHeight) / dur =>
    -- h targetWidth
    local k = dt * logthdivdur

    -- dampingRatio ζ = c / 2 * sqrt(k*m) if >= 1 it's overdamped
    -- so c = ζ * 2 * sqrt(k*m), for m = 1 =>
    -- c = ζ * 2 * sqrt(k)
    -- or dampingRatio = dumping / criticalDumping =>
    -- dumping = dampingRatio * criticalDumping
    local c = self.dampingRatio * 2 * math.sqrt(k)
    self.heightAcc = - k * (self.height - self.targetHeight)
    self.heightAcc = self.heightAcc - c * self.heightVel
    -- self.heightVel = (self.heightVel + self.heightAcc) * (1 - self.damping)
    self.heightVel = self.heightVel + self.heightAcc
    self.height = self.height + self.heightVel

    -- self.widthMoveState = self.widthMoveState or "wait"
    -- -- Diafora fashs 45 (nomizw. Mporei 90)
    -- -- if self.heightAcc < 0 then self.widthMoveState = "start" end
    -- -- Diafora fashs 90 (pali nomizw. Mporei 180)
    -- if self.heightVel < 0 then self.widthMoveState = "start" end

    if self.timeBeforeWidthVibrates <= 0 then
      self.widthAcc = - k * (self.width - self.targetWidth)
      self.widthAcc = self.widthAcc - c * self.widthVel
      -- self.widthVel = (self.widthVel + self.widthAcc) * (1 - self.damping)
      self.widthVel = self.widthVel + self.widthAcc
      self.width = self.width + self.widthVel
      -- if math.abs(self.widthVel) <= 0.1 and math.abs(self.widthAcc) <= 0.1 then
      --   self.stable = true
      -- end
    end
  end,
}

local function resetPeriod(self)
end


local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      instance.state:change_state(instance, dt, "nothing")
    end,
    end_state = function(instance, dt)
    end
  },

  nothing = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
      -- instance:setContent()
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  }
}


local defaultAnchor = {x = 0, y = 0, exists = true}
function DialogueBubble.initialize(instance)
  instance.x = 0
  instance.y = 0
  instance.width = 0
  instance.height = 0
  instance.stable = true
  instance.triangleHeight = 5
  instance.targetWidth = 0
  instance.targetHeight = 0
  instance.padding = 4
  instance.bottomPadding = 1
  instance.resizeFunc = "hThenW"
  instance.resizeFunc = "blobby"
  instance.widthAcc = 0
  instance.widthVel = 0
  instance.heightAcc = 0
  instance.heightVel = 0
  instance.duration = 1
  instance.widthDelayMod = 1
  -- instance.widthDelayMod = 0.5
  -- dampingRatio ζ = c / 2 * sqrt(k*m)
  instance.dampingRatio = 0.5 -- if > 1 it's overdamped
  instance.anchor = defaultAnchor
  instance.color = "black"
  instance.string = "string"
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

DialogueBubble.functions = {
  remove = function (self)
    o.removeFromWorld(self)
  end,

  setContent = function (self, options)
    options = options or {}
    self.string = options.string or self.string
    self.maxWidth = options.maxWidth or self.maxWidth
    self.maxHeight = options.maxHeight or self.maxHeight
    self.font = options.font or self.font
    self.textRGBA = options.textRGBA or self.textRGBA
    self.content = BubbleText.new(self.string, self)
    self.targetWidth = self.content:getWidth()
    self.targetHeight = self.content:getHeight()
  end,

  toggleNextButton = function (self, bool)
    self.nextExists = bool
  end,

  toggleFinishButton = function (self, bool)
    self.finishExists = bool
  end,

  load = function (self)
    self.radius = 2
    self.triggers = {}
    self.positionMod = self.position == "up" and 1 or -1
    self.posModSpeed = 11
    self:setContent()
    self.buttonTimer = 0
  end,

  update = function (self, dt)
    -- Update timer
    self.buttonTimer = self.buttonTimer + dt * 5

    local anchor = self.anchor
    if not anchor or not anchor.exists then return end
    if self.position == "up" then
      self.positionMod = self.positionMod + dt * self.posModSpeed
      if self.positionMod > 1 then self.positionMod = 1 end
    else
      self.positionMod = self.positionMod - dt * self.posModSpeed
      if self.positionMod < -1 then self.positionMod = -1 end
    end

    self.x = anchor.x
    self.y = anchor.y -
    self.positionMod *
    (
      self.height * 0.5
      + self.padding
      + self.triangleHeight * math.abs(self.positionMod)
    )
    if anchor.height then
     self.y = self.y - anchor.height * 0.5 * self.positionMod
    end

    -- do stuff depending on state
    local state = self.state
    -- Check state
    state.states[state.state].check_state(self, dt)

    -- Nilify triggers
    for trigger in pairs(self.triggers) do
      self.triggers[trigger] = nil
    end

    -- Run state
    state.states[state.state].run_state(self, dt)

    -- Resize
    resize[self.resizeFunc](self, dt)
  end,

  draw_overlay = function (self, cam)
    local anchor = self.anchor
    local resetColour = u.storeColour()
    local wdivtw = self.stabilizedOnce and 1 or math.min(self.width / self.targetWidth, 1)
    local hdivth = self.stabilizedOnce and 1 or math.min(self.height / self.targetHeight, 1)
    u.changeColour{self.color}

    -- Adjust x to camera position
    -- Determine side bubble is leaning towards
    local camMiddle = cam:getPosition()
    local side
    if self.x > camMiddle then
      side = -1
    else
      side = 1
    end

    -- Determine xOffset
    local l, t, w, h = cam:getVisible()
    local edgeDist = 0.5 * w - 16
    local xPercent = math.abs(self.x - camMiddle) / edgeDist
    if xPercent > 1 then xPercent = 1 end
    local maxXOffset = self.width * 0.47
    local xOffset = side * xPercent * maxXOffset
    xOffset = self.noXOffset and 0 or xOffset

    local x, y = self.x + xOffset, self.y
    self.xOffset = xOffset

    -- Make sure to stay in camera if I must
    local totalWidth = self.width + 2 * self.padding * wdivtw
    local totalHeight = self.height + 2 * self.padding * hdivth
    if self.staysOnScreen then
      -- Check x axis
      if l + 3 > x - 0.5 * totalWidth then
        -- beyond left edge
        x = l + 3 + 0.5 * totalWidth
      elseif l + w - 3 < x + 0.5 * totalWidth then
        -- beyond right edge
        x = l + w - 3 - 0.5 * totalWidth
      end
      -- Check y axis
      local triangleOffset = self.positionMod * self.triangleHeight
      local topTrigOffset = 0
      local bottomTrigOffset = 0
      if self.positionMod < 0 then
        topTrigOffset = triangleOffset
      else
        bottomTrigOffset = triangleOffset
      end
      if t + 3 > y - 0.5 * totalHeight + topTrigOffset then
        -- beyond top edge
        y = t + 3 + 0.5 * totalHeight - topTrigOffset
      elseif t + h - 3 < y + 0.5 * totalHeight + bottomTrigOffset then
        -- beyond bottom edge
        y = t + h - 3 - 0.5 * totalHeight - bottomTrigOffset
      end
    end

    -- Draw bubble
    if anchor and anchor.exists then
      local triangleX = anchor.x
      triangleX = u.clamp(x - maxXOffset, triangleX, x + maxXOffset)
      -- Draw little triangle
      -- If above anchor
      if self.positionMod > 0 then
        bubbleTriangle.draw(
          triangleX,
          y + 0.5 * self.height + self.padding * hdivth * self.positionMod,
          self.triangleHeight,
          wdivtw,
          hdivth * self.positionMod,
          "down"
        )
      else
        -- If below anchor
        bubbleTriangle.draw(
          triangleX,
          y - 0.5 * self.height + self.padding * hdivth * self.positionMod,
          self.triangleHeight,
          wdivtw,
          - hdivth * self.positionMod,
          "up"
        )
      end
    end
    -- Textbox
    if self.ellipse then
      love.graphics.ellipse("fill", x, y + 1, totalWidth * 0.5, totalHeight * 0.5)
      y = y + 2 -- Correct content height
    else
      roundedRect.draw(
        x, y,
        totalWidth,
        totalHeight,
        self.radius
      )
    end
    -- Text content
    self.content:draw(x, y - self.bottomPadding, cam)

    -- Buttons
    if self.finishExists then
      -- u.changeColour{"white"}
      local baseRad = 2
      local nbx = x + 0.5 * self.width - baseRad
      local nby = y + 0.5 * self.height
      u.changeColour{"red"}
      local rad = baseRad - math.sin(self.buttonTimer) * 0.2
      love.graphics.circle("fill", nbx, nby, 2 - math.sin(self.buttonTimer) * 0.2)
      u.changeColour{"black"}
      local rad2 = baseRad * 0.9 + math.sin(self.buttonTimer) * 0.5
      love.graphics.circle("fill", nbx, nby, rad2)
    elseif self.nextExists then
      local timeMod = math.sin(self.buttonTimer) * 0.2
      u.changeColour{"red"}--, a = (timeMod * 2.5 + 0.5) * COLORCONST}
      local nbtw2 = 2
      local nbth2 = 1 + timeMod
      local nbrw2 = 0.75
      local nbrh = 1.2 + timeMod
      local nbx = x + 0.5 * self.width - nbtw2
      local nby = y + 0.5 * self.height + 1
      love.graphics.polygon("fill",
        nbx, nby + nbth2,
        nbx + nbtw2, nby - nbth2,
        nbx + nbrw2, nby - nbth2,
        nbx + nbrw2, nby - nbth2 - nbrh,
        nbx - nbrw2, nby - nbth2 - nbrh,
        nbx - nbrw2, nby - nbth2,
        nbx - nbtw2, nby - nbth2
      )
    end

    resetColour()
  end,
}

function DialogueBubble:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DialogueBubble, instance, init) -- add own functions and fields
  return instance
end

return DialogueBubble
