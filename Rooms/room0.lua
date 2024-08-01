-- Special starting room that doesn't quite follow room rules
-- Used to create the persistent player object
-- (Yes I could have created it a different way no real reason for this room)
-- 11-5-2023 update: I am a fucking asshole. Why would I do this? Any of this? I suck. Will attempt to fix.
-- 11-5-2023 update: radically changed this to make as sane as possible. Let it stand as a testament to my suckiness.
-- 6-27-2024 update: What? What's going on here? How do I detect where the onLoad room is??? Why why why why
-- 6-27-2024 update: Found it. Its in the PlayaTest initialize function. Fuck.

local room = {}
room.newType = true

room.width = 800
room.height = 450

-- 11-5-2023 update: what the fuck was I thinking.
mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.gameObjects = {}

room.manuallyPlacedObjects = {
  {x = session.save.playerX or 55, y = session.save.playerY or 55, blueprint = "PlayaTest"},
}

return room
