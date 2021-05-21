--@require Atlas
--@require PlanetRefMin
--@require KinematicsMin
--@require StateMachine
--@require SimpleSlotDetectorMin
--@require EventDelegateMin
--@require TaskManagerMin
--@require DynamicDocumentMin
--@require DUTTYMin
--@require CSS_SHUD
--@require FuelTankHelper
--@require TagManagerMin
--@require KeybindControllerMin
--@require STEC
--@require AR_HUDMin
--@require SHUD
--@require STEC_Config
--@require ElevatorScreen
--@timer SHUDRender
--@timer FuelStatus
--@timer EmitterTick
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem
_G.BuildScreen = {}
local buildScreen = _G.BuildScreen

local TestState = StateMachine()

local StepOne = State("Step One State",function ()
	system.print("Step 1 starting..."..system.getTime())

	system.print("Step 1 finished."..system.getTime())
	return true
end, true)
local StepTwo = State("Step Two State",function ()
	system.print("Step 2 starting..."..system.getTime())

	system.print("Step 2 finished."..system.getTime())
return true end, true)
local StepThree = State("Step Three State",function ()
	system.print("Step 3 starting..."..system.getTime())

	system.print("Step 3 finished."..system.getTime())
return false end, false)
--TestState.Current = StepOne
--StepOne.Next = StepTwo
--StepTwo.Next = StepThree
--TestState.End = StepThree



function Unit.Start()
	--Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	if flightModeDb ~= nil then getFuelRenderedHtml() end
	manualControl = false
	e_stop = false
	system.print("Screen: "..tostring(screen))
	if screen ~= nil then
		manualControlSwitch()
		system.print("Altitude: "..helios:closestBody(core.getConstructWorldPos()):getAltitude(core.getConstructWorldPos()))
		ship.altitudeHold = helios:closestBody(core.getConstructWorldPos()):getAltitude(core.getConstructWorldPos())
		--ship.elevatorActive = true
	end
	--if next(manualSwitches) ~= nil then manualSwitches[1].activate() end
	if screen ~= nil then
		screen.setCenteredText("Script Error")
	end
	local sName = ""
	local coreMass = core.getMass()
	if emitter ~= nil then
		system.print("Emitter Range: "..emitter.getRange())
	end
	if activateFFonStart then
		if next(manualSwitches) ~= nil then 
			for _, sw in ipairs(manualSwitches) do
				sw.activate()
			end
		end
	end
	
	
	if coreMass == 70.89 then
		sName = "Caterpillar P1"
	elseif coreMass == 375.97 then
		sName = "Caterpillar L"
	elseif coreMass == 1984.6 then
		sName = "Caterpillar XL"
	elseif coreMass == 12141.47 then
		sName = "Caterpillar EXL"
	else
		sName = "Caterpillar"
	end
	if shipName == "" then shipName = sName end
	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("EmitterTick", 1)
	if laser ~= nil then laser.deactivate() end
	system.print([[Horizon 1.0.1.10_RC5]])
	--StepOne.Start()
end



function Unit.Stop()
	system.showScreen(0)
	if laser ~= nil then laser.deactivate() end
	if next(manualSwitches) ~= nil then 
		for _, sw in ipairs(manualSwitches) do
			sw.deactivate()
		end
	end
	for _, sw in ipairs(forceFields) do
		sw.deactivate()
	end
	if screen ~= nil then
		screen.setHTML([[<img src="assets.prod.novaquark.com/27707/a8a9beb8-73de-4cd3-a0fb-d84e11e7a942.png" style="width:100%; height:100%"/>]])
	end
end

function manualControlSwitch()
	if not manualControl then
		SHUD.Init(system, unit, keybindPresets["screenui"])
		system.showScreen(0)
		system.freeze(0)
		ship.frozen = true
	else
		SHUD.Init(system, unit, keybindPresets["keyboard"])
		system.showScreen(1)
		system.freeze(1)
		ship.frozen = false	
	end

end
local emitterOn = false
local tmpClamp = ship.dockingClamps

