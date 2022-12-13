--@class STEC_Config



ship.inertialDampening = inertialDampening
ship.followGravity = followGravity
ship.counterGravity = counterGravity
ship.rotationSpeed = rotationMin
ship.rotationSpeedMin = rotationMin
ship.rotationSpeedMax = rotationMax
ship.rotationStep = rotationStep

local landing = false
local shiftLock = false

function softLanding()
    if landing then
        ship.counterGravity = false
        ship.inertialDampening = true
        ship.followGravity = true
        ship.direction.y = 0
        ship.direction.x = 0
        unit.extendLandingGears()
        ship.throttle = 0
        if unit.getControlMode() == 1 then 
            unit.cancelCurrentControlMasterMode()
        end
    else
        ship.counterGravity = true
        ship.inertialDampening = false
        unit.retractLandingGears()
    end

end

softLanding()

function holdAlt()
    
    if ship.altitudeHold == 0 then
        ship.altitudeHold = round2(ship.altitude,0)
        --ship.inertialDampening = true
        system.print("altitudeHold: "..round2(ship.altitudeHold,0))

    else
        ship.targetVector = nil
        ship.altitudeHold = 0
        --ship.inertialDampening = false
        system.print("Altitude Hold OFF")
    end
    
end

function goButton()
    ship.direction.y = 1
    if not ship.alternateCM then
        -- Set throttle to 100% or 0
        if ship.throttle ~= 0 then
            ship.throttle = 0
        else
            ship.throttle = 1
        end
    else
        -- Set cruise speed to preset or 0
        if ship.cruiseSpeed ~= goButtonSpeed then
            ship.cruiseSpeed = goButtonSpeed
        elseif ship.cruiseSpeed == goButtonSpeed then
            ship.cruiseSpeed = 0
        end
    end
end



function switchFlightMode(flightMode)
    SHUD.Init(system, unit, keybindPresets[flightMode]) 
    keybindPreset = flightMode
    if flightModeDb then flightModeDb.setStringValue("flightMode",flightMode) end
end

function math.sign(v)
    return (v >= 0 and 1) or -1
end
function math.round(v, bracket)
    bracket = bracket or 1
    return math.floor(v/bracket + math.sign(v) * 0.5) * bracket
end

function switchControlMode()
    if ship.alternateCM == false then 
        ship.tempThrottle = ship.throttle
        ship.throttle = 0
        ship.cruiseSpeed = math.round(ship.world.velocity:len() * 3.6, 100)
        ship.alternateCM = true

    else 
        ship.tempCruise = ship.cruiseSpeed
        ship.cruiseSpeed = 0
        ship.throttle = ship.tempThrottle
        ship.alternateCM = false 
    end
end
-- ::pos{0,2,40.4608,92.2665,4.3205}
function gotoLock(a)
    --::pos{0,0,-17729.2293,198268.4583,43236.0477}
    if a ~= nil then
        if string.find(a, "::pos") ~= nil then
            x, y = helios:convertToBodyIdAndWorldCoordinates(a)
            local target = y
            --local target = helios:closestBody(a):convertToWorldCoordinates(a)
            system.print(tostring(vec3(target)))
            ship.followGravity = false
            ship.targetVector = (target - ship.world.position):normalize()
            ship.gotoLock = target
            ship.stopping = false
            system.print("Target lock: "..a)
            system.setWaypoint(a)
        end
    else
        local target = ship.nearestPlanet:convertToWorldCoordinates("::pos{0,0,-17729.2293,198268.4583,43236.0477}")
        system.print(tostring(vec3(target)))
        ship.followGravity = false
        ship.targetVector = (target - ship.world.position):normalize()
        ship.gotoLock = target
        ship.stopping = false
        system.print("Target lock: ::pos{0,0,-17729.2293,198268.4583,43236.0477}")
        system.setWaypoint("::pos{0,0,-17729.2293,198268.4583,43236.0477}")
    end
    
end

-- ::pos{0,2,40.4652,92.2361,101.1699}
local tty = DUTTY
tty.onCommand('goto', function(a)
    gotoLock(a)
end)
-- Testing commands to be removed
tty.onCommand('goto1', function()
    gotoLock("::pos{0,0,41351.6719,205839.2344,51086.4180}")
end)
tty.onCommand('goto2', function()
    gotoLock("::pos{0,0,-17729.2293,198268.4583,43236.0477}")
end)
tty.onCommand('goto5su', function()
    gotoLock("::pos{0,0,439874.4688,-363701.4062,749901.8750}")
end)
tty.onCommand('goto10su', function()
    gotoLock("::pos{0,0,910554.2500,-951981.0625,1494420.1250}")
end)
tty.onCommand('home', function()
    gotoLock("::pos{0,2,28.4911,76.0307,132054.2656}")
end)
tty.onCommand('madis', function()
    gotoLock("::pos{0,0,17465536.0000,22665536.0000,-34464.0000}")
end)

