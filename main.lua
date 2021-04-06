--@require Atlas
--@require PlanetRef
--@require Kinematics
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
--@require ElevatorScreen
--@timer SHUDRender
--@class Main

_G.BuildUnit = {}
local Unit = _G.BuildUnit
_G.BuildSystem = {}
local System = _G.BuildSystem
_G.BuildScreen = {}
local buildScreen = _G.BuildScreen

function Unit.Start()
	Events.Flush.Add(mouse.apply)
	Events.Flush.Add(ship.apply)
	Events.Update.Add(SHUD.Update)
	manualControl = false
	e_stop = false
	system.print("Screen: "..tostring(screen))
	if screen ~= nil then
		manualControlSwitch()
		system.print("Altitude: "..helios:closestBody(core.getConstructWorldPos()):getAltitude(core.getConstructWorldPos()))
		ship.altitudeHold = helios:closestBody(core.getConstructWorldPos()):getAltitude(core.getConstructWorldPos())
		ship.altitudeHoldToggle = true
	end
	if next(manualSwitches) ~= nil then manualSwitches[1].activate() end
	if screen ~= nil then
		screen.setCenteredText("Script Error")
	end
	system.print([[Horizon 1.0.1.6]])
end

function Unit.Stop()
	system.showScreen(0)
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
		system.showScreen(0)
		system.freeze(0)
		ship.frozen = true
	else
		system.showScreen(1)
		system.freeze(1)
		ship.frozen = false	
	end

end

function Unit.Tick(timer)
	if timer == "SHUDRender" then
		if screen == nil then
			if SHUD then SHUD.Render() end
		elseif manualControl then
			if SHUD then SHUD.Render() end
		else
			
		end
		--local magicNumber = (ship.mass / ship.vfMax) * (ship.world.gravity:len() * 0.01)
        --system.print("Magic Number: "..magicNumber)
		--local fMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(1,0,0):unpack()})
		--system.print("[1]-"..math.abs(round2(fMax[1])))
		--system.print("[2]-"..math.abs(round2(fMax[2])))
		--system.print("[3]-"..math.abs(round2(fMax[3])))
		--system.print("[4]-"..math.abs(round2(fMax[4])))
		--system.print("fMax:		"..round2(ship.fMax,0))	
		--system.print("vfMax:	"..round2(ship.vfMax,0))
		--system.print("hfMax:	"..round2(ship.hfMax,0))

		if screen ~= nil then ElevatorScreen() end
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

function buildScreen.MouseDown(x,y,slot)
	--system.print("Mouse X: "..x..", Mouse Y: "..y)
end
function toggleVerticalLock()
	--ship.verticalLock = true
    ship.lockVector = vec3(core.getConstructWorldOrientationUp())
    ship.lockPos = vec3(core.getConstructWorldPos()) + (vec3(core.getConstructWorldOrientationUp()))
end
function buildScreen.MouseUp(x,y,slot)
	if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.1276 and mousey <= 0.2051 then --P1 button
		toggleVerticalLock()
		ship.altitudeHold = ship.altHoldPreset1 ship.altitudeHoldToggle = true
	end
	if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.2153 and mousey <= 0.2900 then --P2 button
		toggleVerticalLock()
		ship.altitudeHold = ship.altHoldPreset2 ship.altitudeHoldToggle = true
	end
	if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.3883 and mousey <= 0.4632 then --Manual control button
		ship.verticalLock = false
		ship.intertialDampening = true
		ship.altitudeHoldToggle = false
        manualControl = not manualControl
		manualControlSwitch()
    end
	if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.3004 and mousey <= 0.3764 then --Up 10
		toggleVerticalLock()
        ship.altitudeHold = ship.altitudeHold + 10
    end
    if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.3004 and mousey <= 0.3764 then --Down 10
		toggleVerticalLock()
        ship.altitudeHold = ship.altitudeHold - 10
    end
    if mousex >= 0.1003 and mousex <= 0.3703 and mousey >= 0.5059 and mousey <= 0.9185 then --E-Stop button
        e_stop = not e_stop
		if e_stop then
			ship.verticalLock = false
			ship.altitudeHoldToggle = false
			ship.brake = true
		else
			ship.brake = false
		end
    end
end