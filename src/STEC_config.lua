--@class STEC_Config
local P, clamp = system.print, utils.clamp

ship.hoverHeight = tonumber(GEAS_Alt) or 10
ship.autoShutdown = autoShutdown == true
ship.altitudeHold = round2(ship.altitude,2)
ship.inertialDampeningDesired = inertialDampening == true
ship.followGravity = followGravity == true
ship.minRotationSpeed = tonumber(minRotationSpeed) or 0.01
ship.maxRotationSpeedz = tonumber(maxRotationSpeed) or 5
ship.rotationStep = tonumber(rotationStep) or 0.025

ship.verticalSpeedLimitAtmo = tonumber(verticalSpeedLimitAtmo) or 1100
ship.verticalSpeedLimitSpace = tonumber(verticalSpeedLimitSpace) or 4000
ship.approachSpeed = tonumber(approachSpeed) or 100

ship.altHoldPreset1 = tonumber(altHoldPreset1) or 0
ship.altHoldPreset2 = tonumber(altHoldPreset2) or 0
ship.altHoldPreset3 = tonumber(altHoldPreset3) or 0
ship.altHoldPreset4 = tonumber(altHoldPreset4) or 0
ship.deviationThreshold = tonumber(deviationThreshold) or 0.5
ship.pocket = pocket == true
ship.breadCrumbDist = tonumber(breadCrumbDist) or 1000

ContainerOptimization = clamp(tonumber(ContainerOptimization) or 0, 0, 5)
FuelTankOptimization = clamp(tonumber(FuelTankOptimization) or 0, 0, 5)
fuelTankHandlingAtmo = clamp(tonumber(fuelTankHandlingAtmo) or 0, 0, 5)
fuelTankHandlingSpace = clamp(tonumber(fuelTankHandlingSpace) or 0, 0, 5)
dockingMode = clamp(tonumber(dockingMode) or 1, 1, 3)

controlStateChange = true

local shiftLock = false

function writeVecToDb(cVector, name)
	if flightModeDb and name and vec3.isvector(cVector) then
		settingsActive = false
		flightModeDb.setFloatValue(name.."X", cVector.x)
		flightModeDb.setFloatValue(name.."Y", cVector.y)
		flightModeDb.setFloatValue(name.."Z", cVector.z)
		-- P("[I] Wrote "..name..": "..tostring(cVector))
	end
end

function readVecFromDb(name)
	if flightModeDb and name then
		local v = vec3(0,0,0)
		v.x = flightModeDb.getFloatValue(name.."X")
		v.y = flightModeDb.getFloatValue(name.."Y")
		v.z = flightModeDb.getFloatValue(name.."Z")
		-- P("[I] Read "..name..": "..tostring(v))
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
	if not ship.nearestPlanet then return end
    ship.rot = ship.world.right:cross(ship.nearestPlanet:getGravity(construct.getWorldPosition()))
    if type(a) ~= "string" or a == "" then
        ship.baseLoc = ship.world.position
    elseif string.find(a, "::pos") ~= nil then
		local locTmp = ship.nearestPlanet:convertToWorldCoordinates(a)
		if not vec3.isvector(locTmp) then
			P("[E] Invalid location string: "..a)
			return
		end
		ship.baseLoc =  locTmp
    end
	writeVecToDb(ship.baseLoc,"BaseLoc")
	writeVecToDb(ship.rot, "BaseRot")
    config.rtb = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
    ioScheduler.queueData(config)
end

function updateGEAS()
    if useGEAS and not config.manualControl then
        unit.activateGroundEngineAltitudeStabilization(ship.hoverHeight)
    else
        unit.deactivateGroundEngineAltitudeStabilization()
    end
end

local tty = DUTTY
tty.onCommand('setbase', function(a)
    setBase(a)
end)

local function doAlt7() -- RTB
	if elevatorScreen and vec3.isvector(ship.baseLoc) and ship.baseLoc ~= vec3() and ship.baseAltitude and ship.baseAltitude > 0 then
		ship.altitudeHold = ship.baseAltitude
		ship.targetDestination = moveWaypointZ(ship.baseLoc, 0)
		ship.elevatorActive = true
	end
