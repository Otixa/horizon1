--[[
    Shadow Templar Task Manager
    Version 1.04
]]

TaskManager = (function()
    local self = {}
    self.Stack = {}

    function self.Register(task)
        if not task.Coroutine then error("[TaskManager] Trying to register a non-Task") end
        table.insert(self.Stack, task)
    end

    function self.Update()
        for i=1,#self.Stack do
            local task = self.Stack[i]
            if task and task.Coroutine ~= nil then
                if coroutine.status(task.Coroutine) ~= "dead" then
                    local state, retn = coroutine.resume(task.Coroutine)
                    task.Error = not state
                    task.LastReturn = retn
                else
                    table.remove(self.Stack, i)
                    if task.Error and task._Catch then 
                        task._Catch(task.LastReturn)
                    elseif task._Then ~= nil then 
                        task._Then(task.LastReturn)
                    end
                    if task._Finally ~= nil then task._Finally() end
                    task.Finished = true
                end
            end
        end
    end
    return self
end)()


function Task(func)
    local self = {}
    self.LastReturn = nil
    self.Error = nil
    self.Finished = false
    if type(func) ~= "function" then error("[Task] Not a function.") end
    self.Coroutine = coroutine.create(func)

    function self.Then(func)
        if type(func) ~= "function" then error("[Task] Then callback not a function.") end
        self._Then = func
        return self
    end

    function self.Finally(func)
        if type(func) ~= "function" then error("[Task] Finally callback not a function.") end
        self._Finally = func
        return self
    end

    function self.Catch(func)
        if type(func) ~= "function" then error("[Task] Catch callback not a function.") end
        self._Catch = func
        return self
    end
    TaskManager.Register(self)
    return self
end

function await(task)
    if not task or not task.Coroutine then error("Trying to await non-task object") end
    while not task.Finished do
       coroutine.yield() 
    end
    return task.LastReturn
end