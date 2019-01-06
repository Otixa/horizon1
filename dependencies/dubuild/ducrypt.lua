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
    mwc = {}
    function self.random(a, b)
        local m = mwc.m
        local t = mwc.a * mwc.x + mwc.c
        local y = t % m
        mwc.x = y
        mwc.c = math.floor(t / m)
        if not a then return y / 0xffff
        elseif not b then
            if a == 0 then return y
            else return 1 + (y % a) end
        else
            return a + (y % (b - a + 1))
        end
    end
    function self.randomseed(s)
        mwc.a, mwc.c, mwc.m = 1103515245, 12345, 0x10000
        mwc.x = s
    end
    function self.rv(length)
        local res = ""
        for i = 1, length do
            res = res .. string.char(self.random(48, 122))
        end
        return res
    end
    function self.u(string)
        return string:gsub("&LSB","["):gsub("&RSB","]"):gsub('&NLN', '\n')
    end
    
    function self.r(x)
            func = load(x, nil, "t", _ENV)
            if func then
            func()
        	else error("Error on stage decode")
        	end
    end
    function self.d(x)
        return Task(function()
        ux = self.u(x)
        local out = ""
        for i=1,#ux do
            local k = self.k:byte( ((i-1) % #self.k)+1 )

            local v = ux:byte(i)
            if v < 32 then 
                out = out .. string.char(v) 
            else
                local p1 = v - 32
                local p2 = k - 32
                p1 = p1 - p2
                if p1 < 0 then p1 = 95 + p1 end
                out = out .. string.char(32+p1)
            end
            if math.fmod(i, 500) == 0 then coroutine.yield() end
        end
        return out
    end)
    end
    function self.i()
        local x = {{9801,12321,12996,10201},{10609,10201,13456,4489,12321,12100,13225,13456,12996,13689,9801,13456,5329,10000}}
        ___b = '' ___c = ''
        for i=1,#x[1] do ___b = ___b .. string.char(math.sqrt(x[1][i])) end
        for i=1,#x[2] do ___c = ___c .. string.char(math.sqrt(x[2][i])) end
        __b = _ENV[___b]
        local a = 1157745
        if ___b and __b[___c] then a = math.floor(_ENV["core"][___c]()+a) end
        self.randomseed(a)
        return self.rv(256)
    end
    self.k = self.i()
    return self
end
DC = DUCrypt()