--keybindPresets["mouse"] = KeybindController()
--keybindPresets["mouse"].Init = function()
--    mouse.enabled = true
--    mouse.lock()
--    ship.ignoreVerticalThrottle = true
--    ship.throttle = 1
--    ship.direction.y = 0
--end

keybindPresets["standard"] = KeybindController()
keybindPresets["standard"].Init = function()
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.ignoreHorizontalThrottle = true
    ship.inertialDampening = false
    ship.throttle = 0
    ship.direction.y = 1
end

keybindPresets["maneuver"] = KeybindController()
keybindPresets["maneuver"].Init = function()
    keybindPreset = "maneuver"
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.inertialDampening = true
    ship.followGravity = true
    ship.throttle = 1
    ship.direction.y = 0
end



-- Maneuver
keybindPresets["maneuver"].keyDown.up.Add(function () ship.direction.z = 1 if not ship.counterGravity then ship.counterGravity = true end end) --space
keybindPresets["maneuver"].keyUp.up.Add(function () ship.direction.z = 0 end) --space
keybindPresets["maneuver"].keyDown.down.Add(function () ship.direction.z = -1 end) --c
keybindPresets["maneuver"].keyUp.down.Add(function () ship.direction.z = 0 end) --c

keybindPresets["maneuver"].keyDown.yawleft.Add(function () ship.rotation.z = -1 end) --a
keybindPresets["maneuver"].keyUp.yawleft.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end)--a
keybindPresets["maneuver"].keyDown.yawright.Add(function () ship.rotation.z = 1 end) --d
keybindPresets["maneuver"].keyUp.yawright.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end) --d

keybindPresets["maneuver"].keyDown.forward.Add(function () ship.direction.y = 1 end) --w
keybindPresets["maneuver"].keyUp.forward.Add(function () ship.direction.y = 0 end) --w


keybindPresets["maneuver"].keyDown.backward.Add(function () ship.direction.y = -1 end) --s
keybindPresets["maneuver"].keyUp.backward.Add(function () ship.direction.y = 0 end) --s

keybindPresets["maneuver"].keyDown.left.Add(function () ship.direction.x = -1  end) --q
keybindPresets["maneuver"].keyUp.left.Add(function () ship.direction.x = 0  end) --q
keybindPresets["maneuver"].keyDown.right.Add(function () ship.direction.x = 1  end) --e
keybindPresets["maneuver"].keyUp.right.Add(function () ship.direction.x = 0      end) --e

keybindPresets["maneuver"].keyDown.lshift.Add(function () shiftLock = true end,"Shift Modifier")
keybindPresets["maneuver"].keyUp.lshift.Add(function () shiftLock = false end)


