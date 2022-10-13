--@class ExportedVariables

shipName = ""
updateSettings = false --export: Use these settings
altHoldPreset1 = 132000.845  --export: Altitude Hold Preset 1
altHoldPreset2 = 1005 --export: Altitude Hold Preset 2
altHoldPreset3 = 50 --export: Altitude Hold Preset 3
altHoldPreset4 = 2 --export: Altitude Hold Preset 4
deviationThreshold = 0.5 --export: Deviation tolerace in m
inertialDampening = true --export: Start with inertial dampening on/off
followGravity = true --export: Start with gravity follow on/off
minRotationSpeed = 0.01 --export: Minimum speed rotation scales from
maxRotationSpeed = 5 --export: Maximum speed rotation scales to
rotationStep = 0.03 --export: Depermines how quickly rotation scales up
verticalSpeedLimitAtmo = 1100 --export: Vertical speed limit in atmosphere
verticalSpeedLimitSpace = 4000 --export: Vertical limit in space
approachSpeed = 200 --export: Max final approach speed
autoShutdown = true --export: Auto shutoff on RTB landing
breadCrumbDist = 1000 --export: Distance of vector breadcrumbs for elevator control
ContainerOptimization = 5 --export: Container ContainerOptimization
FuelTankOptimization = 5 --export: Fuel Tank FuelTankOptimization
fuelTankHandlingAtmo = 5 --export: Fuel Tank Handling Atmo
fuelTankHandlingSpace = 5 --export: Fuel Tank Handling Space

primaryColor = "b80000" --export: Primary color of HUD
secondaryColor = "e30000" --export: Secondary color of HUD
textShadow = "e81313" --export: Color of text shadow for speedometer
ARCrosshair = "ebbb0c" --export: Color of the AR crosshair
fuelFontSize = 1.8 --export: Fuel Gauge Font Size


showDockingWidget = true --export: Show Docking Widget
dockingMode = 0 --export: Set docking mode (0:Manual, 1:Automatic, 2:Semi-Automatic)
setBaseOnStart = false --export: Set RTB location on start
useGEAS = false --export:
GEAS_Alt = 10 --export:
activateFFonStart = false --export: Activate force fields on start (connected to button)
local pocket = false --export: Pocket ship?
mouseSensitivity = 1 --export: Enter your mouse sensativity setting
enableARReticle = false --export: Enable AR reticle


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