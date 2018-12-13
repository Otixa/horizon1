keybinds.keyDown.yawleft.add(function () engines.rotation.y = -1 end)
keybinds.keyUp.yawleft.add(function () engines.rotation.y = 0 end)

keybinds.keyDown.yawright.add(function () engines.rotation.y = 1 end)
keybinds.keyUp.yawright.add(function () engines.rotation.y = 0 end)

keybinds.keyDown.up.add(function () engines.direction.z = 1 end)
keybinds.keyUp.up.add(function () engines.direction.z = 0 end)

keybinds.keyDown.down.add(function () engines.direction.z = -1 end)
keybinds.keyUp.down.add(function () engines.direction.z = 0 end)

keybinds.keyDown.left.add(function () engines.direction.x = -1 end)
keybinds.keyUp.left.add(function () engines.direction.x = 0 end)

keybinds.keyDown.right.add(function () engines.direction.x = 1 end)
keybinds.keyUp.right.add(function () engines.direction.x = 0 end)

keybinds.keyDown.forward.add(function () engines.direction.y = 1 end)
keybinds.keyUp.forward.add(function () engines.direction.y = 0 end)

keybinds.keyDown.backward.add(function () engines.direction.y = -1 end)
keybinds.keyUp.backward.add(function () engines.direction.y = 0 end)

keybinds.keyDown.brake.add(function () engines.brake = true end)
keybinds.keyUp.brake.add(function () engines.brake = false end)

keybinds.keyUp.speeddown.add(function () engines.throttleUp() end)
keybinds.keyUp.speedup.add(function () engines.throttleDown() end)

keybinds.keyUp["option1"].add(function () mouse.toggleLock() mouse.enabled = not mouse.enabled end)
keybinds.keyUp["option2"].add(function () engines.followGravity = not engines.followGravity end)
keybinds.keyUp["option3"].add(function () engines.direction.y = 1 end)

keybinds.keyUp["option5"].add(function () engines.targetVector = engines.target.prograde end)
keybinds.keyUp["option6"].add(function () engines.targetVector = engines.target.retrograde end)
keybinds.keyUp["option7"].add(function () engines.targetVector = nil end)