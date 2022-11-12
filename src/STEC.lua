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
local atlas = require('atlas')
planetaryReference = PlanetRef()
galaxyReference = planetaryReference(atlas)
helios = galaxyReference[0]

kinematics = Kinematics()
local json = require("dkjson")
local jdecode = json.decode
local atlas = require('atlas')
local find = string.find
function getJsonNum (json, key, init)
  local pattern = [["]] .. key .. [["%s*:%s*(-?[0-9.e-]+)]]
  local startIndex, endIndex, valueStr = find(json, pattern, init)
  return tonumber(valueStr), startIndex, endIndex
end

function round(val, decimal)
  if (decimal) then
    return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
  else
    return math.floor(val + 0.5)
  end
end

--function getBrakingInfo()
--    local curVelMs = vec3(construct.getWorldVelocity()):len()
--    local cMass = construct.getMass()
--    local brakingForce = getJsonNum(unit.getWidgetData(), "maxBrake")
--    local brakeInfo = {}
--    if brakingForce == 0 then
--        brakeInfo.time = "BF: 0"
--        brakeInfo.dist = 1
--        return brakeInfo
--    end
--
--    local brakeForce = math.floor(brakingForce)
--    local rA = brakeForce / cMass
--    local c = 30000000 / 3600
--    local c2 = c * c
--    local cA = c * math.asin(curVelMs / c)
--    local cC = c2 * math.cos(cA / c) / rA
--    
--    local t = (c - cA) / rA
--    local d = cC - c2 * math.cos((rA * t + cA) / c) / rA
--      
--    local min = math.floor(t / 60)
--    t = t - (60 * min)
--    local sec = round(t, 0)
--        
--    local tms = string.format("%02dm:%02ds", min, sec)
--     
--    local km = round(d / 1000, 2)
--    
--    brakeInfo.time = tms
--    brakeInfo.dist = km
--    
--    return brakeInfo
--end