end

local function doAlt9() -- Manual Mode Toggle
    if shiftLock then
		if flightModeDb then
        	flightModeDb.clear() P("[I] DB cleared!")
		end
    else
        config.manualControl = not config.manualControl
        ship.elevatorActive = false
        ship.inertialDampening = true
        ship.verticalLock = false
        manualControlSwitch()
    end
end

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

keybindPresets["keyboard"].keyUp.stopengines.Add(function ()
	SHUD.Select()
	if not SHUD.Enabled then
		if ship.direction.y ~= 0 then ship.direction.y = 0
		else ship.direction.y = 1 end
	end
end, "Cruise")

local function sendDoorCommand(cmd)
	if emitter then
		emitter.send("door_control",cmd)
	end
end

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
		writeVecToDb(ship.lockVector,"lockVector")
		writeVecToDb(ship.lockPos,"lockPos")
    end
end,"Set Vertical Lock")
keybindPresets["keyboard"].keyUp["option6"].Add(function () ship.verticalLock = not ship.verticalLock end,"Toggle Vertical Lock")
--keybindPresets["keyboard"].keyUp["option7"].Add(function () ship.verticalCruise = not ship.verticalCruise end, "Vertical Cruise")
keybindPresets["keyboard"].keyUp["option7"].Add(function() doAlt7() end, "RTB")
keybindPresets["keyboard"].keyUp["option8"].Add(function () construct.setDockingMode(1); if construct.undock() then P('[I] Undocked') end end,"Undock")
--keybindPresets["keyboard"].keyUp["option8"].Add(function () sendDoorCommand(shiftLock and "close" or "open") end, "Open Door")
--keybindPresets["keyboard"].keyUp["option9"].Add(function () if ship.targetDestination == nil then ship.targetDestination = moveWaypointZ(ship.baseLoc, 10000 - baseAltitude) else ship.targetDestination = nil end end, "Preset 2")
--keybindPresets["keyboard"].keyUp.option9.Add(function () if flightModeDb ~= nil then flightModeDb.clear() P("DB Cleared") end end,"Clear Databank")
keybindPresets["keyboard"].keyUp["option9"].Add(function () doAlt9() end,"Manual Mode Toggle")

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
keybindPresets["screenui"].keyUp["option5"].Add(function () sendDoorCommand("open") end, "Open Door")
keybindPresets["screenui"].keyUp["option6"].Add(function () sendDoorCommand("close") end, "Close Door")
keybindPresets["screenui"].keyUp["option7"].Add(function() doAlt7() end, "RTB")
keybindPresets["screenui"].keyUp["option8"].Add(function () construct.setDockingMode(1); construct.undock() end,"Undock")
keybindPresets["screenui"].keyUp["option9"].Add(function () doAlt9() end,"Manual Mode Toggle")

-- Note: in this elevator script version, the flight mode still contains "keyboard",
-- which in later versions of Horizon is replaced with Standard/Maneuver
keybindPreset = "keyboard"
if flightModeDb then
   if not flightModeDb.hasKey("flightMode") then flightModeDb.setStringValue("flightMode","keyboard") end
   keybindPreset = flightModeDb.getStringValue("flightMode")
   if keybindPreset ~= 'keyboard' and keybindPreset ~= 'screenui' then
      keybindPreset = 'keyboard'
   end
end

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

updateGEAS()

function normalizeTravelMode()
	if ship.controlMode == 1 and controlStateChange then
		ship.cruiseSpeed = round(ship.world.velocity:len() * 3.6,-1)
		ship.throttle = 0
		controlStateChange = false
	elseif ship.controlMode == 0 then
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

local function validatePresets()
	ship.altHoldPreset1 = tonumber(ship.altHoldPreset1) or 0
	ship.altHoldPreset2 = tonumber(ship.altHoldPreset2) or 0
	ship.altHoldPreset3 = tonumber(ship.altHoldPreset3) or 0
	ship.altHoldPreset4 = tonumber(ship.altHoldPreset4) or 0
