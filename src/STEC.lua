--[[
    Shadow Templar Engine Control
    Version: 1.16

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
ship = (function (core, control, Cd)
    local this = {}
    this.world = {}
    this.target = {
        prograde = function() return this.world.velocity:normalize() end,
        retrograde = function() return -this.world.velocity:normalize() end,
        radial = function() return this.world.gravity:normalize() end,
        antiradial = function() return -this.world.gravity:normalize() end,
        normal = function() return this.world.velocity:normalize():cross(this.world.gravity:normalize()):normalize() end,
        antinormal = function() return this.world.velocity:normalize():cross(-this.world.gravity:normalize()):normalize() end,
    }
    -- Construct id
    this.id = core.getConstructId()
    -- Active engine tags
    this.tags = TagManager("all,brake")
    -- Target vector to face if non-nil. Can take in a vec3 or function which returns a vec3
    this.targetVector = nil
    -- Whether the target vector should unlock automatically if the ship is rotated by the pilot
    this.targetVectorAutoUnlock = true
    -- Current altitude
    this.altitude = 0
    -- Current mass of the vessel, in kilograms
    this.mass = core.getConstructMass()
    -- Amount of thrust to apply in world space, in Newton. Stacks with {{direction}}
    this.thrust = vec3(0, 0, 0)
    -- Amount of thrust to apply in local space, in percentage of fMax 0-1
    this.direction = vec3(0, 0, 0)
    -- Amount of rotation to apply in local space
    this.rotation = vec3(0, 0, 0)
    -- Speed scale factor for rotations
    this.rotationSpeed = 2
    -- Breaking speed multiplier
    this.brakingFactor = 10
    -- Amount of angular thrust to apply, in world space
    this.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity in directions that are not being accelerated towards
    this.inertialDampening = false
    -- Whether or not the vessel should attempt to completely cancel out its current velocity
    this.brake = false
    -- Whether or not the vessel should attempt to counter gravity influence
    this.counterGravity = true
    -- Whether or not the vessel should attempt to face perpendicular to the gravity vector
    this.followGravity = false
    -- Aggressiveness of the gravity follow adjustment
    this.gravityFollowSpeed = 4
    -- Amount of throttle to apply. 0-1 range
    this.throttle = 1
    -- Maximum thrust which the vessel is capable of producing
    this.fMax = 0
    -- Altitude which the vessel should attempt to hold
    this.altitudeHold = nil
    -- Whether or not to ignore throttle for vertical thrust calculations
    this.ignoreVerticalThrottle = false

    local lastUpdate = system.getTime()

    function this.updateWorld()
        this.world = {
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
            atmosphericDensity = control.getAtmosphereDensity()
        }

        this.mass = core.getConstructMass()
        this.altitude = core.getAltitude()
        this.localVelocity = vec3(core.getVelocity())
        local fMax = core.getMaxKinematicsParameters()
        if this.world.atmosphericDensity > 0.1 then --Temporary hack. Needs proper transition.
            this.fMax = math.max(fMax[1], -fMax[2])
        else
            this.fMax = math.max(fMax[3], -fMax[4])
        end
    end

    function this.worldToLocal(vector)
        return vec3(
            library.systemResolution3(
                {this.world.right:unpack()},
                {this.world.forward:unpack()},
                {this.world.up:unpack()},
                {vector:unpack()}
            )
        )
    end

    function this.localToWorld(vector)
        local rightX, rightY, rightZ = this.world.right:unpack()
        local forwardX, forwardY, forwardZ = this.world.forward:unpack()
        local upX, upY, upZ = this.world.up:unpack()
        local rfuX, rfuY, rfuZ = vector:unpack()
        local relX = rfuX * rightX + rfuY * forwardX + rfuZ * upX
        local relY = rfuX * rightY + rfuY * forwardY + rfuZ * upY
        local relZ = rfuX * rightZ + rfuY * forwardZ + rfuZ * upZ
        return vec3(relX, relY, relZ)
    end

    function this.apply()
        local deltaTime = math.max(system.getTime() - lastUpdate, 0.001) --If delta is below 0.001 then something went wrong in game engine.
        this.updateWorld()
        local tmp = this.thrust
        local atmp = this.angularThrust

        if this.direction.x ~= 0 then
            tmp = tmp + (((this.world.right * this.direction.x) * this.fMax) * this.throttle)
        end
        if this.direction.y ~= 0 then
            tmp = tmp + (((this.world.forward * this.direction.y) * this.fMax) * this.throttle)
        end
        if this.direction.z ~= 0 then
            local a = ((this.world.up * this.direction.z) * this.fMax)
            if not this.ignoreVerticalThrottle then a = a * this.throttle end
            tmp = tmp + a
        end

        -- Rotation
        if (this.rotation.x ~= 0 or this.rotation.z ~= 0) and this.targetVectorAutoUnlock then
            this.targetVector = nil
        end
        atmp = atmp + ((this.world.forward:cross(this.world.up) * this.rotation.x) * this.rotationSpeed)
        atmp = atmp + ((this.world.up:cross(this.world.right) * this.rotation.y) * this.rotationSpeed)
        atmp = atmp + ((this.world.forward:cross(this.world.right) * this.rotation.z) * this.rotationSpeed)

        if this.followGravity and this.rotation.x == 0 then
            atmp = atmp + (this.world.up:cross(-this.world.gravity:normalize()) * this.gravityFollowSpeed)
        end
        if this.altitudeHold ~= nil then
            local deltaAltitude = this.altitude - this.altitudeHold
            local upVelocity = this.world.velocity:project_on(this.world.gravity:normalize())
            if upVelocity.z < 0 then
                upVelocity = -upVelocity:len()
            else
                upVelocity = upVelocity:len()
            end
            deltaAltitude = deltaAltitude + upVelocity
            tmp = tmp + ((this.world.gravity:normalize() * deltaAltitude) * this.mass)
        end
        if this.inertialDampening then
            local brakingForce = this.mass * -this.localVelocity
            local apply = this.direction * this.localVelocity
            local tmpd = deltaTime
            if apply.x <= 0 then
                if (math.abs(this.localVelocity.x) < 1) then
                    tmpd = 0.125
                end
                tmp = tmp + (this.world.right * brakingForce.x) / tmpd
            end
            if apply.y <= 0 then
                if (math.abs(this.localVelocity.y) < 1) then
                    tmpd = 0.125
                end
                tmp = tmp + (this.world.forward * brakingForce.y) / tmpd
            end
            if apply.z <= 0 then
                if (math.abs(this.localVelocity.z) < 1) then
                    tmpd = 0.125
                end
                tmp = tmp + (this.world.up * brakingForce.z) / tmpd
            end
        end

        if this.brake then
            local velocityLen = this.world.velocity:len()
            tmp =
                -this.world.velocity * this.mass *
                math.max(this.brakingFactor * math.max(1, velocityLen * 0.5), utils.pow2(velocityLen))
        end
        if this.targetVector ~= nil then
            atmp = atmp + (this.world.forward:cross(this.targetVector()) * this.rotationSpeed)
        end
        -- must be applied last
        if this.counterGravity then
            tmp = tmp - (this.world.gravity * this.mass)
        end

        tmp = tmp / this.mass
        control.setEngineCommand(tostring(this.tags), {tmp:unpack()}, {atmp:unpack()})
        lastUpdate = system.getTime()
    end

    return this
end)(Slots.Core, unit)