keybindPresets["maneuver"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["maneuver"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["maneuver"].keyDown.stopengines.Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Cruise")
keybindPresets["maneuver"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end end, "Cruise")

keybindPresets["maneuver"].keyUp.gear.Add(function () useGEAS = not useGEAS; updateGEAS() end)
keybindPresets["maneuver"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["maneuver"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["maneuver"].keyUp["option2"].Add(function () ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["maneuver"].keyUp["option3"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["maneuver"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["maneuver"].keyUp["option5"].Add(function () switchFlightMode("standard") end, "Switch Flight Mode")

-- Standard
keybindPresets["standard"].keyDown.up.Add(function () ship.direction.z = 1 end)
keybindPresets["standard"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["standard"].keyDown.down.Add(function () ship.direction.z = -1 end)
keybindPresets["standard"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["standard"].keyDown.yawleft.Add(function () ship.rotation.z = -1 end)
keybindPresets["standard"].keyUp.yawleft.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["standard"].keyDown.yawright.Add(function () ship.rotation.z = 1 end)
keybindPresets["standard"].keyUp.yawright.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["standard"].keyDown.forward.Add(function () ship.rotation.x = -1 end)
keybindPresets["standard"].keyUp.forward.Add(function () ship.rotation.x = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["standard"].keyDown.backward.Add(function () ship.rotation.x = 1 end)
keybindPresets["standard"].keyUp.backward.Add(function () ship.rotation.x = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["standard"].keyDown.left.Add(function () ship.rotation.y = -1 end)
keybindPresets["standard"].keyUp.left.Add(function () ship.rotation.y = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["standard"].keyDown.right.Add(function () ship.rotation.y = 1 end)
keybindPresets["standard"].keyUp.right.Add(function () ship.rotation.y = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["standard"].keyDown.strafeleft.Add(function () ship.direction.x = -1 end)
keybindPresets["standard"].keyUp.strafeleft.Add(function () ship.direction.x = 0 end)
keybindPresets["standard"].keyDown.straferight.Add(function () ship.direction.x = 1 end)
keybindPresets["standard"].keyUp.straferight.Add(function () ship.direction.x = 0 end)


keybindPresets["standard"].keyDown.brake.Add(function () ship.brake = true ship.gotoLock = nil end)
keybindPresets["standard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["standard"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["standard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then goButton() end end, "Go Button")

keybindPresets["standard"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["standard"].keyDown.lshift.Add(function () player.freeze( math.abs(1 - player.isFrozen())) end,"Freeze character")

keybindPresets["standard"].keyDown.lshift.Add(function () shiftLock = true end,"Shift Modifier")
keybindPresets["standard"].keyUp.lshift.Add(function () shiftLock = false end)

keybindPresets["standard"].keyUp["booster"].Add(function () holdAlt() end, "Altitude Hold")
keybindPresets["standard"].keyUp["gear"].Add(function () landing = not landing; softLanding() end, "Land")
keybindPresets["standard"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["standard"].keyUp["option2"].Add(function ()  ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["standard"].keyUp["option3"].Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Thrust on/off")
keybindPresets["standard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["standard"].keyUp["option5"].Add(function () switchFlightMode("maneuver") end, "Switch Flight Mode")
keybindPresets["standard"].keyUp["option6"].Add(function () switchControlMode() end, "Alternate Control Mode Switch")
keybindPresets["standard"].keyUp["option7"].Add(function ()
    if shiftLock then
        ship.disableVtol = not ship.disableVtol
    else
        ship.vtolPriority = not ship.vtolPriority
    end
    

end, "VTOL Priority")
keybindPresets["standard"].keyUp["option8"].Add(function () core.setDockingMode(0); core.undock() end,"Undock")
keybindPresets["standard"].keyUp["option9"].Add(function () flightModeDb.clear() system.print("DB Cleared") end,"Clear DB")

--[[ mouse
keybindPresets["mouse"].keyDown.up.Add(function () landing = false softLanding() ship.direction.z = 1 end)
keybindPresets["mouse"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["mouse"].keyDown.down.Add(function () ship.direction.z = -1 end)
keybindPresets["mouse"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["mouse"].keyDown.yawleft.Add(function () ship.direction.x = -1 end)
keybindPresets["mouse"].keyUp.yawleft.Add(function () ship.direction.x = 0 end)
keybindPresets["mouse"].keyDown.yawright.Add(function () ship.direction.x = 1 end)
keybindPresets["mouse"].keyUp.yawright.Add(function () ship.direction.x = 0 end)

keybindPresets["mouse"].keyDown.forward.Add(function () ship.direction.y = 1 end)
keybindPresets["mouse"].keyUp.forward.Add(function () ship.direction.y = 0 end)
keybindPresets["mouse"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["mouse"].keyUp.backward.Add(function () ship.direction.y = 0 end)

keybindPresets["mouse"].keyDown.left.Add(function () ship.rotation.y = -1 end)
keybindPresets["mouse"].keyUp.left.Add(function () ship.rotation.y = 0 end)
keybindPresets["mouse"].keyDown.right.Add(function () ship.rotation.y = 1 end)
keybindPresets["mouse"].keyUp.right.Add(function () ship.rotation.y = 0 end)

keybindPresets["mouse"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["mouse"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["mouse"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["mouse"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then goButton() end end, "Go Button")

keybindPresets["mouse"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["mouse"].keyUp.speeddown.Add(function () if mouse.enabled then mouse.unlock() mouse.enabled = false else mouse.lock() mouse.enabled = true end end, "Mouse Steering")

keybindPresets["mouse"].keyDown.lshift.Add(function () player.freeze( math.abs(1 - player.isFrozen())) end,"Freeze character")

keybindPresets["mouse"].keyUp["booster"].Add(function () holdAlt() end, "Altitude Hold")
keybindPresets["mouse"].keyUp["gear"].Add(function () landing = not landing; softLanding() end, "Toggle Landing Gear")
keybindPresets["mouse"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["mouse"].keyUp["option2"].Add(function ()  ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["mouse"].keyUp["option3"].Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "keyboard Control")
keybindPresets["mouse"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["mouse"].keyUp["option5"].Add(function () switchFlightMode("standard") end, "Switch Flight Mode")
keybindPresets["mouse"].keyUp["option6"].Add(function () switchControlMode() end, "Alternate Control Mode Switch")
--]]
if flightModeDb then
    if flightModeDb.hasKey("flightMode") == 0 then flightModeDb.setStringValue("flightMode","standard") end
    keybindPreset = flightModeDb.getStringValue("flightMode")
    if keybindPreset == "keyboard" then
        flightModeDb.clear() 
        system.print("DB Cleared")
        keybindPreset = "standard"

    end
 else
    system.print("No databank installed.")
    keybindPreset = "standard"
 end


SHUD.Init(system, unit, keybindPresets[keybindPreset])

Task(function()
    coroutine.yield()
    SHUD.FreezeUpdate = true
    local endTime = system.getArkTime() + 2
    while system.getArkTime() < endTime do
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
        Position = vec3(-15973, 106446, -60333),
        Class = "target",
        Name = "Shadow Templar HQ",
        ShowDistance = true
    }
}

player.freeze(1)
ship.frozen = false
unit.deactivateGroundEngineAltitudeStabilization()