--[[
    Shadow Templar Engine Control
    Version: 1.14

    Setup:
        - Put this file in system.start
        - Replace system.flush with: engines.apply()
        - Replace all controls with the appropriate STEC equivalent:
            - engines.direction.x - left/right
            - engines.direction.y - forward/back
            - engines.direction.z - forward/back
            - engines.rotation.x - pitch
            - engines.rotation.y - roll
            - engines.rotation.z - yaw
        - See comments for additional functionality
]]
function STEC(core, control, Cd)
    local self = {}
    self.world = {
        up = vec3(core.getConstructWorldOrientationUp()),
        down = -vec3(core.getConstructWorldOrientationUp()),
        left = -vec3(core.getConstructWorldOrientationRight()),
        right = vec3(core.getConstructWorldOrientationRight()),
        forward = vec3(core.getConstructWorldOrientationForward()),
        back = -vec3(core.getConstructWorldOrientationForward()),
        id = core.getConstructId()
    }
    self.target = {
        prograde = function() return self.velocity:normalize() end,
        retrograde = function() return -self.velocity:normalize() end
    }
    self.core = core
    self.control = control
    self.tags = TagManager("all,brake")
    -- Current gravity vector
    self.gravity = vec3(0, 0, 0)
    -- Current velocity vector
    self.velocity = vec3(core.getWorldVelocity())
    -- Current acceleration vector
    self.acceleration = vec3(core.getWorldAcceleration())
    -- Target vector to face if non-0. Can take in a vec3 or function which returns a vec3
    self.targetVector = nil
    -- Whether the target vector should unlock automatically if the ship is rotated by the pilot
    self.targetVectorAutoUnlock = true
    -- Current atmospheric density
    self.atmosDensity = 0
    -- Current altitude
    self.altitude = 0
    -- Drag coefficient of the vessel
    self.Cd = Cd
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
    -- Amount of angular thrust to apply, in world space
    self.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity
    self.brake = false
    -- Whether or not the vessel should attempt to counter gravity influence
    self.counterGravity = true
    -- Whether or not the vessel should attempt to face perpendicular to the gravity vector
    self.followGravity = false
    -- Aggressiveness of the gravity follow adjustment
    self.gravityFollowSpeed = 4
    -- Amount of throttle to apply. 0-1 range
    self.throttle = 1
    -- Maximum thrust which the vessel is capable of producing
    self.fMax = 0
    -- Altitude which the vessel should attempt to hold
    self.altitudeHold = 0

    local lastUpdate = system.getTime()

    -- Returns construct's terminal velocity, or 0 if in space
    function self.getTerminalVelocity()
        local atmosDensity = self.core.getAtmosphereDensity()
        local gravity = self.core.g()
        local area = self.core.getConstructCrossSection()
        if atmosDensity == 0 then
            return 0
        end
        return (2 * self.mass * gravity) / ((atmosDensity * self.core.getAtmosphereDensity()) * area * self.Cd)
    end

    function self.getStoppingForceRequired()
        local velocity = vec3(self.core.getWorldVelocity())
        return self.mass * -velocity
    end

    function self.updateDragCoefficient()
        --self.Cd =
    end

    function self.updateWorld()
        self.world.up = vec3(self.core.getConstructWorldOrientationUp())
        self.world.down = -self.world.up
        self.world.right = vec3(self.core.getConstructWorldOrientationRight())
        self.world.left = -self.world.right
        self.world.forward = vec3(self.core.getConstructWorldOrientationForward())
        self.world.back = -self.world.forward
        self.gravity = vec3(self.core.getWorldGravity())
        self.atmosDensity = self.control.getAtmosphereDensity()
        self.mass = self.core.getConstructMass()
        self.altitude = self.core.getAltitude()
        self.velocity = vec3(self.core.getWorldVelocity())
        self.acceleration = vec3(self.core.getWorldAcceleration())
        local fMax = self.core.getMaxKinematicsParameters()
        if self.atmosDensity > 0 then
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

    function self.throttleUp()
        self.throttle = clamp(self.throttle + 0.05, 0, 1)
    end

    function self.throttleDown()
        self.throttle = clamp(self.throttle - 0.05, 0, 1)
    end

    function self.applyThrust(tags, vector)
        self.control.setEngineCommand(tags, {vector:unpack()}, {vec3(0,0,0):unpack()})
    end

    function self.apply()
        local deltaTime = system.getTime() - lastUpdate
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
            tmp = tmp + (((self.world.up * self.direction.z) * self.fMax) * self.throttle)
        end
        if self.rotation.x ~= 0 then
            atmp = atmp + ((self.world.forward:cross(self.world.up) * self.rotation.x) * self.rotationSpeed)
            if self.targetVectorAutoUnlock then self.targetVector = nil end
        end
        if self.rotation.y ~= 0 then
            atmp = atmp + ((self.world.up:cross(self.world.right) * self.rotation.y) * self.rotationSpeed)
        end
        if self.rotation.z ~= 0 then
            atmp = atmp + ((self.world.forward:cross(self.world.right) * self.rotation.z) * self.rotationSpeed)
            if self.targetVectorAutoUnlock then self.targetVector = nil end
        end
        if self.counterGravity and self.direction.z == 0 then
            tmp = tmp + -self.gravity
        end
        if self.followGravity and self.rotation.x == 0 then
            atmp = atmp + (self.world.up:cross(-self.gravity:normalize()) * self.gravityFollowSpeed)
        end
        if self.altitudeHold ~= 0 then
            local deltaAltitude = self.altitude - self.altitudeHold
            tmp = tmp + ((self.gravity:normalize() * deltaAltitude * -1) * self.mass * deltaTime)
        end
        if self.brake then
            local f = self.getStoppingForceRequired():len()
            tmp = self.getStoppingForceRequired() * f * deltaTime
        end
        if self.targetVector ~= nil then
            local vec = vec3(self.world.forward.x,self.world.forward.y,self.world.forward.z)
            if type(self.targetVector) == "function" then 
                vec = self.targetVector()
            elseif type(self.targetVector) == "table" then
                vec = self.targetVector
            end
            atmp = atmp + (self.world.forward:cross(vec) * self.rotationSpeed)
        end
        self.control.setEngineCommand(tostring(self.tags), {tmp:unpack()}, {atmp:unpack()})
        lastUpdate = system.getTime()
    end

    return self
end

engines = STEC(core, unit, 0.9)