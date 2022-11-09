--@class Kinematics
function Kinematics()
    local Kinematic = {} -- just a namespace

local ITERATIONS = 100 -- iterations over engine "warm-up" period

--
-- computeAccelerationTime - solve vf = vi + a*t for t
-- initial      [in]: initial (positive) speed in meters per second.
-- acceleration [in]: constant acceleration until 'finalSpeed' is reached.
-- final        [in]: the speed at the end of the time interval.
-- return: the time in seconds to reach the "final" velocity
--
function Kinematic.computeAccelerationTime(initial, acceleration, final)
    -- ans: t = (vf - vi)/a
    return (final - initial)/acceleration
end

--
-- computeDistanceAndTime - Return distance & time needed to reach final speed.
-- initial[in]:     Initial speed in meters per second.
-- final[in]:       Final speed in meters per second.
-- mass[in]:        Mass of the construct in Kg.
-- thrust[in]:      Engine's maximum thrust in Newtons.
-- t50[in]:         (default: 0) Time interval to reach 50% thrust in seconds.
-- brakeThrust[in]: (default: 0) Constant thrust term when braking.
-- return: Distance (in meters), time (in seconds) required for change.
--
function Kinematic.computeDistanceAndTime(initial,
                                          final,
                                          mass,
                                          thrust,
                                          t50,
                                          brakeThrust)
    -- This function assumes that the applied thrust is colinear with the
    -- velocity. Furthermore, it does not take into account the influence
    -- of gravity, not just in terms of its impact on velocity, but also
    -- its impact on the orientation of thrust relative to velocity.
    -- These factors will introduce (usually) small errors which grow as
    -- the length of the trip increases.
    t50            = t50 or 0
    brakeThrust    = brakeThrust or 0 -- usually zero when accelerating

    local speedUp  = initial < final
    local a0       = thrust / (speedUp and mass or -mass)
    local b0       = -brakeThrust/mass
    local totA     = a0+b0

    if initial == final then
        return 0, 0   -- trivial
    elseif speedUp and totA <= 0 or not speedUp and totA >= 0 then
        return -1, -1 -- no solution
    end

    local distanceToMax, timeToMax = 0, 0

    -- If, the T50 time is set, then assume engine is at zero thrust and will
    -- reach full thrust in 2*T50 seconds. Thrust curve is given by:
    -- Thrust: F(z)=(m*a0*(1+sin(z))+2*m*b0)/2 where z=pi*(t/t50 - 1)/2
    -- Acceleration is given by F(z)/m
    -- or v(z)' = (a0*(1+sin(z))+2*b0)/2

    if a0 ~= 0 and t50 > 0 then
        -- Closed form solution for velocity exists (t <= 2*t50):
        -- v(t) = a0*(t/2 - t50*sin(pi*(t/2)/t50)/pi)+b0*t)+c
        -- @ t=0, v(0) = vi => c=vi

        local c1  = math.pi/t50/2

        local v = function(t)
            return a0*(t/2 - t50*math.sin(c1*t)/math.pi) + b0*t + initial
        end

        local speedchk = speedUp and function(s) return s >= final end or
                                     function(s) return s <= final end
        timeToMax  = 2*t50

        if speedchk(v(timeToMax)) then
            local lasttime = 0

            while math.abs(timeToMax - lasttime) > 0.25 do
                local t = (timeToMax + lasttime)/2
                if speedchk(v(t)) then
                    timeToMax = t 
                else
                    lasttime = t
                end
            end
        end

        -- Closed form solution for distance exists (t <= 2*t50):
        local K       = 2*a0*t50^2/math.pi^2
        distanceToMax = K*(math.cos(c1*timeToMax) - 1) +
                        (a0+2*b0)*timeToMax^2/4 + initial*timeToMax

        if timeToMax < 2*t50 then
            return distanceToMax, timeToMax
        end
        initial = v(timeToMax)
    end
    -- At full thrust, motion follows Newton's formula:
    local a = a0+b0
    local t = Kinematic.computeAccelerationTime(initial, a, final)
    local d = initial*t + a*t*t/2
    return distanceToMax+d, timeToMax+t
end

--
-- computeTravelTime - solve d=vi*t+a*t**2/2 for t
-- initialSpeed [in]: initial (positive) speed in meters per second
-- acceleration [in]: constant acceleration until 'distance' is traversed
-- distance [in]: the distance traveled in meters
-- return: the time in seconds spent in traversing the distance
--
function Kinematic.computeTravelTime(initial, acceleration, distance)
    -- quadratic equation: t=(sqrt(2ad+v^2)-v)/a
    if distance == 0 then return 0 end

    if acceleration ~= 0 then
        return (math.sqrt(2*acceleration*distance+initial^2) - initial)/
                    acceleration
    end
    assert(initial > 0, 'Acceleration and initial speed are both zero.')
    return distance/initial
end

return Kinematic


end