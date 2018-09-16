--[[
    Shadow Templar Mouse Movement
    Version 1.2

    Requires: STEC
    Note: Always apply() before STEC.apply() !
]]

function STMM(stec, system)
    local self = {}
    self.enabled = true
    self.enableX = true
    self.enableY = true
    self.sensitivity = 0.005
    self.threshold = 0.2
    self.deltaClamp = 3000
    self.recenterSpeed = 20
    self.deltaPos = vec3(0, 0, 0)
    self.system = system

    local isLocked = false
    
    function self.lock()
        isLocked = true
        system.lockView(1)
    end

    function self.unlock()
        isLocked = false
        system.lockView(0)
    end

    function self.isLocked()
        return isLocked
    end

    function self.toggleLock()
        if self.isLocked() then self.unlock()
        else self.lock() end
    end

    function self.getPosition()
        return vec3(self.system.getMousePosX(), self.system.getMousePosY(), 0)
    end

    function pow(n, e)
        local sum = n
        for i = 1, e-1 do
            sum = sum * n
        end
        return sum
    end

    function clamp(n, min, max)
        return math.min(max, math.max(n, min))
    end

    function withinThreshold(n ,threshold)
        return (n > threshold and n > 0) or (n < -threshold and n < 0)
    end

    function self.apply()
        if not self.enabled then return end
        self.deltaPos = ( self.deltaPos - ( self.deltaPos / self.recenterSpeed )) - vec3(self.system.getMouseDeltaX() * self.sensitivity, self.system.getMouseDeltaY() * self.sensitivity, 0)
        self.deltaPos = vec3(clamp(self.deltaPos.x, -self.deltaClamp, self.deltaClamp), clamp(self.deltaPos.y, -self.deltaClamp, self.deltaClamp), 0)
        if withinThreshold(self.deltaPos.x, self.threshold) then
             if self.enableX then stec.rotation.z = -self.deltaPos.x end
        else
            if self.enableX then stec.rotation.z = 0 end
        end
        if withinThreshold(self.deltaPos.y, self.threshold) then
            if self.enableY then stec.rotation.x = self.deltaPos.y end
        else
            if self.enableY then stec.rotation.x = 0 end
        end
    end
    self.lock()
    return self
end

mouse = STMM(engines, self.system)