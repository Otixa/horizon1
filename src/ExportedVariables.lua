--@class ExportedVariables

shipName = ""
local updateSettings = false --export: Use these settings
local altHoldPreset1 = 100001.9  --export: Altitude Hold Preset 1
local altHoldPreset2 = 2000 --export: Altitude Hold Preset 2
local altHoldPreset3 = 500 --export: Altitude Hold Preset 3
local altHoldPreset4 = 50 --export: Altitude Hold Preset 4
local inertialDampening = true --export: Start with inertial dampening on/off
local followGravity = false --export: Start with gravity follow on/off
local minRotationSpeed = 0.01 --export: Minimum speed rotation scales from
local maxRotationSpeed = 5 --export: Maximum speed rotation scales to
local rotationStep = 0.03 --export: Depermines how quickly rotation scales up
local verticalSpeedLimitAtmo = 1100 --export: Vertical speed limit in atmosphere
local verticalSpeedLimitSpace = 4000 --export: Vertical limit in space
local autoShutdown = true --export: Auto shutoff on RTB landing

local pocket = false --export: Pocket ship?

--charMovement = true --export: Enable/Disable Character Movement
ship.autoShutdown = autoShutdown
ship.altitudeHold = round2(ship.altitude,0)
ship.inertialDampeningDesired = inertialDampening
ship.followGravity = followGravity
ship.minRotationSpeed = minRotationSpeed
ship.maxRotationSpeedz = maxRotationSpeed
ship.rotationStep = rotationStep

ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace

ship.altHoldPreset1 = altHoldPreset1
ship.altHoldPreset2 = altHoldPreset2
ship.altHoldPreset3 = altHoldPreset3
ship.altHoldPreset4 = altHoldPreset4
ship.pocket = pocket

if flightModeDb.hasKey("verticalSpeedLimitAtmo") == 0 or updateSettings then 
    flightModeDb.setFloatValue("verticalSpeedLimitAtmo",verticalSpeedLimitAtmo)
    ship.verticalSpeedLimitAtmo = verticalSpeedLimitAtmo
else ship.verticalSpeedLimitAtmo = flightModeDb.getFloatValue("verticalSpeedLimitAtmo") end

if flightModeDb.hasKey("verticalSpeedLimitSpace") == 0 or updateSettings then 
    flightModeDb.setFloatValue("verticalSpeedLimitSpace",verticalSpeedLimitSpace)
    ship.verticalSpeedLimitSpace = verticalSpeedLimitSpace
else ship.verticalSpeedLimitSpace = flightModeDb.getFloatValue("verticalSpeedLimitSpace") end

if flightModeDb.hasKey("altHoldPreset1") == 0 or updateSettings then 
    flightModeDb.setFloatValue("altHoldPreset1",altHoldPreset1)
    ship.altHoldPreset1 = altHoldPreset1
else ship.altHoldPreset1 = flightModeDb.getFloatValue("altHoldPreset1") end

if flightModeDb.hasKey("altHoldPreset2") == 0 or updateSettings then 
    flightModeDb.setFloatValue("altHoldPreset2",altHoldPreset2)
    ship.altHoldPreset2 = altHoldPreset2
else ship.altHoldPreset2 = flightModeDb.getFloatValue("altHoldPreset2") end

if flightModeDb.hasKey("altHoldPreset3") == 0 or updateSettings then 
    flightModeDb.setFloatValue("altHoldPreset3",altHoldPreset3)
    ship.altHoldPreset3 = altHoldPreset3
else ship.altHoldPreset3 = flightModeDb.getFloatValue("altHoldPreset3") end

if flightModeDb.hasKey("altHoldPreset4") == 0 or updateSettings then 
    flightModeDb.setFloatValue("altHoldPreset4",altHoldPreset4)
    ship.altHoldPreset4 = altHoldPreset4
else ship.altHoldPreset4 = flightModeDb.getFloatValue("altHoldPreset4") end