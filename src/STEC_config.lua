keybindPresets["maneuver"] = KeybindController()
keybindPresets["maneuver"].Init = function()
    mouse.enabled = true
    mouse.lock()
    ship.ignoreVerticalThrottle = false
    ship.direction.y = 0
    ship.throttle = 1
end

-- Maneuver
keybindPresets["maneuver"].down.up.Add(function () ship.direction.z = 1 end)
keybindPresets["maneuver"].up.up.Add(function () ship.direction.z = 0 end)
keybindPresets["maneuver"].down.down.Add(function () ship.direction.z = -1 end)
keybindPresets["maneuver"].up.down.Add(function () ship.direction.z = 0 end)
keybindPresets["maneuver"].down.left.Add(function () ship.direction.x = -1 end)
keybindPresets["maneuver"].up.left.Add(function () ship.direction.x = 0 end)
keybindPresets["maneuver"].down.right.Add(function () ship.direction.x = 1 end)
keybindPresets["maneuver"].up.right.Add(function () ship.direction.x = 0 end)
keybindPresets["maneuver"].down.forward.Add(function () ship.direction.y = 1 end)
keybindPresets["maneuver"].up.forward.Add(function () ship.direction.y = 0 end)
keybindPresets["maneuver"].down.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["maneuver"].up.backward.Add(function () ship.direction.y = 0 end)

keybindPresets["maneuver"].down.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["maneuver"].up.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["maneuver"].down.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["maneuver"].up.yawright.Add(function () ship.rotation.y = 0 end)

keybindPresets["maneuver"].down.brake.Add(function () ship.brake = true end)
keybindPresets["maneuver"].up.brake.Add(function () ship.brake = false end)

keybindPresets["maneuver"].down.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["maneuver"].up.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)

keybindPresets["maneuver"].up.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["maneuver"].up["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["maneuver"].up["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["maneuver"].up["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")

keybindPreset = "maneuver"

SHUD.Init(system, unit, keybindPresets[keybindPreset])