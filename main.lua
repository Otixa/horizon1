--@require EventDelegate
--@require TaskManager
--@require DynamicDocument
--@require CSS_SHUD
--@require SimpleSlotDetector
--@require TagManager
--@require KeybindController
--@require STEC
--@require SHUD
--@require MouseMovement
--@require STEC_Config
--@timer SHUDRender
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem

local disableFFOnStop = false --export: Deactivate force fields on stop?

function Unit.onStart()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	--manualSwitches[1].activate()
	system.print([[Horizon 1.0.1.5]])
end

function Unit.onStop()
	system.showScreen(0)
	if disableFFOnStop then manualSwitches[1].deactivate() end
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

function System.onUpdate()
	if Events then Events.Update() end
end

function System.onFlush()
	if Events then Events.Flush() end
end