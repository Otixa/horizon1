--@class STEC_Config
shipName = ""
local updateSettings = false --export: Use these settings
local altHoldPreset1 = 100001.9  --export: Altitude Hold Preset 1
local altHoldPreset2 = 2000 --export: Altitude Hold Preset 2
local altHoldPreset3 = 500 --export: Altitude Hold Preset 3
local altHoldPreset4 = 50 --export: Altitude Hold Preset 4
local inertialDampening = true --export: Start with inertial dampening on/off
local followGravity = true --export: Start with gravity follow on/off
local minRotationSpeed = 0.01 --export: Minimum speed rotation scales from
local maxRotationSpeed = 5 --export: Maximum speed rotation scales to
local rotationStep = 0.03 --export: Depermines how quickly rotation scales up
local verticalSpeedLimitAtmo = 1100 --export: Vertical speed limit in atmosphere
local verticalSpeedLimitSpace = 4000 --export: Vertical limit in space
local autoShutdown = true --export: Auto shutoff on RTB landing

local pocket = false --export: Pocket ship?

--charMovement = true --export: Enable/Disable Character Movement
ship.autoShutdown = autoShutdown
ship.altitudeHold = round2(ship.altitude,0)
ship.inertialDampeningDesired = inertialDampening
ship.followGravity = followGravity
ship.minRotationSpeed = minRotationSpeed
ship.maxRotationSpeedz = maxRotationSpeed
ship.rotationStep = rotationStep

ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace

ship.altHoldPreset1 = altHoldPreset1
ship.altHoldPreset2 = altHoldPreset2
ship.altHoldPreset3 = altHoldPreset3
ship.altHoldPreset4 = altHoldPreset4
ship.pocket = pocket

if flightModeDb ~= nil then
    if flightModeDb.hasKey("verticalSpeedLimitAtmo") == 0 or updateSettings then 
        flightModeDb.setFloatValue("verticalSpeedLimitAtmo",verticalSpeedLimitAtmo)
        ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
    else ship.verticalSpeedLimitAtmo = flightModeDb.getFloatValue("verticalSpeedLimitAtmo") end

    if flightModeDb.hasKey("verticalSpeedLimitSpace") == 0 or updateSettings then 
        flightModeDb.setFloatValue("verticalSpeedLimitSpace",verticalSpeedLimitSpace)
        ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace
    else ship.verticalSpeedLimitSpace = flightModeDb.getFloatValue("verticalSpeedLimitSpace") end

    if flightModeDb.hasKey("altHoldPreset1") == 0 or updateSettings then 
        flightModeDb.setFloatValue("altHoldPreset1",altHoldPreset1)
        ship.altHoldPreset1 = altHoldPreset1
    else ship.altHoldPreset1 = flightModeDb.getFloatValue("altHoldPreset1") end

    if flightModeDb.hasKey("altHoldPreset2") == 0 or updateSettings then 
        flightModeDb.setFloatValue("altHoldPreset2",altHoldPreset2)
        ship.altHoldPreset2 = altHoldPreset2
    else ship.altHoldPreset2 = flightModeDb.getFloatValue("altHoldPreset2") end

    if flightModeDb.hasKey("altHoldPreset3") == 0 or updateSettings then 
        flightModeDb.setFloatValue("altHoldPreset3",altHoldPreset3)
        ship.altHoldPreset3 = altHoldPreset3
    else ship.altHoldPreset3 = flightModeDb.getFloatValue("altHoldPreset3") end

    if flightModeDb.hasKey("altHoldPreset4") == 0 or updateSettings then 
        flightModeDb.setFloatValue("altHoldPreset4",altHoldPreset4)
        ship.altHoldPreset4 = altHoldPreset4
    else ship.altHoldPreset4 = flightModeDb.getFloatValue("altHoldPreset4") end

    system.print("Preset 1: "..ship.altHoldPreset1)
    system.print("Preset 2: "..ship.altHoldPreset2)
    system.print("Preset 3: "..ship.altHoldPreset3)
    system.print("Preset 4: "..ship.altHoldPreset4)

    function writeTargetToDb(cVector, name) --customTargetX
        if flightModeDb ~= nil then
            flightModeDb.setFloatValue(name.."X", cVector.x)
            flightModeDb.setFloatValue(name.."Y", cVector.y)
            flightModeDb.setFloatValue(name.."Z", cVector.z)
            if settingsActive then settingsActive = false end
            system.print("Target Lock: "..tostring(cVector))
        end
    end
    
    function readTargetFromDb(name)
        if flightModeDb ~= nil then
            local v = vec3(0,0,0)
            v.x = flightModeDb.getFloatValue(name.."X")
            v.y = flightModeDb.getFloatValue(name.."Y")
            v.z = flightModeDb.getFloatValue(name.."Z")
    
            system.print("Target Lock: "..tostring(v))
            return v
        end
    end



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

