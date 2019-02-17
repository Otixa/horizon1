--[[
    Shadow Templar Keybind Controller
    Version 2.1
]]

function KeybindDelegate(key)
    local this = EventDelegate()
    this.Key = key
    function this.Add(f, keybindName)
        if type(f) ~= "function" then error("[Keybind] Unable to add callback - not a function") return end
        for i=1,#this.Delegates do
            if this.Delegates[i] == f then return false end
        end
        table.insert(this.Delegates, {Function = f, Name = keybindName})
        return true
    end

    function this.Remove(f)
        if type(f) ~= "function" then error("[Keybind] Unable to remove callback - not a function") return end
        for i=1,#this.Delegates do
            if this.Delegates[i].Function == f then
                table.remove(this.Delegates, i)
                return true
            end
        end
        return false
    end

    function this.GetNames()
        local out = {}
        for k,v in pairs(this.Delegates) do
            if v.Name then table.insert(out, v.Name) end
        end
        return out
    end

    function this.Call(...) for i=1,#this.Delegates do this.Delegates[i].Function(...) end end
    return this
end

function KeybindController()
    local this = {}
    this.Bindings = {
        up = {},
        down = {},
        loop = {}
    }

    local bindingMeta = {
        __index = function(t, k)
            t[k] = KeybindDelegate(k)
            return t[k]
        end
    }
    setmetatable(this.Bindings.up, bindingMeta)
    setmetatable(this.Bindings.down, bindingMeta)
    setmetatable(this.Bindings.loop, bindingMeta)

    function this.Call(action, type, ...)
        if not this.Bindings[type] then error("[KeybindController] Invalid event type. up/down/loop expected.") return end
        if not this.Bindings[type][action] then error("[KeybindController] Invalid event key - " .. action) end
        this.Bindings[type][action](action, type, ...)
    end

    function this.GetNamedKeybinds()
        local out = {}
        for _,binds in pairs(this.Bindings) do
            for k,v in pairs(binds) do
                local names = v.GetNames()
                if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
            end
        end
        table.sort(out, function(a,b) return a.Key < b.Key end)
        return out
    end

    this.Init = function() end
    setmetatable(this, {__index = function(t, k) return this.Bindings[k] end})
    return this
end

keybindPresets = {}