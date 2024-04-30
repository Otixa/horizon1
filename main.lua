--@require SimpleSlotDetector
--@require ExportedVariables
--@require PlanetRef
--@require KinematicsMin
--@require Serializer
--@require EventDelegateMin
--@require TaskManagerMin
--@require DynamicDocumentMin
--@require DUTTYMin
--@require FuelTankHelper
--@require KeybindControllerMin
--@require IOScheduler
--@require Utils3D
--@require STEC
--@require CSS_SHUD
--@require SHUD
--@require STEC_Config
--@require ElevatorScreen
--@timer SHUDRender
--@timer FuelStatus
--@timer DockingTrigger
-- timer Debug
--@outFilename Elevator.json
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem
_G.BuildScreen = {}
local buildScreen = _G.BuildScreen
_G.BuildEmitter = {}
local buildEmitter = _G.BuildEmitter

local P = system.print

elevatorScreen = nil -- global!

function manualControlSwitch()
	local c = config.manualControl == true
	player.freeze(c)
	ship.counterGravity = true
	ship.frozen = not c
	ship.elevatorActive = not c
	ship.inertialDampening = c
	ship.counterGravity = c
	ship.followGravity = true
	if c then
		SHUD.Init(system, unit, keybindPresets["keyboard"])
		ship.altitudeHold = ship.baseAltitude
		ship.targetDestination = nil
		ship.stateMessage = "Manual Control"
		config.targetAlt = ship.baseAltitude
	else
		SHUD.Init(system, unit, keybindPresets["screenui"])
		ship.stateMessage = "Idle"
	end
	-- P('Elevator active: '..tostring(ship.elevatorActive))
	-- P('counterGravity: '..tostring(ship.counterGravity))
	-- P('followGravity: '..tostring(ship.followGravity))
	-- P('inertialDampening: '..tostring(ship.inertialDampening))
	-- P('verticalLock: '..tostring(ship.verticalLock))
	-- P('config.manualControl: '..tostring(config.manualControl))
end

function Unit.onStart()
	--Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	getFuelRenderedHtml()
	if system.showHelper then system.showHelper(false) end

	P('Elevator 1.1.0')
	P('Customized by tobitege, v2024-04-30')

	if construct.setDockingMode(dockingMode) then
		P("[I] Docking mode set to: "..dockingMode)
	else
		P("[W] Could not set docking mode to: "..dockingMode)
	end

	if telemeter then
		P("[I] Telemeter found.")
	else
		P("[E] Telemeter not found!")
	end
	if screen then
		P("[I] Screen found.")
	else
		P("[E] No screen found!")
	end

	STEC_configInit()

	-- STARTUP Sanity Checks
	-- E.g. do not allow elevator mode if required element(s) are missing
	-- or we are in space without a gravity well
	ship.elevatorActive = false
	config.manualControl = true
	local body = ship.nearestPlanet
	if screen and telemeter and flightModeDb then
		if not body then
			P'[E] Elevator disabled: no planetary body as gravity well!'
		else
			if setBaseOnStart then setBase() end

			-- in STEC_config the flag for setBaseActive could already be set:
			if config.setBaseActive or not vec3.isvector(ship.baseLoc) then
				config.setBaseActive = false
				config.rtb = body:getAltitude(ship.world.position)
				P("[I] No base location set, using current location!")
			else
				config.rtb = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
				ship.baseAltitude = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
				P("Base location: "..tostring(ship.baseLoc))
			end

			if ship.baseLoc and ship.baseLoc ~= vec3() then
				body = helios:closestBody(ship.baseLoc)
				if body then
					config.manualControl = false
					ship.altitudeHold = body:getAltitude(ship.world.position)
					ship.baseAltitude = body:getAltitude(ship.baseLoc)
					elevatorScreen = ElevatorScreen
					P("[I] Altitude: "..round2(ship.baseAltitude,2))
				end
			end
			if not elevatorScreen then
				P'[E] Elevator disabled: no body of gravity influence!'
			end
		end
	else
		P'[E] Elevator disabled: elements missing!'
		P'Check links for core, databank, telemeter and a screen!'
	end
	if vec3.isvector(ship.baseLoc) and ship.baseLoc ~= vec3() then
		P("Base: "..tostring(ship.baseLoc))
		local mapPos = tostring(ship.nearestPlanet:convertToMapPosition(ship.baseLoc))
		P("Map location: "..mapPos)
		system.setWaypoint(mapPos,false)
	end

	ship.brake = true
	if elevatorScreen then
		ElevatorInit()
	else
		ship.throttle = 0
		ship.verticalLock = false
		ship.followGravity = true
		ship.inertialDampening = true
	end
	ship.followGravity = true
	ship.inertialDampening = true
	if ship.isLanded then
		P("Landed.")
	end

	if emitter then
		P("[I] Emitter range: "..emitter.getRange())
	end

	manualControlSwitch()

	if ship.isLanded then
		P('Ground: '..(round2(ship.GrndDist, 2)..'m'))
	end

	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("DockingTrigger", 1)

	toggleForceFields(activateFFonStart)
	toggleLasers(activateLasersOnStart)
	toggleSwitches(activateSwitchOnStart)

	if showDockingWidget then
		parentingPanelId = system.createWidgetPanel("Docking")
		parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
		system.addDataToWidget(unit.getWidgetDataId(),parentingWidgetId)
	end

	--ioScheduler.queueData(config)
