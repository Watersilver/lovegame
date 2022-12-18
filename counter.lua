local counter = {}

local function update(self, dt)
  self.current = self.current - dt
  if self.current <= 0 then
    while self.current <= 0 do
      self.current = self.current + self.max_secs
    end
    return true
  end

  return false
end

function counter.new(max_secs)
  return {
    max_secs = max_secs,
    current = max_secs,
    update = update
  }
end

return counter