local fsm = {}

function fsm.new_state_machine(states)
  machine = states
  function machine.change_state(self, instance, dt, new_state)
    self[self.state].end_state(instance, dt)
    self.state = new_state
    self[self.state].start_state(instance, dt)
  end
  return machine
end

return fsm
