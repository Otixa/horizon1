--@require PlanetRef
--@require KinematicsMin
--@require SimpleSlotDetector
--@require EventDelegateMin
--@require TaskManagerMin
--@require DynamicDocumentMin
--@require DUTTYMin
--@require CSS_SHUD
--@require FuelTankHelperMin
--@require TagManagerMin
--@require KeybindControllerMin
--@require STEC
--@require AR_HUDMin
--@require StartupSettings
--@require SHUD
--@require MouseMovement
--@require STEC_Config
--@timer SHUDRender
--@timer FuelStatus
--@timer SetHoverHeight
--@timer SetCruise
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

function Unit.onStart()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	getFuelRenderedHtml()
	
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
	system.print(player.getId())
	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("SetHoverHeight", 0.03)
	unit.setTimer("SetCruise", 0.2)
	if laser ~= nil then laser.deactivate() end

	system.print([[Horizon 1.2.1.12]])
	if showDockingWidget then
		parentingPanelId = system.createWidgetPanel("Docking")
		parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
		system.addDataToWidget(unit.getWidgetDataId(),parentingWidgetId)
	end
	startupSettings.readFromDatabank()
end



function Unit.onStop()
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
	updateSettings()
	startupSettings.writeToDatabank()
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
		getFuelRenderedHtml()
		
	end

	if timer == "SetHoverHeight" then
		if ship.hoverUp then ship.hoverHeight = ship.hoverHeight + 0.1 end
		if ship.hoverDown then ship.hoverHeight = ship.hoverHeight - 0.1 end

		ship.throttle = utils.clamp(0,1,(ship.hoverHeight * 0.1))
	end

	if timer == "SetCruise" then
		if ship.cruiseUp then ship.cruiseSpeed = ship.cruiseSpeed + 1 end
		if ship.cruiseDown then ship.cruiseSpeed = ship.cruiseSpeed - 1 end
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
	TaskManager.Update()
end

function System.onFlush()
	if Events then Events.Flush() end
end

function toggleVerticalLock()
	--ship.verticalLock = true
    ship.lockVector = vec3(construct.getWorldOrientationUp())
    ship.lockPos = vec3(construct.getWorldPosition()) + (vec3(construct.getWorldOrientationUp()))
end