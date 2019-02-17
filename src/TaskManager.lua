--[[
    Shadow Templar Task Manager
    Version 1.04
    (c) Copyright 2019 Shadow Templar <http://www.shadowtemplar.org>

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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