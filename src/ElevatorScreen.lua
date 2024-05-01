--@class ElevatorScreen
ElevatorScreen = (function ()
        local self = {}

        function self.updateStats()
            stats.data.elevation = ship.altitude
            stats.data.target = config.targetAlt
            stats.data.velocity = ship.world.velocity:len()
            stats.data.mass = ship.mass
            stats.data.gravity = ship.world.gravity:len()
            stats.data.target_dist = math.abs(ship.altitude - ship.altitudeHold)
            stats.data.brake_dist = ship.brakeDistance
            stats.data.deviation = ship.deviation
            stats.data.deviationVec = ship.worldToLocal(ship.deviationVec)
            stats.data.deviationRot = ship.worldToLocal(ship.deviationRot)
			stats.data.deviationRotAngle = angle_between(ship.world.forward, ship.rot) * (180 / math.pi)
            stats.data.state = ship.stateMessage
			stats.data.delta = nil
			stats.data.grounddistance = ship.GrndDist
			stats.data.agl = ship.agl
			stats.data.base = nil
			if vec3.isvector(ship.baseLoc) and ship.baseLoc ~= vec3() then
				stats.data.base = ship.baseLoc
			end
        end
        self.updateStats()
        -- function self.updateScreenFuel()
        --     fuelAtmo.tanks = {}
        --     fuelSpace.tanks = {}

		-- 	if next(SHUD.fuel.atmo) then
		-- 		for _, tank in pairs(SHUD.fuel.atmo) do
		-- 			table.insert(fuelAtmo.tanks,fuelTank(tank.time,math.ceil(100 * tank.level)))
		-- 		end
		-- 	end
		-- 	if next(SHUD.fuel.space) then
		-- 		for _, tank in pairs(SHUD.fuel.space) do
		-- 			table.insert(fuelSpace.tanks,fuelTank(tank.time,math.ceil(100 * tank.level)))
		-- 		end
        --     end
        --     ioScheduler.queueData(fuelAtmo)
        --     ioScheduler.queueData(fuelSpace)
        -- end
        if screen then screen.clearScriptOutput() end
    return self
end)()