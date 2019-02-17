keybindPresets["cruise"] = KeybindController()
keybindPresets["cruise"].Init = function()
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.throttle = 0
    ship.direction.y = 1
end

-- Cruise
keybindPresets["cruise"].down.up.Add(function () ship.direction.z = 1 end)
keybindPresets["cruise"].up.up.Add(function () ship.direction.z = 0 end)
keybindPresets["cruise"].down.down.Add(function () ship.direction.z = -1 end)
keybindPresets["cruise"].up.down.Add(function () ship.direction.z = 0 end)

keybindPresets["cruise"].down.left.Add(function () ship.rotation.z = -1 end)
keybindPresets["cruise"].up.left.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].down.right.Add(function () ship.rotation.z = 1 end)
keybindPresets["cruise"].up.right.Add(function () ship.rotation.z = 0 end)
keybindPresets["cruise"].down.forward.Add(function () ship.rotation.x = -1 end)
keybindPresets["cruise"].up.forward.Add(function () ship.rotation.x = 0 end)
keybindPresets["cruise"].down.backward.Add(function () ship.rotation.x = 1 end)
keybindPresets["cruise"].up.backward.Add(function () ship.rotation.x = 0 end)

keybindPresets["cruise"].down.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["cruise"].up.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["cruise"].down.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["cruise"].up.yawright.Add(function () ship.rotation.y = 0 end)

keybindPresets["cruise"].down.brake.Add(function () ship.brake = true end)
keybindPresets["cruise"].up.brake.Add(function () ship.brake = false end)

keybindPresets["cruise"].down.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["cruise"].up.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)

keybindPresets["cruise"].up.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["cruise"].up["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["cruise"].up["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["cruise"].up["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")

keybindPreset = "cruise"

SHUD.Init(system, unit, keybindPresets[keybindPreset])