--@class SimpleSlotDetector
core = nil
antigrav = nil
warpDrive = nil
radarUnit = nil
flightModeDb = nil
manualSwitches = {}
forceFields = {}
screen = nil

function getElements()
  for k,var in pairs(_G) do
    if type(var) == "table" and var["getClass"] then
      local class = var["getClass"]()
      system.print(class)
      if class == "CoreUnitDynamic" or class == "CoreUnitStatic" or class == "CoreUnitSpace" then
        core = var
      end
      
      if class == "AtmoFuelContainer" or class == "SpaceFuelContainer" then
        var.showWidget()
      end
      
      if class == "WarpDriveUnit" then
        warpDrive = var
        var.showWidget()
      end
      
      if class == "RadarPvPAtmospheric" or class == "RadarPVPSpaceSmallGroup" then
        radarUnit = var
        var.showWidget()
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
    end
  end
end

getElements()
