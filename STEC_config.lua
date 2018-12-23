    keybindPresets["maneuver"] = KeybindController()
    keybindPresets["cruise"] = KeybindController()

    keybindPresets["maneuver"].keyDown.yawleft.Add(function () ship.rotation.y = -1 end)
    keybindPresets["maneuver"].keyUp.yawleft.Add(function () ship.rotation.y = 0 end)
    keybindPresets["maneuver"].keyDown.yawright.Add(function () ship.rotation.y = 1 end)
    keybindPresets["maneuver"].keyUp.yawright.Add(function () ship.rotation.y = 0 end)

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

    keybindPresets["maneuver"].keyDown.brake.Add(function () ship.brake = true end)
    keybindPresets["maneuver"].keyUp.brake.Add(function () ship.brake = false end)

    keybindPresets["maneuver"].keyUp.speeddown.Add(function () ship.throttleUp() end, "Increase Throttle")
    keybindPresets["maneuver"].keyUp.speedup.Add(function () ship.throttleDown() end, "Decrease Throttle")

    keybindPresets["maneuver"].keyDown.stopengines.Add(function () mouse.unlock() mouse.enabled = false end, "Free Look")
    keybindPresets["maneuver"].keyUp.stopengines.Add(function () mouse.lock() mouse.enabled = true end)

    keybindPresets["maneuver"].keyUp["option1"].Add(function () mouse.toggleLock() mouse.enabled = not mouse.enabled end, "Steering Lock")
    keybindPresets["maneuver"].keyUp["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Assist")
    keybindPresets["maneuver"].keyUp["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")
    keybindPresets["maneuver"].keyUp["option5"].Add(function () if ship.targetVector == ship.target.prograde then ship.targetVector = nil else ship.targetVector = ship.target.prograde end end, "Lock Prograde")
    keybindPresets["maneuver"].keyUp["option6"].Add(function () if ship.targetVector == ship.target.retrograde then ship.targetVector = nil else ship.targetVector = ship.target.retrograde end end, "Lock Retrograde")

    keybindPresets["maneuver"].keyUp["option9"].Add(function () SHUD.showKeybinds = not SHUD.showKeybinds end, "Toggle Keybinds")

    keybindPreset = "maneuver"
    keybinds = keybindPresets[keybindPreset]