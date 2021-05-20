--@class StateMachine
StateMachine = (function()
    local this = {}
    this.Current = nil
    this.Update = function()
        local state = this.Current
        if state then
            if state.Condition() then 
                state.End()
                if state.Next ~= nil then
                    system.print("State change: " .. state.Next.Name)
                    this.Current = state.Next
                    state.Next.Start()
                end
            else
                state.Action()
            end
        end
    end
    return this
end)

State = (function(name, condition, action, nextState)
    local this = {}
    setmetatable(this, {__call = function(ref, ...) ref.Update(...) end, _name = "State" })
    this.Name = name or "State"
    this.Next = nextState
    this.Condition = condition or function() return true end
    this.Start = function() end
    this.End = function() end
    this.Action = action or function() end
    return this
end)