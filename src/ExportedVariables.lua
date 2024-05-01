--@class ExportedVariables

shipName = ""
updateSettings = false --export: Use these settings
altHoldPreset1 = 150000  --export: Altitude Hold Preset 1
altHoldPreset2 = 1000 --export: Altitude Hold Preset 2
altHoldPreset3 = 500 --export: Altitude Hold Preset 3
altHoldPreset4 = 2 --export: Altitude Hold Preset 4
deviationThreshold = 0.5 --export: Deviation tolerace in m
inertialDampening = true --export: Start with inertial dampening on/off
followGravity = true --export: Start with gravity follow on/off
minRotationSpeed = 0.01 --export: Minimum speed rotation scales from
maxRotationSpeed = 5 --export: Maximum speed rotation scales to
rotationStep = 0.025 --export: Depermines how quickly rotation scales up
verticalSpeedLimitAtmo = 1100 --export: Max vertical speed in atmosphere
verticalSpeedLimitSpace = 4000 --export: Max vertical speed in space (100-10000)
approachSpeed = 200 --export: Max final approach speed (50-300)
autoShutdown = true --export: Auto shutoff on RTB landing
breadCrumbDist = 1000 --export: Distance of vector breadcrumbs for elevator control
ContainerOptimization = 0 --export: Container ContainerOptimization (0-5)
FuelTankOptimization = 0 --export: Fuel Tank FuelTankOptimization (0-5)
fuelTankHandlingAtmo = 0 --export: Fuel Tank Handling Atmo (0-5)
fuelTankHandlingSpace = 0 --export: Fuel Tank Handling Space (0-5)

primaryColor = "b80000" --export: Primary color of HUD
secondaryColor = "e30000" --export: Secondary color of HUD
textShadow = "e81313" --export: Color of text shadow for speedometer
fuelFontSize = 1.8 --export: Fuel Gauge Font Size

dockingMode = 1 --export: Set docking mode (1:Manual, 2:Automatic, 3:Semi-Automatic)
showDockingWidget = false --export: Show Docking Widget

setBaseOnStart = false --export: Set RTB location on start
useGEAS = false --export: use ground engine altitude stabilization (GEAS)?
GEAS_Alt = 10 --export: default hover altitude for GEAS in meters

activateFFonStart = false
setactivateFFonStart = false --export: Activate force field(s) on start (if linked directly)?
activateFFonStop = true
setactivateFFonStop = true --export: Deactivate force field(s) on stop (if linked directly)?

activateLasersOnStart = false
setactivateLasersOnStart = false --export: Activate laser(s) on start (if linked directly)?
activateLasersOnStop = true
setactivateLasersOnStop = true --export: Deactivate laser(s) on stop (if linked directly)?

activateSwitchOnStart = false
setactivateSwitchOnStart = false --export: Activate linked switch(es) on start?
activateSwitchOnStop = false
setactivateSwitchOnStop = false --export: Deactivate linked switch(es) on stop?

pocket = false
setpocket = false --export: Pocket ship?
mouseSensitivity = 1 --export: Enter your mouse sensativity setting

lockVerticalToBase = true --export: FOR ELEVATORS ONLY!

--charMovement = true --export: Enable/Disable Character Movement