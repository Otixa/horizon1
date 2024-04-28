--@class STEC_Config

local P = system.print

ship.hoverHeight = GEAS_Alt
ship.autoShutdown = autoShutdown
ship.altitudeHold = round2(ship.altitude,0)
ship.inertialDampeningDesired = inertialDampening
ship.followGravity = followGravity
ship.minRotationSpeed = minRotationSpeed
ship.maxRotationSpeedz = maxRotationSpeed
ship.rotationStep = rotationStep

ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace
ship.approachSpeed = approachSpeed

ship.altHoldPreset1 = altHoldPreset1
ship.altHoldPreset2 = altHoldPreset2
ship.altHoldPreset3 = altHoldPreset3
ship.altHoldPreset4 = altHoldPreset4
ship.deviationThreshold = deviationThreshold
ship.pocket = pocket
ship.breadCrumbDist = breadCrumbDist

local shiftLock = false

function writeVecToDb(cVector, name) --customTargetX
	if flightModeDb and name and vec3.isvector(cVector) then
		flightModeDb.setFloatValue(name.."X", cVector.x)
		flightModeDb.setFloatValue(name.."Y", cVector.y)
		flightModeDb.setFloatValue(name.."Z", cVector.z)
		if settingsActive then settingsActive = false end
		P("[I] Wrote "..name..": "..tostring(cVector))
	end
end

function readVecFromDb(name)
	if flightModeDb and name then
		local v = vec3(0,0,0)
		v.x = flightModeDb.getFloatValue(name.."X")
		v.y = flightModeDb.getFloatValue(name.."Y")
		v.z = flightModeDb.getFloatValue(name.."Z")
		P("[I] Read "..name..": "..tostring(v))
		return v
	end
end

function gearToggle()
	if unit.isAnyLandingGearExtended() then
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
    ship.alternateCM = not ship.alternateCM
end

function swapForceFields()
    if manualSwitches and #manualSwitches > 0 then
        if player.isFrozen() then
            manualSwitches[1].activate()
            for _, sw in ipairs(forceFields) do
                sw.retract()
            end
        else
            manualSwitches[1].deactivate()
            for _, sw in ipairs(forceFields) do
                sw.deploy()
            end
        end
    end
end
function setBase(a)
    ship.rot = ship.world.right:cross(ship.nearestPlanet:getGravity(construct.getWorldPosition()))
    if type(a) ~= "string" or a == "" then
        ship.baseLoc = ship.world.position
    elseif string.find(a, "::pos") ~= nil then
		ship.baseLoc = ship.nearestPlanet:convertToWorldCoordinates(a)
    end
	writeVecToDb(ship.baseLoc,"BaseLoc")
	writeVecToDb(ship.rot, "BaseRot")
    system.print("Base: "..tostring(ship.nearestPlanet:convertToMapPosition(ship.baseLoc)))
    config.rtb = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
    ioScheduler.queueData(config)
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
keybindPresets["keyboard"].keyDown.up.Add(function () ship.direction.z = 1 if not ship.counterGravity then ship.counterGravity = true end end)
keybindPresets["keyboard"].keyUp.up.Add(function () ship.direction.z = 0 end)
keybindPresets["keyboard"].keyDown.down.Add(function () ship.direction.z = -1 end)
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


keybindPresets["keyboard"].keyDown.left.Add(function () ship.direction.x = -1 end) --q
keybindPresets["keyboard"].keyUp.left.Add(function () ship.direction.x = 0 end) --q
keybindPresets["keyboard"].keyDown.right.Add(function () ship.direction.x = 1 end) --e
keybindPresets["keyboard"].keyUp.right.Add(function () ship.direction.x = 0 end) --e

keybindPresets["keyboard"].keyDown.lshift.Add(function () shiftLock = true end,"Shift Modifier")
keybindPresets["keyboard"].keyUp.lshift.Add(function () shiftLock = false end)

