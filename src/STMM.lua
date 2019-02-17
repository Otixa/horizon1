--[[
    Shadow Templar Mouse Movement
    Version 1.3

    Requires: STEC
    Note: Always apply() before STEC.apply() !
]]
mouse = (function (stec, system)
    local this = {}
    this.InvertX = false
    this.InvertY = false
    this.Enabled = true
    this.EnableX = true
    this.EnableY = true
    this.Sensitivity = 0.005
    this.Threshold = 0.15
    this.DeltaClamp = 3000
    this.RecenterSpeed = 20
    this.DeltaPos = vec3(0, 0, 0)

    local isLocked = false

    function this.lock()
        isLocked = true
        system.lockView(1)
    end

    function this.unlock()
        isLocked = false
        system.lockView(0)
    end

    function this.isLocked()
        return isLocked
    end

    function this.toggleLock()
        if this.isLocked() then
            this.unlock()
        else
            this.lock()
        end
    end

    function this.apply()
        if not this.Enabled then return end
        this.DeltaPos =
            (this.DeltaPos - (this.DeltaPos / this.RecenterSpeed)) -
            vec3(system.getMouseDeltaX() * this.Sensitivity, system.getMouseDeltaY() * this.Sensitivity, 0)
        this.DeltaPos =
            vec3(
            utils.clamp(this.DeltaPos.x, -this.DeltaClamp, this.DeltaClamp),
            utils.clamp(this.DeltaPos.y, -this.DeltaClamp, this.DeltaClamp),
            0)
        if this.EnableX then stec.rotation.z = 0 end
        if this.EnableY then stec.rotation.x = 0 end
        if utils.threshold(this.DeltaPos.x, this.Threshold) and this.EnableX then
            if this.InvertX then
                stec.rotation.z = this.DeltaPos.x
            else
                stec.rotation.z = -this.DeltaPos.x
            end
        end
        if utils.threshold(this.DeltaPos.y, this.Threshold) and this.EnableY then
            if this.InvertY then
                stec.rotation.x = -this.DeltaPos.y
            else
                stec.rotation.x = this.DeltaPos.y
            end
        end
    end
    this.lock()
    return this
end)(ship, system)