function STEC(core, control, Cd)
    local self = {}
    self.core = core
    self.construct = construct
    self.constructMaxSpeed = construct.getMaxSpeed() * 3.6
    self.control = control
    self.nearestPlanet = helios:closestBody(construct.getWorldPosition())
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
        nearPlanet = unit.getClosestPlanetInfluence() > 0,
        atlasAltitude = self.nearestPlanet:getAltitude(construct.getWorldPosition()),
        --nearestPlanetGravity = vec3(self.nearestPlanet.getGravity(construct.getWorldPosition()))

    }
    self.target = {
        prograde = function() return self.world.velocity:normalize() end,
        retrograde = function() return -self.world.velocity:normalize() end,
        radial = function() return self.nearestPlanet:getGravity(construct.getWorldPosition()):normalize() end,
        antiradial = function() return -self.nearestPlanet:getGravity(construct.getWorldPosition()):normalize() end,
        normal = function() return self.world.velocity:cross(self.world.right):normalize() end,
        antinormal = function() return self.world.velocity:cross(self.world.left):normalize() end,
    }
    self.planets = {
        sancuary = function() return helios[26]:getGravity(construct.getWorldPosition()):normalize() end,
        madis = function() return helios[1]:getGravity(construct.getWorldPosition()):normalize() end,
        thades = function() return helios[3]:getGravity(construct.getWorldPosition()):normalize() end,
        alioth = function() return helios[2]:getGravity(construct.getWorldPosition()):normalize() end,
        feli = function() return helios[5]:getGravity(construct.getWorldPosition()):normalize() end,
        ion = function() return helios[120]:getGravity(construct.getWorldPosition()):normalize() end,
        jago = function() return helios[9]:getGravity(construct.getWorldPosition()):normalize() end,
        lacobus = function() return helios[100]:getGravity(construct.getWorldPosition()):normalize() end,
        sicari = function() return helios[6]:getGravity(construct.getWorldPosition()):normalize() end,
        sinnen = function() return helios[7]:getGravity(construct.getWorldPosition()):normalize() end,
        symeon = function() return helios[110]:getGravity(construct.getWorldPosition()):normalize() end,
        talemai = function() return helios[4]:getGravity(construct.getWorldPosition()):normalize() end,
        teoma = function() return helios[8]:getGravity(construct.getWorldPosition()):normalize() end,
    }
    -- Construct id
    self.id = construct.getId()
    -- Control Mode - Travel (0) or Cruise (1)
    self.controlMode = unit.getControlMode()
    -- Alternate Control Mode for remote control
    self.alternateCM = false
    -- Placeholder for throttle value when switching control modes
    self.tempThrottle = 0
    -- Placeholder for cruise value when switching control modes
    self.tempCruise = 0  
    -- Active engine tags
    self.tags = TagManager("all")
    -- Target vector to face if non-0. Can take in a vec3 or function which returns a vec3
    self.targetVector = nil
    -- Whether the target vector should unlock automatically if the ship is rotated by the pilot
    self.targetVectorAutoUnlock = true
    -- Roid AP
    self.targetGoTo = nil
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
    -- Starting speed for auto-scaling rotation
    self.rotationSpeedMin = 0.01
    -- Maximum speed for auto-scaling rotation
    self.rotationSpeedMax = 5
    -- Step for increasing the rotation speed
    self.rotationStep = 0.03
    -- Breaking speed multiplier
    self.brakingFactor = 10
    -- Amount of angular thrust to apply, in world space
    self.angularThrust = vec3(0, 0, 0)
    -- Whether or not the vessel should attempt to cancel out its current velocity in directions that are not being accelerated towards
    self.inertialDampening = false
    self.IDIntensity = 5
    -- Whether or not the vessel should attempt to completely cancel out its current velocity
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
    --self.fMax = 0
    self.pocket = pocket
    -- Altitude which the vessel should attempt to hold
    self.altitudeHold = 0
    -- Speed which the vessel should attempt to maintain
    self.cruiseSpeed = 0
    -- Whether or not to ignore throttle for vertical thrust calculations
    self.ignoreVerticalThrottle = false
    -- Whether or not to ignore throttle for horizontal thrust calculations
    self.ignoreHorizontalThrottle = true
    -- Local velocity
    self.localVelocity = vec3(construct.getVelocity())
    -- Roll Degrees
    self.rollDegrees = self.world.vertical:angle_between(self.world.left) / math.pi * 180 - 90
    if self.world.vertical:dot(self.world.up) > 0 then self.rollDegrees = 180 - self.rollDegrees end
    -- Pitch
    self.pitchRatio = self.world.vertical:angle_between(self.world.forward) / math.pi - 0.5
    self.vtolPriority = true
    self.disableVtol = false
    self.disabledTags = ""
    local lastUpdate = system.getArkTime()
    self.thrustVec = vec3(0,0,0)
    self.trajectoryDiff = 0
    self.ETA = 0
    self.simulationPos = vec3(0,0,0)
    
    self.priorityTags1 = "airfoil,torque,ground"
    self.priorityTags2 = "atmospheric_engine,space_engine"
    self.priorityTags3 = "brake,vertical"
    self.brakeDistance = 0
    self.accelTime = 0
    self.targetDist = 0
    self.inertialMass = 0
    self.maxBrake = jdecode(unit.getWidgetData()).maxBrake
    self.debug = vec3(0,0,0)
    self.deviationAngle = 0
    self.stopping = false

    function getAngle(a,b,c)
        if a + c < b then b = a end
        return math.deg(math.acos((a^2+b^2-c^2)/(2*(a*b))))
    end
    function getGapFromAngle(a,b,angle)
        return math.sqrt((a^2 + b^2) - (2*(b*a)*math.cos(angle)))
    end
    function errHandler(x)
        system.print("Error: " .. x)
        return "ERROR"
    end
    function simulateAhead(simLength, timeStep)
        local sv = self.world.velocity:clone()
        local sp = self.world.position:clone()
        local sa = self.world.acceleration:clone()
    
        local cutoff = simLength / timeStep

        for step = 0,cutoff do
            --system.print("Start simulate")
            local stepResult = simulate(timeStep, sp, sv, sa)
            sv = stepResult.velocity
            sp = stepResult.position
            --system.print(tostring(vec3(sp)))
            if stepResult.collision ~= nil then
                stepResult.time = step * timeStep
                --stepResult.time = step / timeStep
                return stepResult
            end
        end
        return {
            ["position"] = sp,
            ["velocity"] = sv,
            ["collision"] = nil
        }
    end

    function simulate(stepSize, sPos, sVel, sAcc)
        local G = 6.6740831 * 10^-11
        local closest = nil
        local vFinal = 0
        local velocity = sVel
        local collided = nil
        local position = sPos
        for i = 1, #atlas[0] do
            local body = atlas[0][i]
            local bPos = vec3(body.center[1], body.center[2], body.center[3])
            local dir = (sPos - bPos):normalize()
            local dist = (sPos - bPos):len()
            
            if dist < body.radius or collided ~= nil then
                if collided == nil then
                    collided = body
                    closest = body
                end
                return {
                    ["position"] = position,
                    ["velocity"] = vec3(0,0,0),
                    ["collision"] = collided
                }
            end
    
            local Fg = G * (ship.mass * body.GM) / dist^2
            local dirMul = dir * ((Fg / ship.mass) * -stepSize)
            velocity = velocity + dirMul
            if closest == nil or ((dist - body.radius) / Fg < ((sPos - vec3(closest.center[1], closest.center[2], closest.center[3])):len() - closest.radius) / Fg) then
                closest = body
            end
            
            if velocity:len() > vFinal then
                vFinal = velocity:len()
            end
    
        end
    
        if collided == nil and stepSize > 0 then
            if closest ~= nil then
    
            end
    
             velocity = velocity + (sAcc * stepSize)
             if velocity:len() > 8333.333333 then
                velocity = velocity:normalize() * 8333.333333
             end
             position = position + (velocity * stepSize)
        end
        return {
            ["position"] = position,
            ["velocity"] = velocity,
            ["collision"] = collided
        }
    end

    function sMovingAverage(period)
        local t = {}
        function _sum(a, ...)
            if a then return a+_sum(...) else return 0 end
        end
        function _average(n)
            if #t == period then table.remove(t, 1) end
            t[#t + 1] = n
            return _sum(table.unpack(t)) / #t
        end
        return _average
    end

    local sMovingAverage5 = sMovingAverage(5)
    local sMovingAverage10 = sMovingAverage(10)
    local sMovingAverage15 = sMovingAverage(15)
    local sMovingAverage25 = sMovingAverage(25)

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
            nearPlanet = unit.getClosestPlanetInfluence() > 0,
            atlasAltitude = self.nearestPlanet:getAltitude(construct.getWorldPosition()),
            --nearestPlanetGravity = vec3(self.nearestPlanet.getGravity(construct.getWorldPosition()))
            
    
        }
        self.nearestPlanet = helios:closestBody(construct.getWorldPosition())
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
        self.altitude = self.nearestPlanet:getAltitude(construct.getWorldPosition())
        self.localVelocity = vec3(construct.getVelocity())

        if self.vtolPriority then
            self.priorityTags1 = "brake,airfoil,torque,vertical,lateral,longitudinal"
            self.priorityTags2 = "atmospheric_engine,space_engine"
            self.priorityTags3 = ""
        else
            self.priorityTags1 = "brake,airfoil,torque,lateral,longitudinal"
            self.priorityTags2 = "atmospheric_engine,space_engine"
            self.priorityTags3 = "vertical"
        end


        local tkForward = construct.getMaxThrustAlongAxis("all", {vec3(0, 1, 0):unpack()})
        local tkUp = construct.getMaxThrustAlongAxis("all", {vec3(0, 0, 1):unpack()})
        local tkRight = construct.getMaxThrustAlongAxis("all", {vec3(1, 0, 0):unpack()})
        
        local tkOffset = 0
        if self.world.atmosphericDensity < 0.1 then
            tkOffset = 2
        end
        
        local virtualGravityEngine =
            vec3(
            library.systemResolution3(
                {self.world.right:unpack()},
                {self.world.forward:unpack()},
                {self.world.up:unpack()},
               {(self.world.gravity * self.mass):unpack()}
            )
        )

        self.MaxKinematics = {
            Forward = math.abs(tkForward[1 + tkOffset] + virtualGravityEngine.y),
            Backward = math.abs(tkForward[2 + tkOffset] - virtualGravityEngine.y),
            Up = math.abs(tkUp[1 + tkOffset] + virtualGravityEngine.z),
            Down = math.abs(tkUp[2 + tkOffset] - virtualGravityEngine.z),
            Right = math.abs(tkRight[1 + tkOffset] + virtualGravityEngine.x),
            Left = math.abs(tkRight[2 + tkOffset] - virtualGravityEngine.x)
        }
        self.maxBrake = jdecode(unit.getWidgetData()).maxBrake
        local c = 50000000 / 3600
        local v = self.world.velocity:len()
        local y = 1/math.sqrt(1-((v*v)/(c*c)))
        self.inertialMass = utils.clamp(self.mass * y, self.mass, self.mass * 1.5)

        

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

    function math.sign(v)
        return (v >= 0 and 1) or -1
    end
    function math.round(v, bracket)
        bracket = bracket or 1
        return math.floor(v/bracket + math.sign(v) * 0.5) * bracket
    end

    function self.throttleUp()
        self.throttle = clamp(self.throttle + 0.05, 0, 1)
    end

    function self.throttleDown()
        self.throttle = clamp(self.throttle - 0.05, 0, 1)
    end

    function self.scaleRotation()
        if self.rotationSpeed <= self.rotationSpeedMax then self.rotationSpeed = self.rotationSpeed + self.rotationStep end
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

    function self.localToRelative(pos, up, right, forward)
        -- this is horrible, can optimize?
        local rightX, rightY, rightZ = right:unpack()
        local forwardX, forwardY, forwardZ = forward:unpack()
        local upX, upY, upZ = up:unpack()
        local rfuX, rfuY, rfuZ = pos:unpack()
        local relX = rfuX * rightX + rfuY * forwardX + rfuZ * upX
        local relY = rfuX * rightY + rfuY * forwardY + rfuZ * upY
        local relZ = rfuX * rightZ + rfuY * forwardZ + rfuZ * upZ
        return vec3(relX, relY, relZ)
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


    function moveWaypointZ(vector, altitude)
        return (vector - (self.nearestPlanet:getGravity(vector)):normalize() * (altitude))
    end
    function moveWaypointY(altitude, distance)
        local z = moveWaypointZ(self.world.position, altitude - self.altitude)
        return z - (self.world.right:cross(self.nearestPlanet:getGravity(self.world.position)):normalize()) * -distance
    end

    function moveWaypoint(origin, intersect, distance)
        return origin + ((origin - intersect):normalize() * distance)
    end

    function self.getTrajectory(distance)
        distance = distance or 1
        local v = self.world.position + (self.world.velocity + self.world.gravity):normalize()
        --local v = self.simulationPos
        return self.world.position - ((self.world.position - v):normalize() * distance)
    end

    

    function self.apply()
        local deltaTime = math.max(system.getArkTime() - lastUpdate, 0.001) --If delta is below 0.001 then something went wrong in game engine.
        self.updateWorld()
        local tmp = self.thrust
        local atmp = self.angularThrust
        --Thrust
        --Lateral
        local gravityCorrection = false
        local fMax = construct.getMaxThrustAlongAxis("all", {vec3(0,1,0):unpack()})
        local vMaxUp = construct.getMaxThrustAlongAxis("all", {vec3(0,0,1):unpack()})
        local vMaxDown = construct.getMaxThrustAlongAxis("all", {vec3(0,0,-1):unpack()})
        local hMax = construct.getMaxThrustAlongAxis("all", {vec3(1,0,0):unpack()})

        if self.direction.x > 0 then
            tmp = tmp  + (self.world.right * self.MaxKinematics.Right) * self.throttle
        end
        if self.direction.x < 0 then
            tmp = tmp  - (self.world.right * self.MaxKinematics.Right) * self.throttle
        end
        --Forward
        if self.direction.y > 0 then
            tmp = tmp  + (self.world.forward * self.MaxKinematics.Forward) * self.throttle
        end
        if self.direction.y < 0 then
            tmp = tmp  - (self.world.forward * self.MaxKinematics.Forward) * self.throttle
        end
        --Vertical
        if self.direction.z > 0 then
            tmp = tmp + self.world.up * self.MaxKinematics.Up
            if not self.ignoreVerticalThrottle then tmp = tmp * self.throttle end
        end
        if self.direction.z < 0 then
            tmp = tmp + -self.world.up * self.MaxKinematics.Down
            if not self.ignoreVerticalThrottle then tmp = tmp * self.throttle end
        end
        --Rotation
        if self.rotation.x ~= 0 then
            self.scaleRotation()
            atmp = atmp + ((self.world.forward:cross(self.world.up) * self.rotation.x) * self.rotationSpeed)
            if self.targetVectorAutoUnlock then
                self.targetVector = nil
                self.followGravity = false
                self.altitudeHold = 0
            end
        end
        if self.rotation.y ~= 0 then
            self.scaleRotation()
            atmp = atmp + ((self.world.up:cross(self.world.right) * self.rotation.y) * self.rotationSpeed)
        end
        if self.rotation.z ~= 0 then
            self.scaleRotation()
            atmp = atmp + ((self.world.forward:cross(self.world.right) * self.rotation.z) * self.rotationSpeed)
            --if self.targetVectorAutoUnlock then
            --    self.targetVector = nil
            --    self.altitudeHold = 0
            --end
        end
        if self.followGravity and self.rotation.x == 0 then
            
            --system.print(tostring(self.direction))
              --local current = self.localVelocity:len() * self.mass
              --local scale = nil
              --if ship.localVelocity:len() > 10 then
              --    scale = self.gravityFollowSpeed * math.min(math.max(current / self.fMax, 0.1), 1) * 10
              --else
              --    scale = self.gravityFollowSpeed
              --end
              --local gFollow = (self.world.up:cross(-self.nearestPlanet:getGravity(construct.getWorldPosition())))
              local gFollow = (self.world.up:cross(-self.world.gravity))
              --local gFollow = (self.world.up:cross(-self.nearestPlanet:getGravity(construct.getWorldPosition())))
              local scale = 1
              if self.pocket then
                  if self.direction.x < 0  then
                      scale = 0.25
                      --gFollow = gFollow + ship.world.right:cross(-self.nearestPlanet:getGravity(construct.getWorldPosition()) * 0.25)
                      gFollow = gFollow + ship.world.right:cross(-self.world.gravity * 0.25)
                  elseif self.direction.x > 0  then
                      scale = 0.25
                      --gFollow = gFollow - ship.world.right:cross(-self.nearestPlanet:getGravity(construct.getWorldPosition()) * 0.25)
                      gFollow = gFollow - ship.world.right:cross(-self.world.gravity * 0.25)
                  elseif self.direction.y < 0  then
                      --gFollow = gFollow + ship.world.forward:cross(-self.nearestPlanet:getGravity(construct.getWorldPosition()) * 0.25)
                      gFollow = gFollow + ship.world.forward:cross(-self.world.gravity * 0.25)
                  end
              end
              gFollow = gFollow * scale
              atmp = atmp + gFollow
          end
  

		if self.altitudeHold ~= 0 then
            --local deltaAltitude =  self.altitudeHold - self.altitude
            local waypoint = moveWaypointY(self.altitudeHold, (self.world.velocity:len() * 3) + 50)
            self.targetVector = (waypoint - self.world.position ):normalize()
            atmp = atmp - (self.world.right:cross(self.world.forward:cross(self.world.gravity:normalize())) * self.rotationSpeed * 9) - ((self.AngularVelocity * 3) - (self.AngularAirFriction * 3))
            --tmp = tmp - ((self.nearestPlanet:getGravity(construct.getWorldPosition()) * self.mass) * deltaAltitude)
        end
        if self.targetVector == nil then self.gotoLock = nil end
        if self.gotoLock ~= nil then
            local targetRadius = ap_stop_distance
            if not self.inertialDampening then self.inertialDampening = true end
            self.direction.y = 0
            self.vtolPriority = true
            local speed = self.constructMaxSpeed
            
            local dest = (self.world.position - self.gotoLock):normalize()
            
            self.targetDist = (self.world.position - self.gotoLock):len() - targetRadius
            --local v = self.getTrajectory(self.targetDist)
            local v = self.simulationPos
            --local v = self.world.position - ((self.world.position - self.world.velocity):normalize() * self.targetDist)
            self.trajectoryDiff = sMovingAverage25((v - self.gotoLock):len())
            
            local force = tmp:dot(self.world.position - self.gotoLock)

            self.brakeDistance, self.accelTime = kinematics.computeDistanceAndTime((self.world.velocity + self.world.gravity):len(), 0, self.inertialMass, force, 0, self.maxBrake)
            
            if self.brakeDistance >= (self.targetDist - targetRadius) or self.targetDist <= targetRadius then
                speed = self.targetDist - self.brakeDistance
                self.stopping = true
            end
            if self.trajectoryDiff > 10 and self.world.velocity:len() > 250 / 3.6 and not self.stopping then
            --    self.inertialDampening = false
  --
