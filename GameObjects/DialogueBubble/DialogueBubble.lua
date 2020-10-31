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
  -- options:
  -- Stays on screen
  -- Avoids player
  -- self playing?
  init.anchor = anchor
  init.string = string
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
      instance.state:change_state(instance, dt, "setUp")
    end,
    end_state = function(instance, dt)
    end
  },

  setUp = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
      -- instance.content = BubbleText.new(instance.string, instance)
      instance:setContent()
    end,
    check_state = function(instance, dt)
      if instance.triggers.resizeReady then
        instance.state:change_state(instance, dt, "test")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  test = {
    run_state = function(instance, dt)
      if instance.timer < 0 then
        instance.content:updateLength(instance.content.length + 1)
        instance.timer = instance.timeBetweenLetters
      end
      instance.timer = instance.timer - dt

      if instance.changeTimer < 0 then
        instance.changeTimer = 99999
        instance:setContent{string = "Happy now?"}
      end
      instance.changeTimer = instance.changeTimer - dt
    end,
    start_state = function(instance, dt)
      instance.timeBetweenLetters = 0.1
      instance.timer = instance.timeBetweenLetters
      instance.changeTimer = 3
    end,
    check_state = function(instance, dt)
      -- instance.state:change_state(instance, dt, "resize")
    end,
    end_state = function(instance, dt)
      instance.timeBetweenLetters = nil
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
  -- dampingRatio ζ = c / 2 * sqrt(k*m)
  instance.dampingRatio = 0.5 -- if > 1 it's overdamped
  instance.anchor = defaultAnchor
  instance.color = "black"
  instance.string = "string"
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

DialogueBubble.functions = {

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

  load = function (self)
    self.radius = 2
    self.triggers = {}
  end,

  update = function (self, dt)
    local anchor = self.anchor
    if not anchor or not anchor.exists then return end
    self.x = anchor.x
    self.y = anchor.y - self.height * 0.5 - self.padding - self.triangleHeight
    if anchor.zo then
      self.y = self.y + anchor.zo
    end
    if anchor.sprite then
      self.y = self.y - anchor.sprite.height * 0.5
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
    -- Draw bubble
    roundedRect.draw(
      self.x, self.y,
      self.width + 2 * self.padding * wdivtw,
      self.height + 2 * self.padding * hdivth,
      self.radius
    )
    if anchor and anchor.exists then
      -- Draw little triangle
      -- If above anchor
      bubbleTriangle.draw(
        anchor.x,
        self.y + 0.5 * self.height + self.padding * hdivth,
        self.triangleHeight,
        wdivtw,
        hdivth,
        "down"
      )
      -- If below anchor
      -- bubbleTriangle.draw(
      --   anchor.x,
      --   self.y - 0.5 * self.height - self.padding * self.height / self.targetHeight,
      --   self.triangleHeight,
      --   self.width / self.targetWidth,
      --   self.height / self.targetHeight,
      --   "up"
      -- )
    end
    self.content:draw(self.x, self.y - self.bottomPadding, cam);
    resetColour()
  end,
}

function DialogueBubble:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DialogueBubble, instance, init) -- add own functions and fields
  return instance
end

return DialogueBubble
