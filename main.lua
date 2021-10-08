--@require Atlas
--@require PlanetRefMin
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
--@require SHUD
--@require MouseMovement
--@require STEC_Config
--@timer SHUDRender
--@timer FuelStatus
--@timer SetHoverHeight
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

function Unit.Start()
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
	if flightModeDb ~= nil then
		if flightModeDb.hasKey("hoverHeight") == 1 then
			ship.hoverHeight = flightModeDb.getIntValue("hoverHeight")
		end
	end
	system.print(unit.getMasterPlayerId())
	unit.setTimer("SHUDRender", 0.02)
	unit.setTimer("FuelStatus", 3)
	unit.setTimer("SetHoverHeight", 1)
	if laser ~= nil then laser.deactivate() end

	system.print([[Horizon 1.2.1.11_6]])
	if showDockingWidget then
		parentingPanelId = system.createWidgetPanel("Docking")
		parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
		system.addDataToWidget(unit.getDataId(),parentingWidgetId)
	end
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
		if flightModeDb ~= nil then
			local hHeight = flightModeDb.getIntValue("hoverHeight")
			if hHeight ~= ship.hoverHeight then
				flightModeDb.setIntValue("hoverHeight",ship.hoverHeight)
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
end

function System.Flush()
	if Events then Events.Flush() end
end

function toggleVerticalLock()
	--ship.verticalLock = true
    ship.lockVector = vec3(core.getConstructWorldOrientationUp())
    ship.lockPos = vec3(core.getConstructWorldPos()) + (vec3(core.getConstructWorldOrientationUp()))
end