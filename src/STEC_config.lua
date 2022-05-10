--@class STEC_Config
goButtonSpeed = 1050 --export: GO Button Speed
inertialDampening = false --export: Start with inertial dampening on/off
followGravity = true --export: Start with gravity follow on/off
counterGravity = false --export: Start with gravity follow on/off
rotationMin = 0.01 --export: Auto-scaling rotation speed starting point
rotationMax = 5 --export: Auto-scaling rotaiton max speed
rotationStep = 0.02 --export: Controls how quickly the rotation speed scales up
showDockingWidget = true --export: Show Docking Widget
dockingMode = 0 --export: Set docking mode (0:Manual, 1:Automatic, 2:Semi-Automatic)
vtolShip = true --export:


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
        if unit.getControlMasterModeId() == 1 then 
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
        system.print("altitudeHold: "..round2(ship.altitudeHold,0))
    else
        ship.targetVector = nil
        ship.altitudeHold = 0
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
            local target = ship.nearestPlanet:convertToWorldCoordinates(a)
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
    gotoLock("::pos{0,0,-7579.1226,195924.3281,41557.4922}")
end)
tty.onCommand('madis', function()
    gotoLock("::pos{0,0,17465536.0000,22665536.0000,-34464.0000}")
end)

keybindPresets["mouse"] = KeybindController()
keybindPresets["mouse"].Init = function()
    mouse.enabled = true
    mouse.lock()
    ship.ignoreVerticalThrottle = true
    ship.throttle = 1
    ship.direction.y = 0
end

keybindPresets["keyboard"] = KeybindController()
keybindPresets["keyboard"].Init = function()
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.ignoreHorizontalThrottle = true
    ship.throttle = 0
    ship.direction.y = 1
end


-- mouse
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

keybindPresets["mouse"].keyDown.lshift.Add(function () system.freeze( math.abs(1 - system.isFrozen())) end,"Freeze character")

keybindPresets["mouse"].keyUp["booster"].Add(function () holdAlt() end, "Altitude Hold")
keybindPresets["mouse"].keyUp["gear"].Add(function () landing = not landing; softLanding() end, "Toggle Landing Gear")
keybindPresets["mouse"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["mouse"].keyUp["option2"].Add(function ()  ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["mouse"].keyUp["option3"].Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "keyboard Control")
keybindPresets["mouse"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["mouse"].keyUp["option5"].Add(function () switchFlightMode("keyboard") end, "Switch Flight Mode")
keybindPresets["mouse"].keyUp["option6"].Add(function () switchControlMode() end, "Alternate Control Mode Switch")

-- keyboard
keybindPresets["keyboard"].keyDown.up.Add(function () ship.direction.z = 1 end)
keybindPresets["keyboard"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["keyboard"].keyDown.down.Add(function () ship.direction.z = -1 end)
keybindPresets["keyboard"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["keyboard"].keyDown.yawleft.Add(function () ship.rotation.z = -1 end)
keybindPresets["keyboard"].keyUp.yawleft.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["keyboard"].keyDown.yawright.Add(function () ship.rotation.z = 1 end)
keybindPresets["keyboard"].keyUp.yawright.Add(function () ship.rotation.z = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["keyboard"].keyDown.forward.Add(function () ship.rotation.x = -1 end)
keybindPresets["keyboard"].keyUp.forward.Add(function () ship.rotation.x = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["keyboard"].keyDown.backward.Add(function () ship.rotation.x = 1 end)
keybindPresets["keyboard"].keyUp.backward.Add(function () ship.rotation.x = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["keyboard"].keyDown.left.Add(function () ship.rotation.y = -1 end)
keybindPresets["keyboard"].keyUp.left.Add(function () ship.rotation.y = 0 ship.rotationSpeed = ship.rotationSpeedMin end)
keybindPresets["keyboard"].keyDown.right.Add(function () ship.rotation.y = 1 end)
keybindPresets["keyboard"].keyUp.right.Add(function () ship.rotation.y = 0 ship.rotationSpeed = ship.rotationSpeedMin end)

keybindPresets["keyboard"].keyDown.strafeleft.Add(function () ship.direction.x = -1 end)
keybindPresets["keyboard"].keyUp.strafeleft.Add(function () ship.direction.x = 0 end)
keybindPresets["keyboard"].keyDown.straferight.Add(function () ship.direction.x = 1 end)
keybindPresets["keyboard"].keyUp.straferight.Add(function () ship.direction.x = 0 end)


keybindPresets["keyboard"].keyDown.brake.Add(function () ship.brake = true ship.gotoLock = nil end)
keybindPresets["keyboard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["keyboard"].keyDown.stopengines.Add(function () if not SHUD.Enabled then mouse.unlock() mouse.enabled = false end end, "Free Look")
keybindPresets["keyboard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then goButton() end end, "Go Button")

keybindPresets["keyboard"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)

keybindPresets["keyboard"].keyDown.lshift.Add(function () system.freeze( math.abs(1 - system.isFrozen())) end,"Freeze character")

keybindPresets["keyboard"].keyDown.lshift.Add(function () shiftLock = true end,"Shift Modifier")
keybindPresets["keyboard"].keyUp.lshift.Add(function () shiftLock = false end)

keybindPresets["keyboard"].keyUp["booster"].Add(function () holdAlt() end, "Altitude Hold")
keybindPresets["keyboard"].keyUp["gear"].Add(function () landing = not landing; softLanding() end, "Land")
keybindPresets["keyboard"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["keyboard"].keyUp["option2"].Add(function ()  ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["keyboard"].keyUp["option3"].Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Thrust on/off")
keybindPresets["keyboard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["keyboard"].keyUp["option5"].Add(function () switchFlightMode("mouse") end, "Switch Flight Mode")
keybindPresets["keyboard"].keyUp["option6"].Add(function () switchControlMode() end, "Alternate Control Mode Switch")
keybindPresets["keyboard"].keyUp["option7"].Add(function ()
    if shiftLock then
        ship.disableVtol = not ship.disableVtol
    else
        ship.vtolPriority = not ship.vtolPriority
    end
    

end, "VTOL Priority")
keybindPresets["keyboard"].keyUp["option8"].Add(function () core.setDockingMode(0); core.undock() end,"Undock")
if flightModeDb then
   if flightModeDb.hasKey("flightMode") == 0 then flightModeDb.setStringValue("flightMode","keyboard") end
   keybindPreset = flightModeDb.getStringValue("flightMode")
else
   system.print("No databank installed.")
   keybindPreset = "keyboard"
end

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
        Position = vec3(-15973, 106446, -60333),
        Class = "target",
        Name = "Shadow Templar HQ",
        ShowDistance = true
    }
}

system.freeze(1)
ship.frozen = false
unit.deactivateGroundEngineAltitudeStabilization()