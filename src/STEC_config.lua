--@class STEC_Config


function gearToggle()
	if unit.isAnyLandingGearExtended() == 1 then
		unit.retractLandingGears()
	else
		unit.extendLandingGears()
	end
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

ship.verticalCruiseSpeed = 100


keybindPresets["keyboard"] = KeybindController()
keybindPresets["keyboard"].Init = function()
    mouse.enabled = false
    mouse.unlock()
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


keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = -1 end)
keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0 end)
keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = 1 end)
keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0 end)

keybindPresets["keyboard"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["keyboard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["keyboard"].keyDown.stopengines.Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Cruise")
keybindPresets["keyboard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end end, "Cruise")



keybindPresets["keyboard"].keyUp.gear.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["keyboard"].keyUp["option1"].Add(function () ship.inertialDampeningDesired = not ship.inertialDampeningDesired end, "Inertial Dampening")
keybindPresets["keyboard"].keyUp["option2"].Add(function () system.freeze(math.abs(1 - system.isFrozen())) end,"Freeze character")
keybindPresets["keyboard"].keyUp["option3"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["keyboard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["keyboard"].keyUp["option5"].Add(function ()
    ship.verticalLock = true
    ship.lockVector = vec3(core.getConstructWorldOrientationUp())
    ship.lockPos = vec3(core.getConstructWorldPos()) + (vec3(core.getConstructWorldOrientationUp()) * 1.235)
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
keybindPresets["keyboard"].keyUp["option7"].Add(function () ship.verticalCruise = not ship.verticalCruise end, "Vertical Cruise")
keybindPresets["keyboard"].keyUp["option8"].Add(function () ship.altitudeHold = ship.altHoldPreset1 ship.altitudeHoldToggle = true end, "Preset 1")
keybindPresets["keyboard"].keyUp["option9"].Add(function () ship.altitudeHold = ship.altHoldPreset2 ship.altitudeHoldToggle = true end, "Preset 2")

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