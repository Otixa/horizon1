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
--@timer KeplerSim
--@timer WaypointTest
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

function Unit.onStart()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	if flightModeDb then 
		if flightModeDb.hasKey("controlMode") == 0 then flightModeDb.setIntValue("controlMode", unit.getControlMode()) end
		local controlMode = flightModeDb.getIntValue("controlMode")
		if controlMode ~= unit.getControlMode() then
			unit.cancelCurrentControlMasterMode()
		end
	end
	
	if flightModeDb ~= nil then getFuelRenderedHtml() end
	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("KeplerSim", 0.1)
	--unit.setTimer("WaypointTest", 1)
	system.print([[Horizon 1.1.1.8_6]])

	if showDockingWidget then
		parentingPanelId = system.createWidgetPanel("Docking")
		parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
		system.addDataToWidget(unit.getWidgetDataId(),parentingWidgetId)
	end
	if system.showHelper then system.showHelper(0) end
	--local fMax = construct.getMaxThrustAlongAxis("all", {vec3(0,1,0):unpack()})
	--local vMax = construct.getMaxThrustAlongAxis("all", {vec3(0,0,1):unpack()})

	--system.print(string.format( "fMax: %f, %f, %f, %f",fMax[1],fMax[2],fMax[3],fMax[4]))
	--system.print(string.format( "vMax: %f, %f, %f, %f",vMax[1],vMax[2],vMax[3],vMax[4]))
end
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
 
function Unit.onStop()
	if flightModeDb then
		flightModeDb.setIntValue("controlMode", unit.getControlMode())
	end
	system.showScreen(0)
end
local switch = false
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
		--local msa = construct.getMaxSpeedPerAxis()
		--system.print(dump(msa))
	end
	if timer == "KeplerSim" then
		if ship.gotoLock ~= nil then
			Task(function()
				local t = ship.ETA - ship.accelTime
				if ship.ETA == 0 then t = 30 end
				local f = simulateAhead(t,t * 0.1)
				ship.simulationPos = f.position
			end)
		end
	end
	
	if timer == "WaypointTest" then
		system.print("Deviation angle: "..ship.deviationAngle.."°")
		system.print("Target Dist: "..ship.targetDist)
		system.print("Brake Dist: "..ship.brakeDistance)
		system.print("Stopping: "..tostring(ship.stopping))
		system.print("Brake Diff: "..(ship.targetDist - ship.brakeDistance))
		system.print("Trajectory Diff: "..ship.trajectoryDiff)
		system.print("Mass (tons): "..ship.mass / 1000)
		system.print("Max Speed: "..ship.constructMaxSpeed)
		system.print("ETA: "..disp_time(ship.ETA))
		
		-- if switch then
		-- 	local waypointString = ship.nearestPlanet:convertToMapPosition(ship.simulationPos)
		-- 	system.setWaypoint(tostring(waypointString))
		-- else
		-- 	if ship.gotoLock ~= nil then
		-- 		local waypointString = ship.nearestPlanet:convertToMapPosition(ship.gotoLock)
		-- 		system.setWaypoint(tostring(waypointString))
		-- 	end
		-- end
		-- switch = not switch


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

function System.onUpdate()
	if Events then Events.Update() end
	if TaskManager then TaskManager.Update() end
end

function System.onFlush()
	if Events then Events.Flush() end
end