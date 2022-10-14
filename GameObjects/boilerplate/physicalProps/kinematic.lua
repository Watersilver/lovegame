local ps = require "physics_settings"

local obj = {}

function obj.initialize(instance)
  instance.physical_properties = {
    bodyType = "kinematic",
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1,
    mass = 40,
    linearDamping = 40,
    restitution = 0,
  }
end