end

function Unit.onStop()
	toggleForceFields(activateFFonStop)
	toggleLasers(activateLasersOnStop)
	toggleSwitches(activateSwitchOnStop)

	config.shutDown = true
	if screen then screen.setScriptInput(serialize(config)) end
	system.showScreen(false)
end

function Unit.onTimer(timer)
	if timer == "SHUDRender" then
		if SHUD then SHUD.Render() end
	elseif timer == "FuelStatus" then
		getFuelRenderedHtml()
		-- Fix: do NOT send fuel data, it corrupts the screen ui!
		-- if elevatorScreen then elevatorScreen.updateScreenFuel() end
	elseif timer == "DockingTrigger" then
		local telDistance
		if telemeter then telDistance = telemeter.raycast().distance end
		if ship.dockingClamps then
			toggleLasers(true)
			if telDistance and telDistance > 0 and telDistance < 1 then
				if ship.autoShutdown and not config.manualControl then
					unit.exit()
				end
			end
		end
	end
end

function System.onActionStart(action)
	keybindPresets[keybindPreset].Call(action, "down")
end

function System.onActionStop(action)
	keybindPresets[keybindPreset].Call(action, "up")
end

function System.onInputText(action)
	if DUTTY then DUTTY.input(action) end
end

function System.onActionLoop(action)
end

function System.onUpdate()
	--P("Target: "..tostring(vec3(ship.baseLoc)).." | alt: "..ship.altitude.." | baseAlt: "..ship.baseAltitude.." | worldPos: "..tostring(vec3(ship.world.position)).." | ")
	--self.deviationVec = (moveWaypointZ(self.baseLoc, self.altitude - self.baseAltitude) - self.world.position)
	ioScheduler.update()
	if elevatorScreen then elevatorScreen.updateStats() end
	if Events then Events.Update() end
	if TaskManager then TaskManager.Update() end
end

function System.onFlush()
	if Events then Events.Flush() end
end

function buildEmitter.onSent(channel, message, slot)
	P("Sent: "..channel.." | "..message)
end

-- function createBreadcrumbTrail(endAlt)
-- 	--Create a set of waypoints starting from the current position to the destination spaced 1km apart
-- 	local startPosition = moveWaypointZ(ship.baseLoc, ship.world.altitude - ship.baseAltitude)
-- 	local endPosition = moveWaypointZ(ship.baseLoc, endAlt)
-- 	local distance = (startPosition - endAlt):len()
-- 	if distance > 1000 then
-- 		for i = 1, round2(distance / 1000,0), 1 do
-- 			if ship.nearestPlanet:getAltitude(startPosition) < ship.nearestPlanet:getAltitude(endPosition) then
-- 				table.insert(ship.breadCrumbs, moveWaypointZ(startPosition, 1000 * i))
-- 			else
-- 				table.insert(ship.breadCrumbs, moveWaypointZ(startPosition, -1000 * i))
-- 			end
-- 		end
-- 	end
-- end
--local btrail = createBreadcrumbTrail(3)
--P("Breadcrumbs:")
--for _, sw in ipairs(ship.breadCrumbs) do
--	P("POS: "..tostring(sw))
--end

function buildScreen.onMouseUp(x,y,slot)
--	ship.baseAltitude = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)
--	if settingsActive then
--		if mousex >= 0.1515 and mousex <= 0.4934 and mousey >= 0.5504 and mousey <= 0.7107 then --Setbase button
--			setBase()
--			settingsActive = false
--		end
--		if mousex >= 0.5097 and mousex <= 0.8511 and mousey >= 0.5504 and mousey <= 0.7134 then --Cancel button
--			settingsActive = false
--		end
--		if mousex >= 0.0277 and mousex <= 0.0868 and mousey >= 0.8515 and mousey <= 0.9484 then --Settings button
--			settingsActive = false
--		end

--		if mousex >= 0.0277 and mousex <= 0.0868 and mousey >= 0.8515 and mousey <= 0.9484 then --Settings button
--			settingsActive = true
--		end
--	end
end
function buildScreen.onMouseDown(x,y,slot)
	--P("Mouse X: "..x..", Mouse Y: "..y)
end
