--@class StartupSettings

function StartupSettings()

    self.inertialDampening = true
    self.followGravity = false
    self.followTerrain = true
    self.idIntensity = 5

    function self.bool_to_number(value)
        return value and 1 or 0
    end
    function self.number_to_bool(value)
        if value == 1 then return true else return false end
    end
    
    function self.writeToDatabank()
        --flightModeDb
        if flightModeDb ~= nil then
            flightModeDb.setIntValue("inertialDampening",self.bool_to_number(self.inertialDampening))
            flightModeDb.setIntValue("followGravity",self.bool_to_number(self.followGravity))
            flightModeDb.setIntValue("followTerrain",self.bool_to_number(self.followTerrain))
            --flightModeDb.setIntValue("hoverHeight",ship.hoverHeight)
        end
    end

    function self.readFromDatabank()
        if flightModeDb ~= nil then
            if flightModeDb.hasKey("inertialDampening") == 1 then
                ship.inertialDampeningDesired = self.number_to_bool(flightModeDb.getIntValue("inertialDampening"))
                self.inertialDampening = ship.inertialDampeningDesired
            end
            --if flightModeDb.hasKey("followGravity") == 1 then
            --    ship.followGravity = self.number_to_bool(flightModeDb.getIntValue("followGravity"))
            --    self.followGravity = ship.followGravity
            --end
            --if flightModeDb.hasKey("followTerrain") == 1 then
            --    ship.followTerrain = self.number_to_bool(flightModeDb.getIntValue("followTerrain"))
            --    self.followTerrain = ship.followTerrain
            --end
            if flightModeDb.hasKey("IDIntensity") == 1 then
                ship.IDIntensity = flightModeDb.getIntValue("IDIntensity")
            end
            if flightModeDb.hasKey("hoverHeight") == 1 then
                ship.hoverHeight = flightModeDb.getFloatValue("hoverHeight")
            end
            if flightModeDb.hasKey("hoverIntensity") == 1 then
                ship.hoverIntensity = flightModeDb.getIntValue("hoverIntensity")
            end
            if flightModeDb.hasKey("minRotationSpeed") == 1 then
                ship.minRotationSpeed = flightModeDb.getFloatValue("minRotationSpeed")
            end
            if flightModeDb.hasKey("rotationStep") == 1 then
                ship.rotationStep = flightModeDb.getFloatValue("rotationStep")
            end
            if flightModeDb.hasKey("maxRotationSpeedz") == 1 then
                ship.maxRotationSpeedz = flightModeDb.getFloatValue("maxRotationSpeedz")
            end
        end
    end
    return self
end

startupSettings = StartupSettings()