--@class ExportedVariables

goButtonSpeed = 1050 --export: GO Button Speed
inertialDampening = false --export: Start with inertial dampening on/off
followGravity = true --export: Start with gravity follow on/off
counterGravity = false --export: Start with gravity follow on/off
rotationMin = 0.2 --export: Auto-scaling rotation speed starting point
rotationMax = 5 --export: Auto-scaling rotaiton max speed
rotationStep = 0.1 --export: Controls how quickly the rotation speed scales up
showDockingWidget = true --export: Show Docking Widget
dockingMode = 3 --export: Set docking mode (1:Manual, 2:Automatic, 3:Semi-Automatic)
vtolShip = true --export:

displaySize = 0.65
--primaryColor = "0faea9" --export: Primary color of HUD
--secondaryColor = "0247b5" --export: Secondary color of HUD
--textShadow = "d9ff00" --export: Color of text shadow for speedometer
primaryColor = "b80000" --export: Primary color of HUD
secondaryColor = "e30000" --export: Secondary color of HUD
textShadow = "e81313" --export: Color of text shadow for speedometer

ContainerOptimization = 0 --export: Container ContainerOptimization
FuelTankOptimization = 0 --export: Fuel Tank FuelTankOptimization
fuelTankHandlingAtmo = 4 --export: Fuel Tank Handling Atmo
fuelTankHandlingSpace = 4 --export: Fuel Tank Handling Space

ap_stop_distance = 200000 --export: AP Stop distance

activateFFonStart = false
setactivateFFonStart = false --export: Activate force fields on start (connected to button)
pocket = false
setpocket = false --export: Pocket ship?

bool_to_number={ [true]=1, [false]=0 }
number_to_bool={ [1]=true, [0]=false }
  
if flightModeDb.hasKey("activateFFonStart") == 0 or updateSettings then 
    flightModeDb.setIntValue("activateFFonStart", bool_to_number[setactivateFFonStart])
    activateFFonStart = setactivateFFonStart
else activateFFonStart = number_to_bool[flightModeDb.getIntValue("activateFFonStart")] end



if flightModeDb.hasKey("pocket") == 0 or updateSettings then 
    flightModeDb.setIntValue("pocket", bool_to_number[setpocket])
    pocket = setpocket
else pocket = number_to_bool[flightModeDb.getIntValue("pocket")] end
