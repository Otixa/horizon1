--[[
    Shadow Templar Keybind Controller
    Version 1.1
]]

function Keybind(key)
    local self = {}
    self.key = key
    local bindings = {}

    function self.add(f)
        if type(f) ~= "function" then error("[Keybind] Unable to add callback - not a function") end
        table.insert(bindings, f)
    end

    function self.remove(f)
        if type(f) ~= "function" then error("[Keybind] Unable to remove callback - not a function") end
        local reverse = {}
        for k,v in pairs(bindings) do reverse[v]=k end
        for k,v in pairs(bindings) do
            if reverse[v] then
                bindings[k]=nil
            end
        end
    end

    function self.call()
        for k,v in pairs(bindings) do v(self.key) end
    end

    return self
end

function KeybindController()
    local self = {}
    self.keyUp = {
        forward = Keybind(),
        backward = Keybind(),
        left = Keybind(),
        right = Keybind(),
        yawleft = Keybind(),
        yawright = Keybind(),
        up = Keybind(),
        down = Keybind(),
        gear = Keybind(),
        light = Keybind(),
        landing = Keybind(),
        brake = Keybind(),
        option1 = Keybind(),
        option2 = Keybind(),
        option3 = Keybind(),
        option4 = Keybind(),
        option5 = Keybind(),
        option6 = Keybind(),
        option7 = Keybind(),
        option8 = Keybind(),
        option9 = Keybind(),
        stopengines = Keybind(),
        speedup = Keybind(),
        speeddown = Keybind(),
        antigravity = Keybind(),
        booster = Keybind()
    }
    self.keyDown = {
        forward = Keybind(),
        backward = Keybind(),
        left = Keybind(),
        right = Keybind(),
        yawleft = Keybind(),
        yawright = Keybind(),
        up = Keybind(),
        down = Keybind(),
        gear = Keybind(),
        light = Keybind(),
        landing = Keybind(),
        brake = Keybind(),
        option1 = Keybind(),
        option2 = Keybind(),
        option3 = Keybind(),
        option4 = Keybind(),
        option5 = Keybind(),
        option6 = Keybind(),
        option7 = Keybind(),
        option8 = Keybind(),
        option9 = Keybind(),
        stopengines = Keybind(),
        speedup = Keybind(),
        speeddown = Keybind(),
        antigravity = Keybind(),
        booster = Keybind()
    }

    self.keyLoop = {
        forward = Keybind(),
        backward = Keybind(),
        left = Keybind(),
        right = Keybind(),
        yawleft = Keybind(),
        yawright = Keybind(),
        up = Keybind(),
        down = Keybind(),
        gear = Keybind(),
        light = Keybind(),
        landing = Keybind(),
        brake = Keybind(),
        option1 = Keybind(),
        option2 = Keybind(),
        option3 = Keybind(),
        option4 = Keybind(),
        option5 = Keybind(),
        option6 = Keybind(),
        option7 = Keybind(),
        option8 = Keybind(),
        option9 = Keybind(),
        stopengines = Keybind(),
        speedup = Keybind(),
        speeddown = Keybind(),
        antigravity = Keybind(),
        booster = Keybind()
    }

    function self.call(action, type)
        if type == "up" then
            if self.keyUp[action] then self.keyUp[action].call(action) end
        elseif type == "down" then
            if self.keyDown[action] then self.keyDown[action].call(action) end
        else
            if self.keyLoop[action] then self.keyDown[action].call(action) end
        end
    end

    function init()
        for k,v in pairs(self.keyUp) do
            v.key = k
        end
        for k,v in pairs(self.keyDown) do
            v.key = k
        end
    end
    init()
    return self
end

keybinds = KeybindController()