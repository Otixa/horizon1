--@require Event_Delegate
--@require Task_Manager
--@require Dynamic_Document
--@require CSS_SHUD
--@require Simple_Slot_Detector
--@require Tag_Manager
--@require Keybind_Controller
--@require STEC
--@require SHUD
--@require Mouse_Movement
--@require Keybind_Presets
--@timer SHUDRender
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

function Unit.Start()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	
	system.print([[Horizon 1.0.1.5]])
end

function Unit.Stop()
	system.showScreen(0)
end

function Unit.Tick(timer)
	if timer == "SHUDRender" then
		if SHUD then SHUD.Render() end
	end
end

function System.ActionStart(action)
	keybindPresets[keybindPreset].Call(action, "down")
end

function System.ActionStop(action)
	keybindPresets[keybindPreset].Call(action, "up")
end

function System.ActionLoop(action)
end

function System.Update()
	if Events then Events.Update() end
end

function System.Flush()
	if Events then Events.Flush() end
end