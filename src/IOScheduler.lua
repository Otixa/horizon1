--@class IOScheduler

--[[
Custom IO scheduler to deal with limited data packet size
of screen send/recieve.  self.defaultData will send as fast as
possible, while self.queueData() will interrupt default send and
to send queued data.
--]]

IOScheduler = (function()
    local self = {}
    self.defaultData = nil
    self.currentTask = nil
    self.taskQueue = {}
    function self.queueData(data)
         table.insert(self.taskQueue, data)
    end

    --Send data and await response
    function self.send(T)
        screen.clearScriptOutput()
        output = screen.getScriptOutput()
            while output ~= "ack" do
                coroutine.yield()
                output = screen.getScriptOutput()
                if output ~= "ack" and output ~= "" then
                    handleOutput.Read(output)
                end
            end
        screen.setScriptInput(serialize(T))
    end

    --Queue table to send
    function self.runQueue()
        if #self.taskQueue == 0 then
            if self.defaultData ~= nil then
                   self.currentTask = coroutine.create(function()
                       self.send(self.defaultData)
                   end)
            coroutine.resume(self.currentTask)
            end
        else
            --Iterate over self.taskQueue and send each to screen
            self.currentTask = coroutine.create(function()
                for i=1, #self.taskQueue do
                    local data = self.taskQueue[i]
                    if type(data) == "table" then
                        self.send(data)
                    end
                    table.remove(self.taskQueue,i)
                end
            end)
            coroutine.resume(self.currentTask)
        end
    end
    
    --Add to system.update
    function self.update()
        if self.currentTask then
            if coroutine.status(self.currentTask) ~= "dead" then
                coroutine.resume(self.currentTask)
            else
                self.runQueue()
            end
        else
            self.runQueue()
        end
    end
    
    return self
end)()

HandleOutput = (function()
    local self = {}
    function self.Read(output)
        if output ~= nil and output ~= "" then
            if type(output) == "string" then
                local s = deserialize(output)
                if s.dataType == "config" then
                    config = s
                    stats.data.target = config.targetAlt
                end
            end
        end
    end

    return self
end)()

ioScheduler = IOScheduler
handleOutput = HandleOutput


