--@class SimpleSlotDetector
core = nil
antigrav = nil
warpDrive = nil
radarUnitAtmo = nil
radarUnitSpace = nil
flightModeDb = nil
manualSwitches = {}
forceFields = {}
laser = nil
screen = nil
settingsActive = false
emitter = nil
telemeter = nil

function getElements()
  for k,var in pairs(_G) do
    if type(var) == "table" and var["getElementClass"] then
      local class = var["getElementClass"]()
      --system.print(class)
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
      
      if class == "RadarPvPAtmospheric" then
        radarUnitAtmo = var
        radarUnitAtmo.show()
      end
      
      if class == "RadarPvPSpace" then
        radarUnitSpace = var
        radarUnitSpace.show()
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
        telemeter = var
      end
    end
  end
end

getElements()



