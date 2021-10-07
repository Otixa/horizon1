--@class STEC_Config
shipName = ""
local updateSettings = false --export: Use these settings
local inertialDampening = true --export: Start with inertial dampening on/off
local followGravity = true --export: Start with gravity follow on/off
local minRotationSpeed = 0.4 --export: Minimum speed rotation scales from
local maxRotationSpeed = 5 --export: Maximum speed rotation scales to
local rotationStep = 0.3 --export: Depermines how quickly rotation scales up
showDockingWidget = true --export: Show Docking Widget
dockingMode = 0 --export: Set docking mode (0:Manual, 1:Automatic, 2:Semi-Automatic)
setBaseOnStart = false --export: Set RTB location on start
GEAS_Alt = 4 --export:
activateFFonStart = false --export: Activate force fields on start (connected to button)
local pocket = false --export: Pocket ship?

ship.hoverHeight = GEAS_Alt
--charMovement = true --export: Enable/Disable Character Movement
ship.autoShutdown = autoShutdown
ship.altitudeHold = round2(ship.altitude,0)
ship.inertialDampeningDesired = inertialDampening
ship.followGravity = followGravity
ship.minRotationSpeed = minRotationSpeed
ship.maxRotationSpeedz = maxRotationSpeed
ship.rotationStep = rotationStep

ship.pocket = pocket


if core.setDockingMode(dockingMode) then
    system.print("Docking mode set successfully")
else
    system.print("Invalid docking mode")
end

function gearToggle()
	if unit.isAnyLandingGearExtended() == 1 then
		unit.retractLandingGears()
	else
		unit.extendLandingGears()
	end
end
function scaleViewBound(rMin,rMax,tMin,tMax,input)
    return ((input - rMin) / (rMax - rMin)) * (tMax - tMin) + tMin
end
function switchFlightMode(flightMode)
    SHUD.Init(system, unit, keybindPresets[flightMode]) 
    keybindPreset = flightMode
    if flightModeDb then flightModeDb.setStringValue("flightMode",flightMode) end
end

function switchControlMode()
    if ship.alternateCM == false then ship.alternateCM = true
        else ship.alternateCM = false end
end

function swapForceFields()
    if manualSwitches ~= nil then
        if system.isFrozen() == 1 then
            manualSwitches[1].activate()
            for _, sw in ipairs(forceFields) do
                sw.deactivate()
            end
        else
            manualSwitches[1].deactivate()
            for _, sw in ipairs(forceFields) do
                sw.activate()
            end
        end
    end

end


ship.baseAltitude = helios:closestBody(ship.customTarget):getAltitude(ship.customTarget)
system.print("Altitude: "..ship.baseAltitude)
function moveWaypointZ(vector, altitude)
    return (vector - (ship.nearestPlanet:getGravity(vector)):normalize() * (altitude))
end
if flightModeDb ~= nil then
    if flightModeDb.hasKey("BaseLocX") == 1 then
        ship.customTarget = readTargetFromDb("BaseLoc")
    else
        ship.customTarget = ship.world.position
        settingsActive = true
    end
    if flightModeDb.hasKey("BaseRotX") == 1 then
        ship.rot = readTargetFromDb("BaseRot")
    else
        ship.rot = ship.world.forward
        settingsActive = true
    end
end

local tty = DUTTY
tty.onCommand('setbase', function(a)
   
end)

keybindPresets["keyboard"] = KeybindController()
keybindPresets["keyboard"].Init = function()
    keybindPreset = "keyboard"
    mouse.enabled = false
    mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.counterGravity = false
    ship.throttle = 1
    --ship.direction.y = 0
end



-- keyboard
keybindPresets["keyboard"].keyDown.up.Add(function () ship.rotation.x = -0.15 ship.direction.z = -1 end)
keybindPresets["keyboard"].keyUp.up.Add(function () ship.rotation.x = 0 ship.direction.z = 0 end)
keybindPresets["keyboard"].keyDown.down.Add(function () ship.rotation.x = 0.15 ship.direction.z = 1 end)
keybindPresets["keyboard"].keyUp.down.Add(function () ship.rotation.x = 0 ship.direction.z = 0 end)

keybindPresets["keyboard"].keyDown.yawleft.Add(function () ship.rotation.y = -0.75 ship.rotation.z = 1 end)
keybindPresets["keyboard"].keyUp.yawleft.Add(function () ship.rotation.y = 0 ship.rotation.z = 0 ship.rotationSpeedz = ship.minRotationSpeed end)
keybindPresets["keyboard"].keyDown.yawright.Add(function () ship.rotation.y = 0.75 ship.rotation.z = -1 end)
keybindPresets["keyboard"].keyUp.yawright.Add(function () ship.rotation.y = 0 ship.rotation.z = 0 ship.rotationSpeedz = ship.minRotationSpeed end)

keybindPresets["keyboard"].keyDown.forward.Add(function () ship.direction.y = 1 end)
keybindPresets["keyboard"].keyUp.forward.Add(function () ship.direction.y = 0 end)


keybindPresets["keyboard"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["keyboard"].keyUp.backward.Add(function () ship.direction.y = 0 end)

keybindPresets["keyboard"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["keyboard"].keyUp.backward.Add(function () ship.direction.y = 0 end)


keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = 1  end) --q
keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0  end) --q
keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = -1  end) --e
keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0      end) --e


--keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = -1 end)
--keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0 end)
--keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = 1 end)
--keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0 end)

