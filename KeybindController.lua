--[[
    Shadow Templar Keybind Controller
    Version 1.2
]]

function Keybind(key)
    local self = {}
    self.Key = key
    local bindings = {}

    function self.Add(f, keybindName)
        if type(f) ~= "function" then error("[Keybind] Unable to add callback - not a function") end
        table.insert(bindings, {Function = f, Name = keybindName})
    end

    function self.Remove(f)
        if type(f) ~= "function" then error("[Keybind] Unable to remove callback - not a function") end
        local reverse = {}
        for k,v in pairs(bindings) do reverse[v.Function]=k end
        for k,v in pairs(reverse) do if k == f then bindings[v]=nil end end
    end

    function self.GetNames()
        local out = {}
        for k,v in pairs(bindings) do if v.Name then table.insert(out, v.Name) end end
        return out
    end

    function self.Call() for k,v in pairs(bindings) do v.Function(self.Key) end end
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

    function self.Call(action, type)
        if type == "up" then
            if self.keyUp[action] then self.keyUp[action].Call(action) end
        elseif type == "down" then
            if self.keyDown[action] then self.keyDown[action].Call(action) end
        else
            if self.keyLoop[action] then self.keyDown[action].Call(action) end
        end
    end

    function self.ConvertKeyName(key)
        local names = {
            forward = "W",
            backward = "S",
            left = "A",
            right = "D",
            yawleft = "Q",
            yawright = "E",
            up = "Space",
            down = "C",
            gear = "G",
            light = "L",
            landing = "LANDING?",
            brake = "CTRL",
            option1 = "a1",
            option2 = "a2",
            option3 = "a3",
            option4 = "a4",
            option5 = "a5",
            option6 = "a6",
            option7 = "a7",
            option8 = "a8",
            option9 = "a9",
            stopengines = "MMB",
            speedup = "R",
            speeddown = "T",
            antigravity = "ANTIGRAVITY?",
            booster = "V"
        }
        if names[key] then return names[key] end
        return key
    end

    function self.GetNamedKeybinds()
        local out = {}
        for k,v in pairs(self.keyUp) do
            local names = v.GetNames()
            if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
        end
        for k,v in pairs(self.keyDown) do
            local names = v.GetNames()
            if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
        end
        for k,v in pairs(self.keyLoop) do
            local names = v.GetNames()
            if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
        end
        table.sort(out, function(a,b) return a.Key < b.Key end)
        return out
    end

    local function init()
        for k,v in pairs(self.keyUp) do v.Key = k end
        for k,v in pairs(self.keyDown) do v.Key = k end
        for k,v in pairs(self.keyLoop) do v.Key = k end
    end
    init()
    return self
end

keybindPresets = {}