function Unit.Tick(timer)
	if timer == "SHUDRender" then
		if screen == nil then
			if SHUD then SHUD.Render() end
		elseif manualControl then
			if SHUD then SHUD.Render() end
			if enableARReticle then updateAR() end
		else
			
		end
		if screen ~= nil then ElevatorScreen() end
	end
	if timer == "FuelStatus" then
		if flightModeDb ~= nil then
			local getFuelAsync = Task(function()
				getFuelRenderedHtml()
			end)
			
			Task(function ()
				await(getFuelAsync)
			end)
		end
	end
	if timer == "EmitterTick" then
		if telemeter ~= nil then telDistance = telemeter.getDistance() end
		if ship.dockingClamps then
			if laser ~= nil then laser.activate() end
			if telemeter ~= nil and telDistance > 0 and telDistance < 1 then
				if ship.autoShutdown then unit.exit() end
			end
		end
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
	TaskManager.Update()
	TestState.Update()
end

function System.Flush()
	if Events then Events.Flush() end
end

function buildScreen.MouseDown(x,y,slot)
	--system.print("Mouse X: "..x..", Mouse Y: "..y)
end
function toggleVerticalLock()
	--ship.verticalLock = true
    ship.lockVector = vec3(core.getConstructWorldOrientationUp())
    ship.lockPos = vec3(core.getConstructWorldPos()) + (vec3(core.getConstructWorldOrientationUp()))
end
function buildScreen.MouseUp(x,y,slot)
	ship.baseAltitude = helios:closestBody(ship.customTarget):getAltitude(ship.customTarget)
	if settingsActive then
		if mousex >= 0.1515 and mousex <= 0.4934 and mousey >= 0.5504 and mousey <= 0.7107 then --Setbase button
			setBase()
			settingsActive = false
		end
		if mousex >= 0.5097 and mousex <= 0.8511 and mousey >= 0.5504 and mousey <= 0.7134 then --Cancel button
			settingsActive = false
		end
		if mousex >= 0.0277 and mousex <= 0.0868 and mousey >= 0.8515 and mousey <= 0.9484 then --Settings button
			settingsActive = false
		end
	else
		if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.1276 and mousey <= 0.2850 then --RTB button
			ship.altitudeHold = ship.baseAltitude ship.elevatorActive = true
			ship.targetDestination = moveWaypointZ(ship.customTarget, 0)
		end
		if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.1276 and mousey <= 0.2051 then --P1 button
			ship.altitudeHold = ship.altHoldPreset1 ship.elevatorActive = true
			ship.targetDestination = moveWaypointZ(ship.customTarget, ship.altHoldPreset1 - ship.baseAltitude)
		end
		if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.2091 and mousey <= 0.2850 then --P2 button
			ship.altitudeHold = ship.altHoldPreset2 ship.elevatorActive = true
			ship.targetDestination = moveWaypointZ(ship.customTarget, ship.altHoldPreset2 - ship.baseAltitude)
		end
		if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.2928 and mousey <= 0.3677 then --P3 button
			ship.altitudeHold = ship.altHoldPreset3 ship.elevatorActive = true
			ship.targetDestination = moveWaypointZ(ship.customTarget, ship.altHoldPreset3 - ship.baseAltitude)
		end
		if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.3761 and mousey <= 0.4514 then --P4 button
			ship.altitudeHold = ship.altHoldPreset4 ship.elevatorActive = true
			ship.targetDestination = moveWaypointZ(ship.customTarget, ship.altHoldPreset4 - ship.baseAltitude)
		end
		
		if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.4609 and mousey <= 0.5364 then --Manual control button
			ship.verticalLock = false
			ship.intertialDampening = true
			ship.elevatorActive = false
			manualControl = not manualControl
			manualControlSwitch()
		end
		if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.2928 and mousey <= 0.3677 then --Up 10
			ship.elevatorActive = true
			ship.altitudeHold = ship.altitudeHold + 10
			ship.targetDestination = moveWaypointZ(ship.targetDestination, 10)
		end
		if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.3761 and mousey <= 0.4514 then --Down 10
			ship.elevatorActive = true
			ship.altitudeHold = ship.altitudeHold - 10
			ship.targetDestination = moveWaypointZ(ship.targetDestination, -10)

		end
		if mousex >= 0.1003 and mousex <= 0.3703 and mousey >= 0.5484 and mousey <= 0.9475 then --E-Stop button
			e_stop = not e_stop
			if e_stop then
				ship.verticalLock = false
				ship.elevatorActive = false
				ship.brake = true
			else
				ship.brake = false
			end
		end
		if mousex >= 0.0277 and mousex <= 0.0868 and mousey >= 0.8515 and mousey <= 0.9484 then --Settings button
			settingsActive = true
		end
	end
end