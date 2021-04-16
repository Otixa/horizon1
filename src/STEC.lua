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
planetaryReference = PlanetRef()
galaxyReference = planetaryReference(Atlas())
helios = galaxyReference[0]
kinematics = Kinematics()
local jdecode = json.decode
local maxBrake = jdecode(unit.getData()).maxBrake

function STEC(core, control, Cd)
    local self = {}
    self.core = core
    self.control = control
    self.nearestPlanet = helios:closestBody(core.getConstructWorldPos())
    self.world = {
        up = vec3(core.getConstructWorldOrientationUp()),
        down = -vec3(core.getConstructWorldOrientationUp()),
        left = -vec3(core.getConstructWorldOrientationRight()),
        right = vec3(core.getConstructWorldOrientationRight()),
        forward = vec3(core.getConstructWorldOrientationForward()),
        back = -vec3(core.getConstructWorldOrientationForward()),
        velocity = vec3(core.getWorldVelocity()),
        acceleration = vec3(core.getWorldAcceleration()),
        position = vec3(core.getConstructWorldPos()),
        gravity = vec3(core.getWorldGravity()),
        vertical = vec3(core.getWorldVertical()),
        atmosphericDensity = control.getAtmosphereDensity(),
        nearPlanet = unit.getClosestPlanetInfluence() > 0,
        atlasAltitude = self.nearestPlanet:getAltitude(core.getConstructWorldPos())
    }
    self.target = {
        prograde = function() return self.world.velocity:normalize() end,
        retrograde = function() return -self.world.velocity:normalize() end,
        radial = function() return self.world.gravity:normalize() end,
        antiradial = function() return -self.world.gravity:normalize() end,
        normal = function() return self.world.velocity:normalize():cross(self.world.gravity:normalize()):normalize() end,
        antinormal = function() return self.world.velocity:normalize():cross(-self.world.gravity:normalize()):normalize() end,
    }
    self.customTarget = vec3(0,0,0)
    -- Construct id
    self.id = core.getConstructId()
    -- Control Mode - Travel (0) or Cruise (1)
    self.controlMode = unit.getControlMasterModeId()
    -- Alternate Control Mode for remote control
    self.alternateCM = false
    -- Active engine tags
    self.tags = TagManager("all,brake")
    -- Target vector to face if non-0. Can take in a vec3 or function which returns a vec3
    self.targetVector = nil
    self.targetDestination = nil
    self.verticalLock = false
    self.lockVector = vec3(0,0,0)
    self.lockPos = vec3(0,0,0)
    self.altHoldPreset1 = 0
    self.altHoldPreset2 = 0
    self.pocket = false
    -- Whether the target vector should unlock automatically if the ship is rotated by the pilot
    self.targetVectorAutoUnlock = true
    -- Current altitude
    self.altitude = 0
    -- Current mass of the vessel, in kilograms
    self.mass = self.core.getConstructMass()
    -- Amount of thrust to apply in world space, in Newton. Stacks with {{direction}}
    self.thrust = vec3(0, 0, 0)
    -- Amount of thrust to apply in local space, in percentage of fMax 0-1
    self.direction = vec3(0, 0, 0)
    -- Amount of rotation to apply in local space
    self.rotation = vec3(0, 0, 0)
    -- Speed scale factor for rotations
    self.rotationSpeed = 2
    -- Minimum rotation speed for auto-scale
    self.rotationSpeedzMin = 0.01
    -- Rotation Speed on x axis
    self.rotationSpeedz = 0.01
    -- Max rotation speed for auto-scale
    self.maxRotationSpeedz = 3
    -- Auto-scale rotation Setup
    self.rotationStep = 0.03
    -- Breaking speed multiplier
    self.brakingFactor = 10
    -- Amount of angular thrust to apply, in world space
    self.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity in directions that are not being accelerated towards
    self.inertialDampening = false
    -- Desired state of intertialDampening
    self.inertialDampeningDesired = false
    -- Whether or not the vessel should attempt to completely cancel out its current velocity
    self.brake = false
    -- Whether or not the vessel should attempt to counter gravity influence
    self.counterGravity = true
    -- Whether or not the vessel should attempt to face perpendicular to the gravity vector
    self.followGravity = false
    -- Aggressiveness of the gravity follow adjustment
    self.gravityFollowSpeed = 6
    -- Speed (in km/h) in which to limit the velocity of the ship
    self.speedLimiter = 2000
    -- Variable speed limit based on delta distance in altitude hold mode
    self.variableSpeedLimit = 2000
    -- Toggle speed limiter on/off
    self.speedLimiterToggle = true
    -- Vertical Speed Limit (Atmo)
    self.verticalSpeedLimitAtmo = 750
    -- Vertical Speed Limit (Space)
    self.verticalSpeedLimitAtmo = 2000
    -- Amount of throttle to apply. 0-1 range
    self.throttle = 1
    -- Maximum thrust which the vessel is capable of producing
    self.fMax = 0
    self.vfMax = 0
    self.hfMax = 0
    -- Toggle altitude hold on/off
    self.altitudeHoldToggle = false
    -- Altitude which the vessel should attempt to hold
    self.altitudeHold = 0
    -- Atmosphere density Threshold
    self.atmosphereThreshold = 0
    -- Speed which the vessel should attempt to maintain
    self.cruiseSpeed = 0
    -- Whether or not to ignore throttle for vertical thrust calculations
    self.ignoreVerticalThrottle = false
    -- Local velocity
    self.localVelocity = vec3(core.getVelocity())
    -- Roll Degrees
    self.rollDegrees = self.world.vertical:angle_between(self.world.left) / math.pi * 180 - 90
    if self.world.vertical:dot(self.world.up) > 0 then self.rollDegrees = 180 - self.rollDegrees end
    -- Pitch
    self.pitchRatio = self.world.vertical:angle_between(self.world.forward) / math.pi - 0.5
    --Vertical Cruise Toggle (for elevator stuff)
    self.verticalCruise = false
    --Vertical Cruise Speed (for elevator stuff)
    self.verticalCruiseSpeed = 0

    local lastUpdate = system.getTime()

    function self.updateWorld()
        self.world = {
            up = vec3(core.getConstructWorldOrientationUp()),
            down = -vec3(core.getConstructWorldOrientationUp()),
            left = -vec3(core.getConstructWorldOrientationRight()),
            right = vec3(core.getConstructWorldOrientationRight()),
            forward = vec3(core.getConstructWorldOrientationForward()),
            back = -vec3(core.getConstructWorldOrientationForward()),
            velocity = vec3(core.getWorldVelocity()),
            acceleration = vec3(core.getWorldAcceleration()),
            position = vec3(core.getConstructWorldPos()),
            gravity = vec3(core.getWorldGravity()),
            vertical = vec3(core.getWorldVertical()),
            atmosphericDensity = control.getAtmosphereDensity(),
            nearPlanet = unit.getClosestPlanetInfluence() > 0,
        }
        self.nearestPlanet = helios:closestBody(core.getConstructWorldPos())
	   -- Roll Degrees
        self.rollDegrees = self.world.vertical:angle_between(self.world.left) / math.pi * 180 - 90
        if self.world.vertical:dot(self.world.up) > 0 then self.rollDegrees = 180 - self.rollDegrees end
        -- Pitch
        self.pitchRatio = self.world.vertical:angle_between(self.world.forward) / math.pi - 0.5

        self.AngularVelocity = vec3(core.getWorldAngularVelocity())
        self.AngularAcceleration = vec3(core.getWorldAngularAcceleration())
        self.AngularAirFriction = vec3(core.getWorldAirFrictionAngularAcceleration())

	    self.airFriction = vec3(core.getWorldAirFrictionAcceleration())
        self.atmosphereThreshold = helios:closestBody(core.getConstructWorldPos()).noAtmosphericDensityAltitude
        self.mass = self.core.getConstructMass()
        --self.altitude = self.core.getAltitude()
        self.altitude = helios:closestBody(core.getConstructWorldPos()):getAltitude(core.getConstructWorldPos())
        self.localVelocity = vec3(core.getVelocity())
        self.maxBrake = jdecode(unit.getData()).maxBrake
        local fMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,1,0):unpack()})
        local vfMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,0,1):unpack()})
        local hfMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(1,0,0):unpack()})
        if self.world.atmosphericDensity > 0.1 then --Temporary hack. Needs proper transition.
            self.fMax = math.max(fMax[1], -fMax[2])
        else
            self.fMax = math.max(fMax[3], -fMax[4])
        end
        if self.world.atmosphericDensity > 0.1 then --Temporary hack. Needs proper transition.
            self.vfMax = math.max(vfMax[1], -vfMax[2])
        else
            self.vfMax = math.max(vfMax[3], -vfMax[4])
        end
        if self.world.atmosphericDensity > 0.1 then --Temporary hack. Needs proper transition.
            self.hfMax = math.max(hfMax[1], -hfMax[2])
        else
            self.hfMax = math.max(hfMax[3], -hfMax[4])
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

    function MsToKmh(ms)
        return ms * 3.6
    end
    function KmhToMs(kmh)
        return kmh / 3.6
    end

    function self.apply()
        local deltaTime = math.max(system.getTime() - lastUpdate, 0.001) --If delta is below 0.001 then something went wrong in game engine.
        self.updateWorld()
        local tmp = self.thrust
        local atmp = self.angularThrust
        local gravityCorrection = false
        local fMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,1,0):unpack()})
        local vfMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(0,0,1):unpack()})
        local hfMax = core.getMaxKinematicsParametersAlongAxis("all", {vec3(1,0,0):unpack()})
        if not self.altitudeHoldToggle then self.inertialDampening = self.inertialDampeningDesired end
        
        if self.direction.x ~= 0 then
            local dot  = (1 - self.world.up:dot(-self.world.gravity:normalize())) * (self.mass * 0.000095) -- Magic number is magic
            local gravCorrection = -self.world.vertical * dot

            if self.direction.x < 0 and math.abs(round2(hfMax[2],0)) < 500 then
                gravityCorrection = true
                tmp = tmp + ((((self.world.right * self.direction.x) + gravCorrection):normalize() * self.fMax) * self.throttle)
            elseif self.direction.x > 0 and math.abs(round2(hfMax[1],0)) < 500 then
                gravityCorrection = true
                tmp = tmp + ((((self.world.right * self.direction.x) + gravCorrection):normalize() * self.fMax) * self.throttle)
            else
                tmp = tmp + (((self.world.right * self.direction.x) * self.fMax) * self.throttle) -- OG code
            end
        end
        
        if self.direction.y ~= 0 then
            
            --tmp = tmp + (((self.world.forward * self.direction.y) * self.fMax) * self.throttle)
            --tmp = tmp + (((self.world.gravity:normalize():cross(-self.world.right) * self.direction.y) * self.fMax) * self.throttle)
            local dot  = (1 - self.world.up:dot(-self.world.gravity:normalize())) * (self.mass * 0.000095)
            local gravCorrection = -self.world.vertical * dot
            --system.print(math.abs(round2(fMax[2],0)))
            if self.direction.y < 0 and math.abs(round2(fMax[2],0)) == 0 then
                gravityCorrection = true
                tmp = tmp + ((((self.world.forward * self.direction.y) + gravCorrection):normalize() * self.fMax) * self.throttle)
            else
                tmp = tmp + (((self.world.forward * self.direction.y) * self.fMax) * self.throttle)
            end
            
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
            if self.rotationSpeedz <= self.maxRotationSpeedz then self.rotationSpeedz = self.rotationSpeedz + self.rotationStep end
            --system.print("Rotation Speed: "..self.rotationSpeedz)
            atmp = atmp + ((self.world.forward:cross(self.world.right) * self.rotation.z) * clamp(self.rotationSpeedz, 0.01, self.maxRotationSpeedz))
            if self.targetVectorAutoUnlock then
                self.targetVector = nil
            end
        end
        if self.followGravity and self.rotation.x == 0 then
            
          --system.print(tostring(self.direction))
		    local current = self.localVelocity:len() * self.mass
            local scale = nil
            --if ship.localVelocity:len() > 10 then
            --    scale = self.gravityFollowSpeed * math.min(math.max(current / self.fMax, 0.1), 1) * 10
            --else
            --    scale = self.gravityFollowSpeed
            --end
            local gFollow = (self.world.up:cross(-self.nearestPlanet:getGravity(core.getConstructWorldPos())))
            local scale = 1
            if pocket then
                if self.direction.x < 0 and math.abs(round2(hfMax[2],0)) < 500 then
                    scale = 0.25
                    gFollow = gFollow + ship.world.right:cross(-self.nearestPlanet:getGravity(core.getConstructWorldPos()) * 0.25)
                elseif self.direction.x > 0 and math.abs(round2(hfMax[1],0)) < 500 then
                    scale = 0.25
                    gFollow = gFollow - ship.world.right:cross(-self.nearestPlanet:getGravity(core.getConstructWorldPos()) * 0.25)
                elseif self.direction.y < 0 and math.abs(round2(fMax[2],0)) == 0 then
                    gFollow = gFollow + ship.world.forward:cross(-self.nearestPlanet:getGravity(core.getConstructWorldPos()) * 0.25)
                end
            end
            gFollow = gFollow * scale
            atmp = atmp + gFollow
        end
        if self.verticalCruise then
            local speed = (self.verticalCruiseSpeed / 3.6)
            local dot = self.world.up:dot(self.airFriction)
            local modifiedVelocity = (speed - dot)
            local desired = self.world.up * modifiedVelocity
            local delta = (desired - (self.world.velocity - self.world.acceleration))

            tmp = tmp + (delta * self.mass)
        end
        ahTmpd = 0.125
        if self.altitudeHoldToggle then
            
            local deltaAltitude =  self.altitudeHold - self.altitude
            local brakeBuffer = 1000
            --if (self.altitudeHold - self.altitude) > 0.1 and self.altitude < self.altitudeHold then deltaAltitude = deltaAltitude + 20 end
            local tempd = math.abs(deltaAltitude) / (100 * math.abs(self.localVelocity.z))
            if deltaAltitude < 1 and (math.abs(self.localVelocity.z)) < 0 then
                ahTmpd = deltaTime
            else
                ahTmpd = utils.clamp(tempd, 0.001, 0.125)
            end

            local breakDistance, accelTime = kinematics.computeDistanceAndTime(self.world.velocity:len(), 0, self.mass, self.vfMax,20,self.maxBrake)
            
            if math.abs(deltaAltitude) > breakDistance and math.abs(deltaAltitude) > 5 then
                self.inertialDampening = false
                local verticalSpeedLimit
                if self.altitude <= (self.atmosphereThreshold + breakDistance) or self.altitude <= breakDistance then 
                    verticalSpeedLimit = self.verticalSpeedLimitAtmo 
                else 
                    verticalSpeedLimit = self.verticalSpeedLimitSpace 
                end
                if  (breakDistance + brakeBuffer) >= math.abs(deltaAltitude) then
                    verticalSpeedLimit = 200
                end
                
                local speed = round2((clamp(deltaAltitude, -verticalSpeedLimit, verticalSpeedLimit) / 3.6), 1)
                if math.modf(self.altitude) ==  math.modf(self.altitudeHold) then
                        speed = 0
                        self.inertialDampening = true
                end

                self.inertialDampening = false
                local dot = self.world.up:dot(self.airFriction)
                local modifiedVelocity = (speed - dot)
                local desired = self.world.up * modifiedVelocity
                local delta = (desired - (self.world.velocity - self.world.acceleration))
                tmp = tmp + (delta * (self.mass))
                
                
            else
                self.inertialDampening = true
                tmp = tmp - ((self.world.gravity * (self.mass)) * deltaAltitude)
            end
            
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
                --system.print("apply.x")
                local tmpd = deltaTime
                --if self.altitudeHoldToggle then tmpd = ahTmpd end
                if (math.abs(self.localVelocity.x) < 1) then
                        tmpd = 0.125
                end
                tmp = tmp + (self.world.right * brakingForce.x) / tmpd
            end
            if apply.y <= 0 then
                --system.print("apply.y")
                local tmpd = deltaTime
                --if self.altitudeHoldToggle then tmpd = ahTmpd end
                if (math.abs(self.localVelocity.y) < 1) then
                        tmpd = 0.125
                end
                tmp = tmp + (self.world.forward * brakingForce.y) / tmpd
            end
            if apply.z <= 0 and gravityCorrection == false then
                --system.print("apply.z")
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
            atmp = atmp + (self.world.forward:cross(vec) * self.rotationSpeed)  - ((self.AngularVelocity * 2) - (self.AngularAirFriction * 2))
        end
        
        -- must be applied last
        if self.counterGravity then
            tmp = tmp - self.nearestPlanet:getGravity(core.getConstructWorldPos()) * self.mass
        end

        if self.verticalLock then
            local localPos = (self.world.position + self.world.up) - self.lockPos
            local intersectionPos = self.lockVector * self.lockVector:dot(localPos)
            local intersectionVec = intersectionPos - localPos
            local thrustForce = intersectionVec * self.mass * deltaTime
            --system.print("thrustForce: " .. tostring(thrustForce))
            tmp = tmp + thrustForce * self.mass
         end

         if self.targetDestination ~= nil then
            tmp = tmp + (self.targetDestination - self.world.position) * self.mass * deltaTime
         end

        atmp = atmp - ((self.AngularVelocity * 2) - (self.AngularAirFriction * 2))
        tmp = tmp / self.mass

        if self.controlMode ~= unit.getControlMasterModeId() then
            self.controlMode = unit.getControlMasterModeId()
            if unit.getControlMasterModeId() == 0 then self.alternateCM = false end
            if unit.getControlMasterModeId() == 1 then self.alternateCM = true end
        end


        self.control.setEngineCommand(tostring(self.tags), {tmp:unpack()}, {atmp:unpack()})
        atmp = vec3(0, 0, 0)
        tmp = vec3(0, 0, 0)
        lastUpdate = system.getTime()
    end

    return self
end

ship = STEC(core, unit)