--
            --    local a = self.targetDist
            --    local b = (self.world.position - v):len()
            --    local c = (self.gotoLock - v):len()
--
--
            --    self.deviationAngle = utils.clamp(math.deg(self.world.forward:angle_between(v)),0,45)
--
            --    local tri = getGapFromAngle(a,b,0)
            --    if utils.round(self.deviationAngle) ~= 0 and a > c and b > c then
            --        --system.print("adjust...")
            --        tri = getGapFromAngle(a,b,self.deviationAngle)
            --    end
            --        
--
            --    --local aa = moveWaypoint(self.world.position, v, self.targetDist)
            --    --local ab = moveWaypoint(self.gotoLock, aa, -c)
--
            --    --self.debug = ab
            --    self.debug = moveWaypoint(self.gotoLock,v,tri)
            --    dest = (self.world.position - self.debug):normalize()
            --    self.targetVector = -(self.world.position - self.debug):normalize()
            --else
            --    dest = (self.world.position - self.gotoLock):normalize()
            --    self.targetVector = -dest
            end
            dest = (self.world.position - self.gotoLock):normalize()
            self.targetVector = -dest
            if self.targetDist < 1 then
                speed = 0
                self.gotoLock = nil
                self.targetVector = nil
                self.stopping = false
            end
            --self.ETA = math.sqrt((2*self.targetDist + targetRadius)/sMovingAverage15(self.world.acceleration:len()))
            self.ETA = (self.targetDist / self.world.velocity:len()) + self.accelTime
            tmp = tmp - dest * self.mass * utils.clamp(self.targetDist * 3.6,0.3,((math.abs(speed)/3.6) * self.IDIntensity))
        end
        
        if self.alternateCM then
          local speed = (self.cruiseSpeed / 3.6)
          local dot = self.world.forward:dot(self.airFriction)
          local modifiedVelocity = (speed - dot)
          local desired = self.world.forward * modifiedVelocity
          local delta = (desired - self.world.velocity  - self.world.acceleration)
          --system.print(tostring(vec3(self.world.acceleration)))
          tmp = tmp + (delta * self.mass)
        end
        if self.inertialDampening then
            local currentShipMomentum = self.localVelocity
            local delta = vec3(0,0,0)
            local moveDirection = self.direction or vec3(0,0,0)

            if moveDirection.x == 0 then delta.x = currentShipMomentum.x end
            if moveDirection.y == 0 then delta.y = currentShipMomentum.y end
            if moveDirection.z == 0 then delta.z = currentShipMomentum.z end

            delta = self.localToRelative(delta, self.world.up, self.world.right, self.world.forward)
            tmp = tmp - (delta * (self.mass * self.IDIntensity))

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

            local damp = self.mass * 0.000001 * 2 + 4
            atmp = atmp + (self.world.forward:cross(vec) * self.rotationSpeedMax) - ((self.AngularVelocity * damp) - (self.AngularAirFriction * damp))
        end

        -- must be applied last
        if self.counterGravity then
            if self.direction.z >= 0 then
                tmp = tmp - self.nearestPlanet:getGravity(construct.getWorldPosition()) * self.mass
            end
        end

        atmp = atmp - ((self.AngularVelocity * 2) - (self.AngularAirFriction * 2))
        tmp = tmp / self.mass

        if self.controlMode ~= unit.getControlMode() then
            self.controlMode = unit.getControlMode()
            if unit.getControlMode() == 0 then
                self.tempCruise = self.cruiseSpeed
                self.cruiseSpeed = 0
                self.throttle = self.tempThrottle
                self.alternateCM = false
            end
            if unit.getControlMode() == 1 then
                self.tempThrottle = self.throttle
                self.throttle = 0
                --system.print("Velocity = "..tostring(math.round(self.world.velocity:len(), 100)))
                self.cruiseSpeed = math.round(self.world.velocity:len() * 3.6, 100)
                self.alternateCM = true
            end
        end
        
        if self.disableVtol then
            self.disabledTags = "vtol"
        else
            self.disabledTags = ""
        end
        
        self.control.setEngineCommand("atmospheric_engine,space_engine,airfoil,brake,torque,ground",
                                        {tmp:unpack()}, {atmp:unpack()}, false, false,
                                        self.priorityTags1,
                                        self.priorityTags2,
                                        self.priorityTags3)
        self.control.setEngineCommand(self.disabledTags)
        self.thrustVec = self.worldToLocal(tmp)
        atmp = vec3(0, 0, 0)
        tmp = vec3(0, 0, 0)
        lastUpdate = system.getArkTime()
    end

    return self
end

ship = STEC(core, unit)