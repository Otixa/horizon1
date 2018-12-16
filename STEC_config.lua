keybindPresets["maneuver"] = KeybindController()
keybindPresets["cruise"] = KeybindController()

keybindPresets["maneuver"].keyDown.yawleft.Add(function () engines.rotation.y = -1 end)
keybindPresets["maneuver"].keyUp.yawleft.Add(function () engines.rotation.y = 0 end)
keybindPresets["maneuver"].keyDown.yawright.Add(function () engines.rotation.y = 1 end)
keybindPresets["maneuver"].keyUp.yawright.Add(function () engines.rotation.y = 0 end)

keybindPresets["maneuver"].keyDown.up.Add(function () engines.direction.z = 1 end)
keybindPresets["maneuver"].keyUp.up.Add(function () engines.direction.z = 0 end)
keybindPresets["maneuver"].keyDown.down.Add(function () engines.direction.z = -1 end)
keybindPresets["maneuver"].keyUp.down.Add(function () engines.direction.z = 0 end)
keybindPresets["maneuver"].keyDown.left.Add(function () engines.direction.x = -1 end)
keybindPresets["maneuver"].keyUp.left.Add(function () engines.direction.x = 0 end)
keybindPresets["maneuver"].keyDown.right.Add(function () engines.direction.x = 1 end)
keybindPresets["maneuver"].keyUp.right.Add(function () engines.direction.x = 0 end)
keybindPresets["maneuver"].keyDown.forward.Add(function () engines.direction.y = 1 end)
keybindPresets["maneuver"].keyUp.forward.Add(function () engines.direction.y = 0 end)
keybindPresets["maneuver"].keyDown.backward.Add(function () engines.direction.y = -1 end)
keybindPresets["maneuver"].keyUp.backward.Add(function () engines.direction.y = 0 end)

keybindPresets["maneuver"].keyDown.brake.Add(function () engines.brake = true end)
keybindPresets["maneuver"].keyUp.brake.Add(function () engines.brake = false end)

keybindPresets["maneuver"].keyUp.speeddown.Add(function () engines.throttleUp() end, "Increase Throttle")
keybindPresets["maneuver"].keyUp.speedup.Add(function () engines.throttleDown() end, "Decrease Throttle")

keybindPresets["maneuver"].keyDown.stopengines.Add(function () mouse.unlock() mouse.enabled = false end, "Free Look")
keybindPresets["maneuver"].keyUp.stopengines.Add(function () mouse.lock() mouse.enabled = true end)

keybindPresets["maneuver"].keyUp["option2"].Add(function () engines.followGravity = not engines.followGravity end, "Gravity Assist")
keybindPresets["maneuver"].keyUp["option3"].Add(function () engines.direction.y = 1 end, "Cruise Control")
keybindPresets["maneuver"].keyUp["option5"].Add(function () if engines.targetVector == engines.target.prograde then engines.targetVector = nil else engines.targetVector = engines.target.prograde end end, "Lock Prograde")
keybindPresets["maneuver"].keyUp["option6"].Add(function () if engines.targetVector == engines.target.retrograde then engines.targetVector = nil else engines.targetVector = engines.target.retrograde end end, "Lock Retrograde")

keybindPresets["maneuver"].keyUp["option9"].Add(function () mouse.toggleLock() mouse.enabled = not mouse.enabled end, "Steering Lock")

keybindPreset = "maneuver"
keybinds = keybindPresets[keybindPreset]