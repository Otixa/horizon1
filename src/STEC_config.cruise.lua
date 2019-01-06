keybindPresets["cruise"] = KeybindController()
keybindPresets["cruise"].Init = function()
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.throttle = 0
    ship.direction.y = 1
end

-- Cruise
keybindPresets["cruise"].keyDown.up.Add(function () ship.direction.z = 1 end)
keybindPresets["cruise"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["cruise"].keyDown.down.Add(function () ship.direction.z = -1 end)
keybindPresets["cruise"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["cruise"].keyDown.left.Add(function () ship.rotation.z = -1 end)
keybindPresets["cruise"].keyUp.left.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].keyDown.right.Add(function () ship.rotation.z = 1 end)
keybindPresets["cruise"].keyUp.right.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].keyDown.forward.Add(function () ship.rotation.x = -1 end)
keybindPresets["cruise"].keyUp.forward.Add(function () ship.rotation.x = 0 end)
keybindPresets["cruise"].keyDown.backward.Add(function () ship.rotation.x = 1 end)
keybindPresets["cruise"].keyUp.backward.Add(function () ship.rotation.x = 0 end)

keybindPresets["cruise"].keyDown.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["cruise"].keyUp.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["cruise"].keyDown.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["cruise"].keyUp.yawright.Add(function () ship.rotation.y = 0 end)

keybindPresets["cruise"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["cruise"].keyUp.brake.Add(function () ship.brake = false end)

keybindPresets["cruise"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["cruise"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)

keybindPresets["cruise"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["cruise"].keyUp["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["cruise"].keyUp["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["cruise"].keyUp["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")

keybindPreset = "cruise"

SHUD.Init(system, unit, keybindPresets[keybindPreset])