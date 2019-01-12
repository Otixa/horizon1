keybindPresets["maneuver"] = KeybindController()
keybindPresets["maneuver"].Init = function()
    mouse.enabled = true
    mouse.lock()
    ship.ignoreVerticalThrottle = false
    ship.direction.y = 0
    ship.throttle = 1
end

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

keybindPresets["maneuver"].keyDown.yawleft.Add(function () ship.rotation.y = -1 end)
keybindPresets["maneuver"].keyUp.yawleft.Add(function () ship.rotation.y = 0 end)
keybindPresets["maneuver"].keyDown.yawright.Add(function () ship.rotation.y = 1 end)
keybindPresets["maneuver"].keyUp.yawright.Add(function () ship.rotation.y = 0 end)

keybindPresets["maneuver"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["maneuver"].keyUp.brake.Add(function () ship.brake = false end)

keybindPresets["maneuver"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["maneuver"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then mouse.lock() mouse.enabled = true end end)

keybindPresets["maneuver"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["maneuver"].keyUp.speeddown.Add(function () if mouse.enabled then mouse.unlock() mouse.enabled = false else mouse.lock() mouse.enabled = true end end, "Mouse Steering")

keybindPresets["maneuver"].keyUp["option1"].Add(function () ship.counterGravity = not ship.counterGravity end, "Gravity Suppression")
keybindPresets["maneuver"].keyUp["option2"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["maneuver"].keyUp["option3"].Add(function () ship.direction.y = 1 end, "Cruise Control")

keybindPreset = "maneuver"

SHUD.Init(system, unit, keybindPresets[keybindPreset])

Task(function()
    coroutine.yield()
    SHUD.FreezeUpdate = true
    local endTime = system.getTime() + 2
    while system.getTime() < endTime do
            coroutine.yield()
    end
    SHUD.FreezeUpdate = false
    SHUD.IntroPassed = true
end)

SHUD.Markers = {
    {
        Position = function() return ship.world.position + (ship.target.prograde() * 2) end,
        Class = "prograde"
    },
    {
        Position = function() return ship.world.position + (ship.target.retrograde() * 2) end,
        Class = "retrograde"
    },
    {
        Position = function() return ship.world.position + (ship.target.radial() * 2) end,
        Class = "radial"
    },
    {
        Position = function() return ship.world.position + (ship.target.antiradial() * 2) end,
        Class = "antiradial"
    },
    {
        Position = vec3(-8449.461, 105327.145, -57142.980),
        Class = "target",
        Name = "Shadow Templar HQ",
        ShowDistance = true
    }
}

ship.throttle = 0.2