TaskManager = {}
TaskManager.Stack = {}
_ENV["core"] = core
_ENV["system"] = system
_ENV["unit"] = unit
function TaskManager.Register(task)
    if not task.Coroutine then error("[TaskManager] Trying to register a non-Task") end
    table.insert(TaskManager.Stack, task)
end
function TaskManager.Update()
    for i=1,#TaskManager.Stack do
        local task = TaskManager.Stack[i]
        if task and task.Coroutine ~= nil then
            if coroutine.status(task.Coroutine) ~= "dead" then
                local state, retn = coroutine.resume(task.Coroutine)
                task.Error = not state
                task.LastReturn = retn
            else
                table.remove(TaskManager.Stack, i)
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

function DUCrypt()
    local self = {}
    self.k = "fb0KXk7evdjeoskzIJYN"
    self.k2 = false
    function self.u(string)
        return string:gsub("&lsbracket","["):gsub("&rsbracket","]"):gsub("&newline", '\n')
    end
    function self.rv(length)
        local res = ""
        for i = 1, length do
            res = res .. string.char(math.random(48, 122))
        end
        return res
    end
    function self.r(x)
            func = load(x, nil, "t", _ENV)
            if func then
            func()
        	else error("Error on stage decode")
        	end
    end
    function self.d(x,k)
        return Task(function()
        if k == nil then k = false end
        while not k and not self.k2 do coroutine.yield() end

        ux = self.u(x)
        local out = ""
        for i=1,#ux do
            local k = self.k:byte( ((i-1) % #self.k)+1 )
            if k < 32 then k = k + 32 end
            local v = ux:byte(i)
            if v < 32 then 
                out = out .. string.char(v) 
            else
                local p1 = v - 32
                p1 = p1 - (k-32)
                if p1 < 0 then p1 = 95 + p1 end
                out = out .. string.char(p1+32)
            end
            if math.fmod(i, 1000) == 0 then coroutine.yield() end
        end
        return out
    end)
    end
    function self.i()
        local x = [[{{keyinit}}]]
        self.d(x,true).Then(function(val) DC.r(val) end).Catch(function(e) error(e) end).Finally(function() self.k=self.rv(256) self.k2=true end)
    end
    self.i()
    return self
end
DC = DUCrypt()