keybindPresets["keyboard"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["keyboard"].keyUp.brake.Add(function () ship.brake = false end)

--keybindPresets["keyboard"].keyDown.stopengines.Add(function () if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end, "Cruise")
keybindPresets["keyboard"].keyUp.stopengines.Add(function () SHUD.Select() if not SHUD.Enabled then if ship.direction.y == 1 then ship.direction.y = 0 else ship.direction.y = 1 end end end, "Cruise")

keybindPresets["keyboard"].keyUp.gear.Add(function () useGEAS = not useGEAS; updateGEAS() end)
keybindPresets["keyboard"].keyUp.speedup.Add(function () SHUD.Enabled = not SHUD.Enabled end)
keybindPresets["keyboard"].keyUp["option1"].Add(function () ship.inertialDampeningDesired = not ship.inertialDampeningDesired end, "Inertial Dampening")
keybindPresets["keyboard"].keyUp["option2"].Add(function () player.freeze(not player.isFrozen()); swapForceFields() end,"Freeze character")
keybindPresets["keyboard"].keyUp["option3"].Add(function () ship.followGravity = not ship.followGravity end, "Gravity Follow")
keybindPresets["keyboard"].keyUp["option4"].Add(function () ship.counterGravity = not ship.counterGravity end, "Counter Gravity")
keybindPresets["keyboard"].keyUp["option5"].Add(function ()
    ship.verticalLock = true
    ship.lockVector = vec3(construct.getWorldOrientationUp())
    ship.lockPos = vec3(construct.getWorldPosition()) + (vec3(construct.getWorldOrientationUp()))
    if flightModeDb then
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
    ship.targetDestination = moveWaypointZ(ship.baseLoc, 0)
end, "RTB")
keybindPresets["keyboard"].keyUp["option8"].Add(function () construct.setDockingMode(1); construct.undock() end,"Undock")
--keybindPresets["keyboard"].keyUp["option8"].Add(function () emitter.send("door_control","open") end, "Open Door")
--keybindPresets["keyboard"].keyUp["option9"].Add(function () if ship.targetDestination == nil then ship.targetDestination = moveWaypointZ(ship.baseLoc, 10000 - baseAltitude) else ship.targetDestination = nil end end, "Preset 2")
--keybindPresets["keyboard"].keyUp.option9.Add(function () if flightModeDb ~= nil then flightModeDb.clear() system.print("DB Cleared") end end,"Clear Databank")
keybindPresets["keyboard"].keyUp["option9"].Add(function ()
    if shiftLock then
        flightModeDb.clear() system.print("DB Cleared");
    else
        ship.verticalLock = false
        ship.intertialDampening = true
        ship.elevatorActive = false
        config.manualControl = not config.manualControl
        manualControlSwitch()
    end
end,"Manual Mode Toggle")

keybindPresets["screenui"] = KeybindController()
keybindPresets["screenui"].Init = function()
    keybindPreset = "screenui"
    ship.ignoreVerticalThrottle = true
    ship.throttle = 1
    player.freeze(true)
    ship.frozen = false
end
keybindPresets["screenui"].keyDown.lshift.Add(function () shiftLock = true end,"Shift Modifier")
keybindPresets["screenui"].keyUp.lshift.Add(function () shiftLock = false end)
keybindPresets["screenui"].keyDown.brake.Add(function () ship.brake = true end)
keybindPresets["screenui"].keyUp.brake.Add(function () ship.brake = false end)
keybindPresets["screenui"].keyUp["option7"].Add(function()
    ship.altitudeHold = ship.baseAltitude ship.elevatorActive = true
    ship.targetDestination = moveWaypointZ(ship.baseLoc, 0)
end, "RTB")
keybindPresets["screenui"].keyUp["option8"].Add(function () construct.setDockingMode(1); construct.undock() end,"Undock")
keybindPresets["screenui"].keyUp["option9"].Add(function ()
    if shiftLock then
        flightModeDb.clear() system.print("DB Cleared");
    else
        ship.verticalLock = false
        ship.intertialDampening = true
        ship.elevatorActive = false
        config.manualControl = not config.manualControl
        manualControlSwitch()
    end
    end,"Manual Mode Toggle")

-- Note: in this elevator script version, the flight mode still contains "keyboard",
-- which in later versions of Horizon is replaced with Standard/Maneuver
if flightModeDb then
   if not flightModeDb.hasKey("flightMode") then flightModeDb.setStringValue("flightMode","keyboard") end
   keybindPreset = flightModeDb.getStringValue("flightMode")
else
   keybindPreset = "keyboard"
end
keybindPreset = "keyboard"

SHUD.Init(system, unit, keybindPresets[keybindPreset])

Task(function()
    coroutine.yield()
    SHUD.FreezeUpdate = true
	-- artificial pause to let system initialize
    local endTime = system.getArkTime() + 2
    while system.getArkTime() < endTime do
        coroutine.yield()
    end
    SHUD.FreezeUpdate = false
    SHUD.IntroPassed = true
end)

player.freeze(true)
ship.frozen = false
--ship.throttle = 0
function updateGEAS()
    if useGEAS then
        unit.activateGroundEngineAltitudeStabilization(ship.hoverHeight)
    else
        unit.deactivateGroundEngineAltitudeStabilization()
    end
end

updateGEAS()

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


function STEC_configInit()
	-- default to current location/rotation
	ship.baseLoc = ship.world.position
	ship.rot = ship.world.forward

	if not flightModeDb then
		P("[E] No databank found!")
	else
		P("[I] Databank found.")
		if not flightModeDb.hasKey("verticalSpeedLimitAtmo") or updateSettings then
			flightModeDb.setFloatValue("verticalSpeedLimitAtmo",verticalSpeedLimitAtmo)
			ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
		else ship.verticalSpeedLimitAtmo = flightModeDb.getFloatValue("verticalSpeedLimitAtmo") end

		if not flightModeDb.hasKey("verticalSpeedLimitSpace") or updateSettings then
			flightModeDb.setFloatValue("verticalSpeedLimitSpace",verticalSpeedLimitSpace)
			ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace
		else ship.verticalSpeedLimitSpace = flightModeDb.getFloatValue("verticalSpeedLimitSpace") end

		if not flightModeDb.hasKey("approachSpeed") or updateSettings then
			flightModeDb.setFloatValue("approachSpeed",approachSpeed)
			ship.approachSpeed = approachSpeed
		else ship.approachSpeed = flightModeDb.getFloatValue("approachSpeed") end

		if not flightModeDb.hasKey("altHoldPreset1") or updateSettings then
			flightModeDb.setFloatValue("altHoldPreset1",altHoldPreset1)
			ship.altHoldPreset1 = altHoldPreset1
		else ship.altHoldPreset1 = flightModeDb.getFloatValue("altHoldPreset1") end

		if not flightModeDb.hasKey("altHoldPreset2") or updateSettings then
			flightModeDb.setFloatValue("altHoldPreset2",altHoldPreset2)
			ship.altHoldPreset2 = altHoldPreset2
		else ship.altHoldPreset2 = flightModeDb.getFloatValue("altHoldPreset2") end

		if not flightModeDb.hasKey("altHoldPreset3") or updateSettings then
			flightModeDb.setFloatValue("altHoldPreset3",altHoldPreset3)
			ship.altHoldPreset3 = altHoldPreset3
		else ship.altHoldPreset3 = flightModeDb.getFloatValue("altHoldPreset3") end

		if not flightModeDb.hasKey("altHoldPreset4") or updateSettings then
			flightModeDb.setFloatValue("altHoldPreset4",altHoldPreset4)
			ship.altHoldPreset4 = altHoldPreset4
		else ship.altHoldPreset4 = flightModeDb.getFloatValue("altHoldPreset4") end

		if flightModeDb.hasKey("BaseLocX") then
			ship.baseLoc = readVecFromDb("BaseLoc")
			-- only load rotation if location exists
			if flightModeDb.hasKey("BaseRotX") then
				ship.rot = readVecFromDb("BaseRot")
			else
				config.setBaseActive = true
			end
		else
			config.setBaseActive = true
		end
	end

	if config.setBaseActive or ship.baseLoc == vec3() then
		config.rtb = helios:closestBody(ship.world.position):getAltitude(ship.world.position)
		P("[I] No base location set!")
	else
		config.rtb = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
		ship.baseAltitude = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
		P("Base location: "..tostring(ship.baseLoc))
		P("Altitude: "..tostring(ship.baseAltitude))
	end
end

function ElevatorInit()
	config.floors.floor1 = ship.altHoldPreset1
	config.floors.floor2 = ship.altHoldPreset2
	config.floors.floor3 = ship.altHoldPreset3
	config.floors.floor4 = ship.altHoldPreset4
	elevatorName = construct.getName()
	if ship.baseLoc and ship.baseLoc ~= vec3() then
		config.rtb = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
	end
	config.targetAlt = 0

	P("Preset 1: "..config.floors.floor1)
	P("Preset 2: "..config.floors.floor2)
	P("Preset 3: "..config.floors.floor3)
	P("Preset 4: "..config.floors.floor4)

	ioScheduler.defaultData = stats
	ioScheduler.queueData(config)
	ioScheduler.queueData(fuelAtmo)
	ioScheduler.queueData(fuelSpace)
end
