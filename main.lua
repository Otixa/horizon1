--@require Atlas
--@require PlanetRef
--@require Kinematics
--@require SimpleSlotDetector
--@require EventDelegate
--@require TaskManager
--@require DynamicDocument
--@require DUTTY
--@require CSS_SHUD
--@require FuelTankHelper
--@require TagManager
--@require KeybindController
--@require STEC
--@require SHUD
--@require MouseMovement
--@require STEC_Config
--@timer SHUDRender
--@timer FuelStatus
--@timer WaypointTest
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

function Unit.Start()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	if flightModeDb then 
		if flightModeDb.hasKey("controlMode") == 0 then flightModeDb.setIntValue("controlMode", unit.getControlMasterModeId()) end
		local controlMode = flightModeDb.getIntValue("controlMode")
		if controlMode ~= unit.getControlMasterModeId() then
			unit.cancelCurrentControlMasterMode()
		end
	end
	
	if flightModeDb ~= nil then getFuelRenderedHtml() end
	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("WaypointTest", 0.5)
	system.print([[Horizon 1.1.1.8_5]])

	if showDockingWidget then
		parentingPanelId = system.createWidgetPanel("Docking")
		parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
		system.addDataToWidget(unit.getDataId(),parentingWidgetId)
	end
	if system.showHelper then system.showHelper(0) end
	--local fMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,1,0):unpack()})
	--local vMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,0,1):unpack()})

	--system.print(string.format( "fMax: %f, %f, %f, %f",fMax[1],fMax[2],fMax[3],fMax[4]))
	--system.print(string.format( "vMax: %f, %f, %f, %f",vMax[1],vMax[2],vMax[3],vMax[4]))
end

function Unit.Stop()
	if flightModeDb then 
		flightModeDb.setIntValue("controlMode", unit.getControlMasterModeId())
	end
	system.showScreen(0)
end

function Unit.Tick(timer)
	if timer == "SHUDRender" then
		if SHUD then SHUD.Render() end
		if antigrav ~= nil then
			updateAGGBaseAlt()
			readAGGState()
			updateAGGState()
		end
	end
	if timer == "FuelStatus" then
		getFuelRenderedHtml()
	end
	if timer == "WaypointTest" then
		--local waypoint = moveWaypointY(ship.altitudeHold, (ship.world.velocity:len() * 2) + 50)
		--local waypointString = ship.nearestPlanet:convertToMapPosition(waypoint)
		--if ship.altitudeHold ~= 0 then
		--	ship.targetVector = waypoint
		--end
		--system.setWaypoint(tostring(waypointString))
		--system.print("Local thrust vector: "..tostring(vec3(ship.thrustVec)).." Brake dist: "..ship.brakeDistance)
		--system.print("Max Brake: "..ship.maxBrake)
		system.print("Brake Dist: "..math.floor(ship.brakeDistance).."/Target Dist: "..math.floor(ship.targetDist).."/Mass: "..math.floor(ship.mass))
		system.print("Inertial Mass: "..ship.inertialMass.."/Accel: "..tostring(vec3(ship.worldToLocal(ship.world.acceleration))))
		--system.print("Debug: "..ship.debug)
		--system.print("direction.z: "..ship.direction.z)
		--system.print("self.MaxKinematics.Up: "..ship.MaxKinematics.Up)
		--system.print("Gravity: "..tostring(vec3(ship.nearestPlanet:getGravity(core.getConstructWorldPos()))))
	end

end

function System.ActionStart(action)
	keybindPresets[keybindPreset].Call(action, "down")
end

function System.ActionStop(action)
	keybindPresets[keybindPreset].Call(action, "up")
end

function System.InputText(action)
	if DUTTY then DUTTY.input(action) end
end

function System.ActionLoop(action)
end

function System.Update()
	if Events then Events.Update() end
end

function System.Flush()
	if Events then Events.Flush() end
end