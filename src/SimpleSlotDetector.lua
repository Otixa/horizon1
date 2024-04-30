--@class SimpleSlotDetector
core = nil
antigrav = nil
warpDrive = nil
radarUnitAtmo = nil
radarUnitSpace = nil
flightModeDb = nil
manualSwitches = {}
forceFields = {}
lasers = {}
screen = nil
settingsActive = false
emitter = nil
telemeter = nil

function getElements()
	for _,var in pairs(_G) do
		if type(var) == "table" and var["getClass"] then
			local class = string.lower(var["getClass"]())
			--system.print(class)
			if class == "coreunitdynamic" or class == "coreunitstatic" or class == "coreunitspace" then
				core = var
			end
			-- if class == "atmofuelcontainer" or class == "spacefuelcontainer" then
			-- 	var.showWidget()
			-- end
			if class == "warpdriveunit" then
				warpDrive = var
				var.showWidget()
			end
			if class == "radarpvpatmospheric" then
				radarUnitAtmo = var
				radarUnitAtmo.showWidget()
			end
			if class == "radarpvpspace" then
				radarUnitSpace = var
				radarUnitSpace.showWidget()
			end
			if class == "databankunit" then
				flightModeDb = var
			end
			if class == "antigravitygeneratorunit" then
				antigrav = var
			end
			if class == "manualswitchunit" then
				table.insert(manualSwitches, var)
			end
			if class == "forcefieldunit" then
				table.insert(forceFields, var)
			end
			if class == "screenunit" then
				screen = var
			end
			if class == "laseremitterunit" then
				table.insert(lasers, var)
			end
			if class == "emitterunit" then
				emitter = var
			end
			if class == "telemeterunit" then
				telemeter = var
			end
		end
	end
end

function toggleForceFields(state)
	if next(forceFields) then
		for _, ff in ipairs(forceFields) do
			if state then
				ff.deploy()
			else
				ff.retract()
			end
		end
	end
end

function toggleLasers(state)
	if next(lasers) then
		for _, laser in ipairs(lasers) do
			if state then
				laser.activate()
			else
				laser.deactivate()
			end
		end
	end
end

function toggleSwitches(state)
	if next(manualSwitches) then
		for _, sw in ipairs(manualSwitches) do
			if state then
				sw.activate()
			else
				sw.deactivate()
			end
		end
	end
end

getElements()
