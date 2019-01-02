--[[
    Shadow Templar Engine Control
    Version: 1.15

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
    self.control = control
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
        atmosphericDensity = control.getAtmosphereDensity()
    }
    self.target = {
        prograde = function() return self.world.velocity:normalize() end,
        retrograde = function() return -self.world.velocity:normalize() end,
        progravity = function() return self.world.gravity:normalize() end,
        antigravity = function() return -self.world.gravity:normalize() end,
    }
    -- Construct id
    self.id = core.getConstructId()
    -- Active engine tags
    self.tags = TagManager("all,brake")
    -- Target vector to face if non-0. Can take in a vec3 or function which returns a vec3
    self.targetVector = nil
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
    -- Amount of angular thrust to apply, in world space
    self.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity in directions that are not being accelerated towards
    self.brake = false
	-- Whether or not the vessel should attempt to completely cancel out its current velocity
	self.handbrake = false
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
    -- Whether or not to ignore throttle for vertical thrust calculations
    self.ignoreVerticalThrottle = false

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
            atmosphericDensity = control.getAtmosphereDensity()
        }

        self.mass = self.core.getConstructMass()
        self.altitude = self.core.getAltitude()
		self.localVelocity = vec3(core.getVelocity())
        local fMax = self.core.getMaxKinematicsParameters()
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

    function self.throttleUp()
        self.throttle = clamp(self.throttle + 0.05, 0, 1)
    end

    function self.throttleDown()
        self.throttle = clamp(self.throttle - 0.05, 0, 1)
    end

    function self.worldToLocal(vector)
        return vec3(library.systemResolution3(
            { self.world.right:unpack() },
            { self.world.forward:unpack() },
            { self.world.up:unpack() },
            { vector:unpack() }
        ))
    end

    function self.localToWorld(vector)
        vector = { vector:unpack() }
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
        local deltaTime = math.max(system.getTime() - lastUpdate, 0.001) --If delta is below 0.001 then something went wrong in game engine.
        self.updateWorld()
        local tmp = self.thrust
        local atmp = self.angularThrust
		local brakingForce = vec3(
			-self.localVelocity.x * self.mass * math.max(math.abs(self.localVelocity.x),1),
			-self.localVelocity.y * self.mass * math.max(math.abs(self.localVelocity.y),1),
			-self.localVelocity.z * self.mass * math.max(math.abs(self.localVelocity.z),1)
		)

        if self.direction.x ~= 0 then
            tmp = tmp + (((self.world.right * self.direction.x) * self.fMax) * self.throttle)
        end
        if self.direction.y ~= 0 then
            local a = ((self.world.forward * self.direction.y) * self.fMax)
            if not self.ignoreVerticalThrottle then a = a * self.throttle end
            tmp = tmp + a
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
        if self.counterGravity then
            tmp = tmp - self.world.gravity * self.mass
        end
        if self.followGravity and self.rotation.x == 0 then
            atmp = atmp + (self.world.up:cross(-self.world.gravity:normalize()) * self.gravityFollowSpeed)
        end
        if self.altitudeHold ~= 0 then
            local deltaAltitude = self.altitude - self.altitudeHold
            tmp = tmp + ((self.world.gravity:normalize() * deltaAltitude * -1) * self.mass * deltaTime)
        end
		if self.brake then
			if (self.direction.x >= 0 and self.localVelocity.x <= 0) or (self.direction.x <= 0 and self.localVelocity.x >= 0) then
				tmp = tmp + self.mass * (self.world.right 	* brakingForce.x ) * deltaTime
			end
			if (self.direction.y >= 0 and self.localVelocity.y <= 0) or (self.direction.y <= 0 and self.localVelocity.y >= 0) then
				tmp = tmp + self.mass * (self.world.forward * brakingForce.y ) * deltaTime
			end
			if (self.direction.z >= 0 and self.localVelocity.z <= 0) or (self.direction.z <= 0 and self.localVelocity.z >= 0) then
				tmp = tmp + self.mass * (self.world.up 		* brakingForce.z ) * deltaTime
			end
		end
        if self.handbrake then
            tmp = 		self.mass * (self.world.right 	* brakingForce.x ) * deltaTime
			tmp = tmp + self.mass * (self.world.forward * brakingForce.y ) * deltaTime
			tmp = tmp + self.mass * (self.world.up 		* brakingForce.z ) * deltaTime
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
		
		tmp = tmp / self.mass
        self.control.setEngineCommand(tostring(self.tags), {tmp:unpack()}, {atmp:unpack()})
        lastUpdate = system.getTime()
    end

    return self
end

ship = STEC(core, unit)