--@class STEC
--[[
    Shadow Templar Engine Control
    Version: 1.17

    Setup:
        - Put this file in system.start
        - Replace system.flush with: engines.apply()
        - Replace all controls with the appropriate STEC equivalent:
            - ship.direction.x - left/right
            - ship.direction.y - forward/back
            - ship.direction.z - forward/back
            - ship.rotation.x - pitch
            - ship.rotation.y - roll
            - ship.rotation.z - yaw
        - See comments for additional functionality
]]
function STEC(core, control, Cd)
    local self = {}
    self.core = core
    self.construct = construct
    self.control = control
    self.world = {
        up = vec3(construct.getWorldOrientationUp()),
        down = -vec3(construct.getWorldOrientationUp()),
        left = -vec3(construct.getWorldOrientationRight()),
        right = vec3(construct.getWorldOrientationRight()),
        forward = vec3(construct.getWorldOrientationForward()),
        back = -vec3(construct.getWorldOrientationForward()),
        velocity = vec3(construct.getWorldVelocity()),
        acceleration = vec3(construct.getWorldAcceleration()),
        position = vec3(construct.getWorldPosition()),
        gravity = vec3(core.getWorldGravity()),
        vertical = vec3(core.getWorldVertical()),
        atmosphericDensity = control.getAtmosphereDensity(),
        nearPlanet = unit.getClosestPlanetInfluence() > 0
    }
    self.target = {
        prograde = function() return self.world.velocity:normalize() end,
        retrograde = function() return -self.world.velocity:normalize() end,
        radial = function() return self.world.gravity:normalize() end,
        antiradial = function() return -self.world.gravity:normalize() end,
        normal = function() return self.world.velocity:normalize():cross(self.world.gravity:normalize()):normalize() end,
        antinormal = function() return self.world.velocity:normalize():cross(-self.world.gravity:normalize()):normalize() end,
    }
    -- Construct id
    self.id = construct.getId()
    -- Control Mode - Travel (0) or Cruise (1)
    self.controlMode = unit.getControlMode()
    -- Alternate Control Mode for remote control
    self.alternateCM = false
    -- Active engine tags
    self.tags = TagManager("all,brake")
    -- Target vector to face if non-0. Can take in a vec3 or function which returns a vec3
    self.targetVector = nil
    self.verticalLock = false
    self.lockVector = vec3(0,0,0)
    self.lockPos = vec3(0,0,0)
    -- Whether the target vector should unlock automatically if the ship is rotated by the pilot
    self.targetVectorAutoUnlock = true
    -- Current altitude
    self.altitude = 0
    -- Current mass of the vessel, in kilograms
    self.mass = self.construct.getMass()
    -- Amount of thrust to apply in world space, in Newton. Stacks with {{direction}}
    self.thrust = vec3(0, 0, 0)
    -- Amount of thrust to apply in local space, in percentage of fMax 0-1
    self.direction = vec3(0, 0, 0)
    -- Amount of rotation to apply in local space
    self.rotation = vec3(0, 0, 0)
    -- Speed scale factor for rotations
    self.rotationSpeed = 2
    -- Breaking speed multiplier
    self.brakingFactor = 10
    -- Amount of angular thrust to apply, in world space
    self.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity in directions that are not being accelerated towards
    self.inertialDampening = false
    -- Whether or not the vessel should attempt to completely cancel out its current velocity
    self.brake = false
    -- Whether or not the vessel should attempt to counter gravity influence
    self.counterGravity = true
    -- Whether or not the vessel should attempt to face perpendicular to the gravity vector
    self.followGravity = false
    -- Aggressiveness of the gravity follow adjustment
    self.gravityFollowSpeed = 10
    -- Speed (in km/h) in which to limit the velocity of the ship
    self.speedLimiter = 1000 --export: Limit ship's velocity
    -- Variable speed limit based on delta distance in altitude hold mode
    self.variableSpeedLimit = 1000
    -- Toggle speed limiter on/off
    self.speedLimiterToggle = true --export: Toggle speed limit on/off
    -- Amount of throttle to apply. 0-1 range
    self.throttle = 1
    -- Maximum thrust which the vessel is capable of producing
    self.fMax = 0
    -- Toggle altitude hold on/off
    self.altitudeHoldToggle = false
    -- Altitude which the vessel should attempt to hold
    self.altitudeHold = 0
    -- Speed which the vessel should attempt to maintain
    self.cruiseSpeed = 0
    -- Whether or not to ignore throttle for vertical thrust calculations
    self.ignoreVerticalThrottle = false
    -- Local velocity
    self.localVelocity = vec3(construct.getVelocity())
    -- Roll Degrees
    self.rollDegrees = self.world.vertical:angle_between(self.world.left) / math.pi * 180 - 90
    if self.world.vertical:dot(self.world.up) > 0 then self.rollDegrees = 180 - self.rollDegrees end
    -- Pitch
    self.pitchRatio = self.world.vertical:angle_between(self.world.forward) / math.pi - 0.5

    local lastUpdate = system.getArkTime()

    function self.updateWorld()
        self.world = {
            up = vec3(construct.getWorldOrientationUp()),
            down = -vec3(construct.getWorldOrientationUp()),
            left = -vec3(construct.getWorldOrientationRight()),
            right = vec3(construct.getWorldOrientationRight()),
            forward = vec3(construct.getWorldOrientationForward()),
            back = -vec3(construct.getWorldOrientationForward()),
            velocity = vec3(construct.getWorldVelocity()),
            acceleration = vec3(construct.getWorldAcceleration()),
            position = vec3(construct.getWorldPosition()),
            gravity = vec3(core.getWorldGravity()),
            vertical = vec3(core.getWorldVertical()),
            atmosphericDensity = control.getAtmosphereDensity(),
            nearPlanet = unit.getClosestPlanetInfluence() > 0
        }
	   -- Roll Degrees
        self.rollDegrees = self.world.vertical:angle_between(self.world.left) / math.pi * 180 - 90
        if self.world.vertical:dot(self.world.up) > 0 then self.rollDegrees = 180 - self.rollDegrees end
        -- Pitch
        self.pitchRatio = self.world.vertical:angle_between(self.world.forward) / math.pi - 0.5

        self.AngularVelocity = vec3(construct.getWorldAngularVelocity())
        self.AngularAcceleration = vec3(construct.getWorldAngularAcceleration())
        self.AngularAirFriction = vec3(construct.getWorldAirFrictionAngularAcceleration())

	   self.airFriction = vec3(construct.getWorldAirFrictionAcceleration())

        self.mass = self.construct.getMass()
        self.altitude = self.core.getAltitude()
        self.localVelocity = vec3(construct.getVelocity())
        local fMax = construct.getMaxThrustAlongAxis("all", {vec3(0,1,0):unpack()})
        if self.world.atmosphericDensity > 0.1 then --Temporary hack. Needs proper transition.
            self.fMax = math.max(fMax[1], -fMax[2])
        else
            self.fMax = math.max(fMax[3], -fMax[4])
        end
    end

    function self.calculateAccelerationForce(acceleration, time)
        return self.mass * (acceleration / time)
    end

    function clamp(n, min, max)
        return math.min(max, math.max(n, min))
    end
    function round(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end
    function self.throttleUp()
        self.throttle = clamp(self.throttle + 0.05, 0, 1)
    end

    function self.throttleDown()
        self.throttle = clamp(self.throttle - 0.05, 0, 1)
    end

    function self.worldToLocal(vector)
        return vec3(
            library.systemResolution3(
                {self.world.right:unpack()},
                {self.world.forward:unpack()},
                {self.world.up:unpack()},
                {vector:unpack()}
            )
        )
    end

    function self.localToWorld(vector)
        vector = {vector:unpack()}
        local rightX, rightY, rightZ = self.world.right:unpack()
        local forwardX, forwardY, forwardZ = self.world.forward:unpack()
        local upX, upY, upZ = self.world.up:unpack()
        local rfuX, rfuY, rfuZ = vector:unpack()
        local relX = rfuX * rightX + rfuY * forwardX + rfuZ * upX
        local relY = rfuX * rightY + rfuY * forwardY + rfuZ * upY
        local relZ = rfuX * rightZ + rfuY * forwardZ + rfuZ * upZ
        return vec3(relX, relY, relZ)
    end

    function self.apply()
        local deltaTime = math.max(system.getArkTime() - lastUpdate, 0.001) --If delta is below 0.001 then something went wrong in game engine.
        self.updateWorld()
        local tmp = self.thrust
        local atmp = self.angularThrust

        if self.direction.x ~= 0 then
            tmp = tmp + (((self.world.right * self.direction.x) * self.fMax) * self.throttle)
        end
        if self.direction.y ~= 0 then
            tmp = tmp + (((self.world.forward * self.direction.y) * self.fMax) * self.throttle)
        end
        if self.direction.z ~= 0 then
            local a = ((self.world.up * self.direction.z) * self.fMax)
            if not self.ignoreVerticalThrottle then a = a * self.throttle end
            tmp = tmp + a
        end
        if self.rotation.x ~= 0 then
            atmp = atmp + ((self.world.forward:cross(self.world.up) * self.rotation.x) * self.rotationSpeed)
            if self.targetVectorAutoUnlock then
                self.targetVector = nil
            end
        end
        if self.rotation.y ~= 0 then
            atmp = atmp + ((self.world.up:cross(self.world.right) * self.rotation.y) * self.rotationSpeed)
        end
        if self.rotation.z ~= 0 then
            atmp = atmp + ((self.world.forward:cross(self.world.right) * self.rotation.z) * self.rotationSpeed)
            if self.targetVectorAutoUnlock then
                self.targetVector = nil
            end
        end
        if self.followGravity and self.rotation.x == 0 then
		  local current = self.localVelocity:len() * self.mass
            local scale = nil
            if ship.localVelocity:len() > 10 then
                scale = self.gravityFollowSpeed * math.min(math.max(current / self.fMax, 0.1), 1) * 10
            else
                scale = self.gravityFollowSpeed
            end
            atmp = atmp + (self.world.up:cross(-self.world.vertical) * scale)
        end
        ahTmpd = 0.125
        if self.altitudeHoldToggle then
            local deltaAltitude =  self.altitudeHold - self.altitude
            local tempd = math.abs(deltaAltitude) / (100 * math.abs(self.localVelocity.z))
            if deltaAltitude < 1 and (math.abs(self.localVelocity.z)) < 0 then
                ahTmpd = deltaTime
            else
                ahTmpd = utils.clamp(tempd, 0.001, 0.125)
            end
            if deltaAltitude > 10 then
                self.variableSpeedLimit = utils.clamp(math.abs(deltaAltitude),50,self.speedLimiter)
            else
                self.variableSpeedLimit = self.speedLimiter
            end
            
            tmp = tmp - ((self.world.gravity * self.mass) * deltaAltitude)
	    end
        if self.alternateCM then
          local speed = (self.cruiseSpeed / 3.6)
          local dot = self.world.forward:dot(self.airFriction)
          local modifiedVelocity = (speed - dot)
          local desired = self.world.forward * modifiedVelocity
          local delta = (desired - (self.world.velocity - self.world.acceleration))

          tmp = tmp + (delta * self.mass)
        end
        
        if self.inertialDampening then
            local brakingForce = self.mass * -self.localVelocity
            local apply = self.direction * self.localVelocity
            if apply.x <= 0 then
                local tmpd = deltaTime
                if self.altitudeHoldToggle then tmpd = ahTmpd end
                if (math.abs(self.localVelocity.x) < 1) then
                        tmpd = 0.125
                end
                tmp = tmp + (self.world.right * brakingForce.x) / tmpd
            end
            if apply.y <= 0 then
                local tmpd = deltaTime
                if self.altitudeHoldToggle then tmpd = ahTmpd end
                if (math.abs(self.localVelocity.y) < 1) then
                        tmpd = 0.125
                end
                tmp = tmp + (self.world.forward * brakingForce.y) / tmpd
            end
            if apply.z <= 0 then
                local tmpd = deltaTime
                if self.altitudeHoldToggle then tmpd = ahTmpd end
                if (math.abs(self.localVelocity.z) < 1) then
                        tmpd = 0.125
                end
                tmp = tmp + (self.world.up * brakingForce.z) / tmpd
            end
        end
        if self.brake then
            local velocityLen = self.world.velocity:len()
            tmp =
                -self.world.velocity * self.mass *
                math.max(self.brakingFactor * math.max(1, velocityLen * 0.5), velocityLen * velocityLen)
        end
        if self.targetVector ~= nil then
            local vec = vec3(self.world.forward.x, self.world.forward.y, self.world.forward.z)
            if type(self.targetVector) == "function" then
                vec = self.targetVector()
            elseif type(self.targetVector) == "table" then
                vec = self.targetVector
            end
            atmp = atmp + (self.world.forward:cross(vec) * self.rotationSpeed)
        end
        --Speed limiter
        if self.speedLimiterToggle then
            local currentVelocity = self.world.velocity:len()
            local speedLimit
            if self.altitudeHoldToggle then 
                speedLimit = self.variableSpeedLimit
            else
                speedLimit = self.speedLimiter
            end
            local speedLimitInMs = speedLimit / 3.6
            if currentVelocity > speedLimitInMs then
                local movementVector = self.world.velocity:normalize()
                local maxVelocityVector = movementVector * speedLimitInMs
                local deltaVelocityVector = self.world.velocity - maxVelocityVector
                system.print("Speed limit: "..speedLimit.." Speed Limit (m/s): "..speedLimitInMs)
                tmp = tmp - (deltaVelocityVector / deltaTime) * self.mass
            end
        end
        
        -- must be applied last
        if self.counterGravity then
            tmp = tmp - self.world.gravity * self.mass
        end

        if self.verticalLock then
            local localPos = (self.world.position + self.world.up * 1.235) - self.lockPos
            local intersectionPos = self.lockVector * self.lockVector:dot(localPos)
            local intersectionVec = intersectionPos - localPos
            local thrustForce = intersectionVec * self.mass * deltaTime * 2
            system.print("thrustForce: " .. tostring(thrustForce))
            tmp = tmp + thrustForce * self.mass
         end

        atmp = atmp - ((self.AngularVelocity * 2) - (self.AngularAirFriction * 2))
        tmp = tmp / self.mass
        if self.controlMode ~= unit.getControlMode() then
            self.controlMode = unit.getControlMode()
            if unit.getControlMode() == 0 then self.alternateCM = false end
            if unit.getControlMode() == 1 then self.alternateCM = true end
        end
        

        self.control.setEngineCommand(tostring(self.tags), {tmp:unpack()}, {atmp:unpack()})
        atmp = vec3(0, 0, 0)
        tmp = vec3(0, 0, 0)
        lastUpdate = system.getArkTime()
    end

    return self
end

ship = STEC(core, unit)