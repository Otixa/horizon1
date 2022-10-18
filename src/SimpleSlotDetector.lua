--@class SimpleSlotDetector
core = nil
antigrav = nil
warpDrive = nil
radarUnit = nil
flightModeDb = nil
manualSwitches = {}
forceFields = {}
laser = nil
screen = nil
settingsActive = false
emitter = nil
telemeters = {}
hovers = {}
frontTel = nil
rearTel = nil

function getElements()
  for k,var in pairs(_G) do
    if type(var) == "table" and var["getClass"] then
      local class = var["getClass"]()
      system.print(class)
      if class == "CoreUnitDynamic" or class == "CoreUnitStatic" or class == "CoreUnitSpace" then
        core = var
      end
      
      if class == "AtmoFuelContainer" or class == "SpaceFuelContainer" then
        var.show()
      end
      
      if class == "WarpDriveUnit" then
        warpDrive = var
        var.show()
      end
      
      if class == "RadarPvPAtmospheric" or class == "RadarPvPSpace" then
        radarUnit = var
        var.show()
      end
      
      if class == "DataBankUnit" then
        flightModeDb = var
      end
      
      if class == "AntiGravityGeneratorUnit" then
        antigrav = var
      end
      if class == "ManualSwitchUnit" then
        --manualSwitch = var
        
        table.insert(manualSwitches, var)
      end
      if class == "ForceFieldUnit" then
        table.insert(forceFields, var)
      end
      if class == "ScreenUnit" then
        screen = var
      end
      if class == "LaserEmitterUnit" then
        laser = var
        --table.insert(lasers, var)
      end
      if class == "EmitterUnit" then
        emitter = var
      end
      if class == "TelemeterUnit" then
        table.insert(telemeters, var)
      end
      if class == "HoverEngineSmallGroup" then
        table.insert(hovers, var)
      end
    end
  end
end

getElements()
local tel1Pos = vec3(core.getElementPositionById(telemeters[1].getLocalId()))
local tel2Pos = vec3(core.getElementPositionById(telemeters[2].getLocalId()))

system.print("Telemeter 1 position: "..tostring((tel1Pos)))
system.print("Telemeter 2 position: "..tostring((tel2Pos)))

system.print("Telemeter 1 distance: "..telemeters[1].raycast().distance)
system.print("Telemeter 2 distance: "..telemeters[2].raycast().distance)


if tel1Pos.y < tel2Pos.y then
  frontTel = telemeters[1]
  rearTel = telemeters[2]
else
  frontTel = telemeters[2]
  rearTel = telemeters[1]
end