end

function STEC_configInit()
	-- default to current location/rotation
	ship.baseLoc = ship.world.position
	ship.rot = ship.world.forward

	validatePresets()

	if not flightModeDb then
		P("[E] No databank found!")
	else
		local bool_to_number={ [true]=1, [false]=0 }
		local number_to_bool={ [1]=true, [0]=false }

		P("[I] Databank found.")
		-- assure that keys exist in the databank for each saved setting
		if not flightModeDb.hasKey("dockingMode") or updateSettings then
			flightModeDb.setIntValue("dockingMode", dockingMode)
		end
		dockingMode = clamp(flightModeDb.getIntValue("dockingMode"), 1, 3)

		if not flightModeDb.hasKey("activateFFonStart") or updateSettings then
			flightModeDb.setIntValue("activateFFonStart", bool_to_number[setactivateFFonStart == true])
		end
		activateFFonStart = number_to_bool[flightModeDb.getIntValue("activateFFonStart")]

		if not flightModeDb.hasKey("lockVerticalToBase") or updateSettings then
			flightModeDb.setIntValue("lockVerticalToBase", bool_to_number[lockVerticalToBase == true])
		end
		lockVerticalToBase = number_to_bool[flightModeDb.getIntValue("lockVerticalToBase")]

		if not flightModeDb.hasKey("pocket") or updateSettings then
			flightModeDb.setIntValue("pocket", bool_to_number[setpocket == true])
		end
		pocket = number_to_bool[flightModeDb.getIntValue("pocket")]

		verticalSpeedLimitAtmo = clamp(verticalSpeedLimitAtmo or 1080, 0, 1100)
		if not flightModeDb.hasKey("verticalSpeedLimitAtmo") or updateSettings then
			flightModeDb.setFloatValue("verticalSpeedLimitAtmo", verticalSpeedLimitAtmo)
			ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
		end
		ship.verticalSpeedLimitAtmo = flightModeDb.getFloatValue("verticalSpeedLimitAtmo")

		verticalSpeedLimitSpace = clamp(verticalSpeedLimitSpace or 4000, 100, 10000)
		if not flightModeDb.hasKey("verticalSpeedLimitSpace") or updateSettings then
			flightModeDb.setFloatValue("verticalSpeedLimitSpace",verticalSpeedLimitSpace)
			ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace
		end
		ship.verticalSpeedLimitSpace = flightModeDb.getFloatValue("verticalSpeedLimitSpace")

		approachSpeed = clamp(approachSpeed or 200, 50, 300)
		if not flightModeDb.hasKey("approachSpeed") or updateSettings then
			flightModeDb.setFloatValue("approachSpeed",approachSpeed)
			ship.approachSpeed = approachSpeed
		end
		ship.approachSpeed = flightModeDb.getFloatValue("approachSpeed")

		altHoldPreset1 = clamp(tonumber(altHoldPreset1) or 0, 0, 200000000)
		altHoldPreset2 = clamp(tonumber(altHoldPreset2) or 0, 0, 200000000)
		altHoldPreset3 = clamp(tonumber(altHoldPreset3) or 0, 0, 200000000)
		altHoldPreset4 = clamp(tonumber(altHoldPreset4) or 0, 0, 200000000)
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
end

function ElevatorInit()
	elevatorName = construct.getName()
	config.floors.floor1 = ship.altHoldPreset1
	config.floors.floor2 = ship.altHoldPreset2
	config.floors.floor3 = ship.altHoldPreset3
	config.floors.floor4 = ship.altHoldPreset4
	config.targetAlt = 0

	P("Preset 1: "..config.floors.floor1)
	P("Preset 2: "..config.floors.floor2)
	P("Preset 3: "..config.floors.floor3)
	P("Preset 4: "..config.floors.floor4)

	ioScheduler.defaultData = stats
	ioScheduler.queueData(config)
	-- ioScheduler.queueData(fuelAtmo)
	-- ioScheduler.queueData(fuelSpace)
end
