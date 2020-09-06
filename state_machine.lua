local sm = {}

function sm.new_state_machine(states)
  local machine = {}
  machine.states = states
  if states.state then machine.state = states.state end
  function machine.change_state(self, instance, dt, new_state)
    self.states[self.state].end_state(instance, dt)
    self.state = new_state
    self.states[self.state].start_state(instance, dt)
  end
  return machine
end

return sm