function setBase(a)
    if a == nil then
        ship.customTarget = ship.world.position
        ship.rot = ship.world.forward
        writeTargetToDb(ship.customTarget,"BaseLoc")
        writeTargetToDb(ship.rot, "BaseRot")
        
        system.print("Base Position: "..tostring(ship.nearestPlanet:convertToMapPosition(ship.customTarget)))
    else
        if string.find(a, "::pos") ~= nil then
            ship.customTarget = ship.nearestPlanet:convertToWorldCoordinates(a)
            writeTargetToDb(ship.customTarget,"BaseLoc")
            writeTargetToDb(ship.rot, "BaseRot")
            system.print("Base Position: "..tostring(ship.nearestPlanet:convertToMapPosition(ship.customTarget)))
        end
    end
end

local tty = DUTTY
tty.onCommand('setbase', function(a)
    setBase(a)
end)

keybindPresets["keyboard"] = KeybindController()
keybindPresets["keyboard"].Init = function()
    keybindPreset = "keyboard"
    --mouse.enabled = false
    --mouse.unlock()
    ship.ignoreVerticalThrottle = true
    ship.throttle = 1
    --ship.direction.y = 0
end



-- keyboard
keybindPresets["keyboard"].keyDown.up.Add(function () ship.direction.z = 1 end)
keybindPresets["keyboard"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["keyboard"].keyDown.down.Add(function () ship.direction.z = -0.5 end)
keybindPresets["keyboard"].keyUp.down.Add(function () ship.direction.z = 0 end)

keybindPresets["keyboard"].keyDown.yawleft.Add(function () ship.rotation.z = -1 end)
keybindPresets["keyboard"].keyUp.yawleft.Add(function () ship.rotation.z = 0 ship.rotationSpeedz = ship.minRotationSpeed end)
keybindPresets["keyboard"].keyDown.yawright.Add(function () ship.rotation.z = 1 end)
keybindPresets["keyboard"].keyUp.yawright.Add(function () ship.rotation.z = 0 ship.rotationSpeedz = ship.minRotationSpeed end)

keybindPresets["keyboard"].keyDown.forward.Add(function () ship.direction.y = 1 end)
keybindPresets["keyboard"].keyUp.forward.Add(function () ship.direction.y = 0 end)


keybindPresets["keyboard"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["keyboard"].keyUp.backward.Add(function () ship.direction.y = 0 end)

keybindPresets["keyboard"].keyDown.backward.Add(function () ship.direction.y = -1 end)
keybindPresets["keyboard"].keyUp.backward.Add(function () ship.direction.y = 0 end)


keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = -1  end) --q
keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0  end) --q
keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = 1  end) --e
keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0      end) --e


--keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = -1 end)
--keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0 end)
--keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = 1 end)
--keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0 end)

keybindPresets["keyboard"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["keyboard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["keyboard"].keyDown.stopengines.Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Cruise")
keybindPresets["keyboard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end end, "Cruise")

keybindPresets["keyboard"].keyUp.gear.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["keyboard"].keyUp["option1"].Add(function () ship.inertialDampeningDesired = not ship.inertialDampeningDesired end, "Inertial Dampening")
keybindPresets["keyboard"].keyUp["option2"].Add(function () system.freeze(math.abs(1 - system.isFrozen())) swapForceFields() end,"Freeze character")
keybindPresets["keyboard"].keyUp["option3"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["keyboard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["keyboard"].keyUp["option5"].Add(function ()
    ship.verticalLock = true
    ship.lockVector = vec3(core.getConstructWorldOrientationUp())
    ship.lockPos = vec3(core.getConstructWorldPos()) + (vec3(core.getConstructWorldOrientationUp()))
    if flightModeDb ~= nil then
        flightModeDb.setFloatValue("lockVectorX",ship.lockVector.x)
        flightModeDb.setFloatValue("lockVectorY",ship.lockVector.y)
        flightModeDb.setFloatValue("lockVectorZ",ship.lockVector.z)
        flightModeDb.setFloatValue("lockPosX",ship.lockPos.x)
        flightModeDb.setFloatValue("lockPosY",ship.lockPos.y)
        flightModeDb.setFloatValue("lockPosZ",ship.lockPos.z)
    end
end,"Set Vertical Lock")
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
    ship.elevatorActive = false
    manualControl = not manualControl
    manualControlSwitch()
    end,"Manual Mode Toggle")

keybindPresets["screenui"] = KeybindController()
keybindPresets["screenui"].Init = function()
    keybindPreset = "screenui"
    ship.ignoreVerticalThrottle = true
    ship.throttle = 1
    system.freeze(1)
    ship.frozen = false
end
keybindPresets["screenui"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["screenui"].keyUp.brake.Add(function () ship.brake = false end)
keybindPresets["screenui"].keyUp["option7"].Add(function() 
    ship.altitudeHold = ship.baseAltitude ship.elevatorActive = true
    ship.targetDestination = moveWaypointZ(ship.customTarget, 0)
end, "RTB")
keybindPresets["screenui"].keyUp["option9"].Add(function ()
    ship.verticalLock = false
    ship.intertialDampening = true
    ship.elevatorActive = false
    manualControl = not manualControl
    manualControlSwitch()
    end,"Manual Mode Toggle")
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

unit.deactivateGroundEngineAltitudeStabilization()

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