keybindPresets["keyboard"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["keyboard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["keyboard"].keyDown.stopengines.Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Cruise")
keybindPresets["keyboard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end end, "Cruise")
keybindPresets["keyboard"].keyUp.speeddown.Add(function () if mouse.enabled then mouse.unlock() mouse.enabled = false else mouse.lock() mouse.enabled = true end end, "Mouse Steering")



keybindPresets["keyboard"].keyUp.gear.Add(function () ship.holdAlt = not ship.holdAlt ship.counterGravity = ship.holdAlt end)
keybindPresets["keyboard"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["keyboard"].keyUp["option1"].Add(function () ship.inertialDampeningDesired = not ship.inertialDampeningDesired end, "Inertial Dampening")
keybindPresets["keyboard"].keyUp["option2"].Add(function () system.freeze(math.abs(1 - system.isFrozen())) swapForceFields() end,"Freeze character")
keybindPresets["keyboard"].keyUp["option3"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["keyboard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["keyboard"].keyUp["option5"].Add(function () switchFlightMode("mouse") end,"Switch Flight Mode")
keybindPresets["keyboard"].keyUp["option6"].Add(function () ship.verticalLock = not ship.verticalLock end,"Toggle Vertical Lock")
--keybindPresets["keyboard"].keyUp["option7"].Add(function () ship.verticalCruise = not ship.verticalCruise end, "Vertical Cruise")
keybindPresets["keyboard"].keyUp["option7"].Add(function() 
    ship.altitudeHold = ship.baseAltitude ship.elevatorActive = true
    ship.targetDestination = moveWaypointZ(ship.customTarget, 0)
end, "RTB")
--keybindPresets["keyboard"].keyUp["option8"].Add(function () emitter.send("door_control","open") end, "Open Door")
--keybindPresets["keyboard"].keyUp["option9"].Add(function () if ship.targetDestination == nil then ship.targetDestination = moveWaypointZ(ship.customTarget, 10000 - baseAltitude) else ship.targetDestination = nil end end, "Preset 2")
--keybindPresets["keyboard"].keyUp.option9.Add(function () if flightModeDb ~= nil then flightModeDb.clear() system.print("DB Cleared") end end,"Clear Databank")
keybindPresets["keyboard"].keyUp["option9"].Add(function ()
    ship.verticalLock = false
    ship.intertialDampening = true
    end,"Manual Mode Toggle")


    keybindPresets["mouse"] = KeybindController()
    keybindPresets["mouse"].Init = function()
        mouse.enabled = true
        mouse.lock()
        ship.ignoreVerticalThrottle = true
        ship.throttle = 1
        ship.direction.y = 0
    end
    
-- mouse
keybindPresets["mouse"].keyDown.up.Add(function () ship.direction.z = -1 end)
keybindPresets["mouse"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["mouse"].keyDown.down.Add(function () ship.direction.z = 1 end)
keybindPresets["mouse"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["mouse"].keyDown.yawleft.Add(function () ship.direction.x = 1 end)
keybindPresets["mouse"].keyUp.yawleft.Add(function () ship.direction.x = 0 end)
keybindPresets["mouse"].keyDown.yawright.Add(function () ship.direction.x = -1 end)
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
keybindPresets["mouse"].keyUp.speeddown.Add(function () if mouse.enabled then mouse.unlock() mouse.enabled = false else mouse.lock() mouse.enabled = true end end, "Keyboard")

--keybindPresets["mouse"].keyDown.lshift.Add(function () system.freeze( math.abs(1 - system.isFrozen())) end,"Freeze character")

keybindPresets["mouse"].keyUp["booster"].Add(function () holdAlt() end, "Altitude Hold")
keybindPresets["mouse"].keyUp.gear.Add(function () useGEAS = not useGEAS; updateGEAS() end)
keybindPresets["mouse"].keyUp["option1"].Add(function () ship.inertialDampening = not ship.inertialDampening end, "Inertial Dampening")
keybindPresets["mouse"].keyUp["option2"].Add(function ()  ship.targetVector = nil ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["mouse"].keyUp["option3"].Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "keyboard Control")
keybindPresets["mouse"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["mouse"].keyUp["option5"].Add(function () switchFlightMode("keyboard") end, "Switch Flight Mode")
keybindPresets["mouse"].keyUp["option6"].Add(function () switchControlMode() end, "Alternate Control Mode Switch")



if flightModeDb then
   if flightModeDb.hasKey("flightMode") == 0 then flightModeDb.setStringValue("flightMode","keyboard") end
   keybindPreset = flightModeDb.getStringValue("flightMode")
else
   system.print("No databank installed.")
   keybindPreset = "keyboard"
end
keybindPreset = "keyboard"

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


system.freeze(1)
ship.frozen = false
--ship.throttle = 0
controlStateChange = true

function normalizeTravelMode()
	if ship.controlMode == 1 and controlStateChange then
		ship.cruiseSpeed = round(ship.world.velocity:len() * 3.6,-1)
		ship.throttle = 0
		controlStateChange = false
	end
	if ship.controlMode == 0 then
		controlStateChange = true
	end
end
		
function autoLandingGear()
	if ship.world.velocity:len() >= 83.3333 then
		unit.retractLandingGears()
	else
		unit.extendLandingGears()
	end
end

--unit.setTimer("console",0.5)

function round(num, numDecimalPlaces)
local mult = 10^(numDecimalPlaces or 0)
return math.floor(num * mult + 0.5) / mult
end