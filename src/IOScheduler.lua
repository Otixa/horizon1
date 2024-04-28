--@class IOScheduler

--[[
Custom IO scheduler to deal with limited data packet size
and tick rate of screen send/receive. IOScheduler.defaultData
will send as fast as possible, while IOScheduler.queueData()
will interrupt default send and to send queued data.
--]]

IOScheduler = (function()
    local self = {}

    self.defaultData = nil
    self.currentTask = nil
    self.taskQueue = {}
    function self.queueData(data)
         table.insert(self.taskQueue, data)
    end
    --Send queued data to screen
    function self.send(T)
		if not screen then return end
        output = screen.getScriptOutput()
        screen.clearScriptOutput()
        if output ~= "ack" then
            if output and output ~= "" then
                handleOutput.Read(output)
            end
            coroutine.yield()
            self.send(T)
        else
            screen.setScriptInput(serialize(T))
        end
    end
    --Queue data to send or send self.defaultData
    function self.runQueue()
        if #self.taskQueue == 0 then
            --Send default table
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

    --Add to system.update()
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
		if type(output) ~= "string" or output == "" then
			return
		end
		local s = deserialize(output)
		if type(s) ~= "table" then
			system.print('[E] Communication error!')
			return
		end
		if s.dataType == "config" then
			config = s
			local delta = tonumber(config.delta)
			-- fix for +/- 10m buttons:
			if delta ~= nil then
				config.targetAlt = ship.altitude + delta
			end
			stats.data.target = config.targetAlt
			self.Execute()
		elseif s.updateReq then
			ioScheduler.queueData(config)
		else
			system.print(tostring(s))
		end
    end

    function self.Execute()
        ship.baseAltitude = helios:closestBody(ship.baseLoc):getAltitude(ship.baseLoc)

        ship.altitudeHold = config.targetAlt

        if config.estop then
            config.targetAlt = 0
            ship.altitudeHold = 0
            ship.brake = true
            ship.elevatorActive = false
            ship.verticalLock = false
            ship.stateMessage = "EMERGENCY STOP"
            system.print(ship.stateMessage)
            ioScheduler.queueData(config)
        else
            ship.brake = false
        end
        if ship.altitudeHold and ship.altitudeHold ~= 0 then
            ship.elevatorActive = true
            system.print("Alt. diff: "..(config.targetAlt - ship.baseAltitude))
            ship.targetDestination = moveWaypointZ(ship.baseLoc, config.targetAlt - ship.baseAltitude)
        end
        if config.setBaseReq then
            setBase()
            config.setBaseReq = false
            ioScheduler.queueData(config)
        end
        --if config.updateReq then
        --    config.updateReq = false
        --    ioScheduler.queue(config)
        --end
        manualControlSwitch()
    end

    return self
end)()

ioScheduler = IOScheduler
handleOutput = HandleOutput