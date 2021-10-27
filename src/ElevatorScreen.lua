--@class ElevatorScreen
ElevatorScreen = (function ()
    local self = {}
    self.elevation = mToKm(ship.altitude)
    self.velocity = round2((ship.world.velocity:len() * 3.6),0)
    self.verticalVelocity = round2(ship.world.velocity:dot(-ship.world.gravity:normalize()), 2)
    self.deltaV = round2(ship.world.acceleration:len(),2)
    self.targetDistance = round2(math.abs(ship.altitude - ship.altitudeHold),2)
    --self.brakeDistance, accelTime = kinematics.computeDistanceAndTime(ship.world.velocity:len(), 0, ship.mass, ship.vfMax,5,ship.maxBrake)
    self.brakeDistanceRound = round2(math.abs(ship.brakeDistance), 2)
    -- Data types
    config = {
        dataType = "config",
        floors = {
            floor1 = ship.altHoldPreset1,
            floor2 = ship.altHoldPreset2,
            floor3 = ship.altHoldPreset3,
            floor4 = ship.altHoldPreset4,
        },
        rtb = helios:closestBody(ship.customTarget):getAltitude(ship.customTarget),
        targetAlt = 0,
        estop = false,
        settingsActive = false,
        manualControl = false,
        destination = nil,
        shutDown = false
        }
    function self.updateStats()
        stats.data.elevation = ship.altitude
        target = config.targetAlt
        stats.data.velocity = ship.world.velocity:len()
        stats.data.mass = ship.mass
        stats.data.gravity = ship.world.gravity:len()
        stats.data.target_dist = math.abs(ship.altitude - ship.altitudeHold)
        stats.data.brake_dist = self.brakeDistanceRound
        stats.data.deviation = ship.deviation
        stats.data.state = ship.stateMessage
    end
    self.updateStats()
    function self.updateScreenFuel()
        fuelAtmo.tanks = {}
        fuelSpace.tanks = {}

        for _, tank in pairs(SHUD.fuel.atmo) do
            table.insert(fuelAtmo.tanks,fuelTank(tank.time,math.ceil(100 * tank.level)))
        end
        for _, tank in pairs(SHUD.fuel.space) do
            table.insert(fuelSpace.tanks,fuelTank(tank.time,math.ceil(100 * tank.level)))
        end
        --for _, tank in pairs(SHUD.fuel.rocket) do fuelHtmlRocket = fuelHtmlRocket .. mkTankHtml("rocket", tank) end
        ioScheduler.queueData(fuelAtmo)
        ioScheduler.queueData(fuelSpace)
    end
    screen.clearScriptOutput()
    ioScheduler.defaultData = stats
    ioScheduler.queueData(config)
    ioScheduler.queueData(fuelAtmo)
    ioScheduler.queueData(fuelSpace)
    return self
end)()



