keybindPresets["maneuver"] = KeybindController()
keybindPresets["cruise"] = KeybindController()

-- Maneuver
keybindPresets["maneuver"].keyDown.up.Add(function () ship.direction.z = 1 end)
keybindPresets["maneuver"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["maneuver"].keyDown.down.Add(function () ship.direction.z = -1 end)
keybindPresets["maneuver"].keyUp.down.Add(function () ship.direction.z = 0 end)
keybindPresets["maneuver"].keyDown.left.Add(function () ship.direction.x = -1 end)
keybindPresets["maneuver"].keyUp.left.Add(function () ship.direction.x = 0 end)
keybindPresets["maneuver"].keyDown.right.Add(function () ship.direction.x = 1 end)
keybindPresets["maneuver"].keyUp.right.Add(function () ship.direction.x = 0 end)
keybindPresets["maneuver"].keyDown.forward.Add(function () ship.direction.y = 1 end)
keybindPresets["maneuver"].keyUp.forward.Add(function () ship.direction.y = 0 end)
keybindPresets["maneuver"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["maneuver"].keyUp.backward.Add(function () ship.direction.y = 0 end)

-- Cruise
keybindPresets["cruise"].keyDown.up.Add(function () ship.rotation.z = 1 end)
keybindPresets["cruise"].keyUp.up.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].keyDown.down.Add(function () ship.rotation.z = -1 end)
keybindPresets["cruise"].keyUp.down.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].keyDown.left.Add(function () ship.rotation.x = -1 end)
keybindPresets["cruise"].keyUp.left.Add(function () ship.rotation.x = 0 end)
keybindPresets["cruise"].keyDown.right.Add(function () ship.rotation.x = 1 end)
keybindPresets["cruise"].keyUp.right.Add(function () ship.rotation.x = 0 end)
keybindPresets["cruise"].keyDown.forward.Add(function () ship.rotation.x = 1 end)
keybindPresets["cruise"].keyUp.forward.Add(function () ship.rotation.x = 0 end)
keybindPresets["cruise"].keyDown.backward.Add(function () ship.rotation.x = -1 end)
keybindPresets["cruise"].keyUp.backward.Add(function () ship.rotation.x = 0 end)

-- Both
keybindPresets["maneuver"].keyDown.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["maneuver"].keyUp.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["maneuver"].keyDown.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["maneuver"].keyUp.yawright.Add(function () ship.rotation.y = 0 end)
keybindPresets["cruise"].keyDown.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["cruise"].keyUp.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["cruise"].keyDown.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["cruise"].keyUp.yawright.Add(function () ship.rotation.y = 0 end)

keybindPresets["maneuver"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["maneuver"].keyUp.brake.Add(function () ship.brake = false end)
keybindPresets["cruise"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["cruise"].keyUp.brake.Add(function () ship.brake = false end)

keybindPresets["maneuver"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["maneuver"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)
keybindPresets["cruise"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["cruise"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)

keybindPresets["maneuver"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["cruise"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["maneuver"].keyUp["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["maneuver"].keyUp["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Assist")
keybindPresets["maneuver"].keyUp["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")
keybindPresets["cruise"].keyUp["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["cruise"].keyUp["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Assist")
keybindPresets["cruise"].keyUp["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")

keybindPreset = "maneuver"
keybinds = keybindPresets[keybindPreset]

SHUD.Init(system, unit, keybinds)