function EventDelegate()
    local this = {}
    this.Delegates = {}

    function this.Add(f)
        if type(f) ~= "function" then error("[EventDelegate] Unable to add callback - not a function") return end
        for i=1,#this.Delegates do
            if this.Delegates[i] == f then return false end
        end
        table.insert(this.Delegates, f)
        return true
    end

    function this.Remove(f)
        if type(f) ~= "function" then error("[EventDelegate] Unable to remove callback - not a function") return end
        for i=1,#this.Delegates do
            if this.Delegates[i] == f then
                table.remove(this.Delegates, i)
                return true
            end
        end
        return false
    end

    function this.Call(...) for i=1,#this.Delegates do this.Delegates[i](...) end end

    function this.Count() return #this.Delegates end

    setmetatable(this, {
        __call = function(ref, ...) this.Call(...) end,
        __add = function(left, right)
            if left == this then this.Add(right) return this end
            if right == this then this.Add(left) return this end
            return this
            end,
        __sub = function(left, right)
            if left == this then this.Remove(right) return this end
            if right == this then this.Remove(left) return this end
            return this
            end,
        __tostring = function() return "EventDelegate(#".. #this.Delegates ..")" end
        })

    return this
end