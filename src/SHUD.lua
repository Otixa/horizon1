mat4 = require('cpml/mat4')
vec2 = require('cpml/vec2')

function round2(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function SpeedConvert(value)
    if not value or value == 0 then return {0,"00","km/h"} end
    if value > 194.44 then
        local ending = tonumber(tostring(round2(value/55.55, 2)):match("%.(%d+)"))
        ending = string.format("%02d",ending)
        return {round2(value/55.55),ending,"su/h"}   
    end
    local ending = tonumber(tostring(round2(value/3.6, 2)):match("%.(%d+)"))
    ending = string.format("%02d",ending)
    return {round2(value*3.6),ending,"km/h"}
end


function SHUDMenuItem(content, action, update)
    local self = {}
    self.Enabled = true
    self.Active = false
    self.Content = content
    self.Class = ""
    self.Action = action or function(system, unit, self) end
    self.Update = update or function(system, unit, self) end

    function self.Disable()
        self.Enabled = false
        return self
    end

    function self.Enable()
        self.True = false
        return self
    end

    function self.Lock()
        SHUD.ScrollLock = true
        self.Active = true
        self.Class = "locked"
        return self
    end

    function self.Unlock()
        SHUD.ScrollLock = false
        self.Active = false
        self.Class = ""
        return self
    end

    return self
end

SHUD =
(function()
    local self = {}
    self.Enabled = false
    self.FreezeUpdate = false
    self.IntroPassed = false
    self.FOV = 85
    self.Resolution = vec2(1920, 1080)
    self.Markers = {}

    self.MarkerBuffer = {}

    function self.worldToScreen(pos)
        local P = mat4():perspective(48, 1920/1080, 0.1, 100000)
        local adjustedPos = ship.world.position - vec3(unit.getOwnerRelativePosition())
        local V = mat4():look_at(adjustedPos, adjustedPos + ship.world.forward, ship.world.up)

        local pos = V * P * { pos.x, pos.y, pos.z, 1 }

        pos[1] = pos[1] / pos[4] * 0.5 + 0.5
        pos[2] = pos[2] / pos[4] * 0.5 + 0.5

        pos[1] = pos[1] * 100
        pos[2] = pos[2] * 100

        return vec3(pos[1], pos[2], pos[3])
    end

    local SMI = SHUDMenuItem
    local DD = DynamicDocument
    
    function self.UpdateMarkers()
        self.MarkerBuffer = {}
        for i=1,#self.Markers do
            local m = self.Markers[i]
            local marker = {}
            local p = vec3(0,0,0)
            if type(m.Position) == "function" then marker.pos = m.Position() p = m.Position() else marker.pos = m.Position p = m.Position end
            marker.pos = self.worldToScreen(marker.pos)
            marker.class = m.Class
            marker.content = '&nbsp;'
            if m.Name then marker.content = [[<div class="name">]] .. m.Name .. [[</div>]] end
            if m.ShowDistance then marker.content = marker.content .. [[<div class="distance">]] .. round2((ship.world.position - p):len()) .. [[m</div>]] end
            if marker.pos.z > 0 then self.MarkerBuffer[#self.MarkerBuffer + 1] = marker end
        end
    end

    local function esc(x)
        return (x:gsub("%%", "%%%%"))
    end

    function self.MakeBooleanIndicator(varName)
        local tmpl = [[<span class="right">
            <i dd-if="varName == true">✓&nbsp;</i>
            <i dd-if="varName == false">✘&nbsp;</i>
        </span>]]
        return tmpl:gsub("varName", esc(varName))
    end

    function self.MakeSliderIndicator(varName, suffix)
        suffix = suffix or ""
        local tmpl = [[<span class="right">{{varName}}{{suffix}}<i>&udarr;&nbsp;</i></span>]]
        return tmpl:gsub("varName", esc(varName)):gsub("{{suffix}}", esc(suffix))
    end

    function self.GenerateMenuLink(text, link)
        return SMI(text..self.MenuIcon,  function() self.SelectMenu(link) end)
    end

    self.MenuIcon = [[<span class="right"><i>&gt;&nbsp;</i></span>]]
    self.BackButton = SMI([[<i>&lt;&nbsp;</i>&nbsp;]].."Back", function() SHUD.Menu = SHUD.MenuList.prev SHUD.CurrentIndex = 1 end)
    self.Menu = {
        SMI(DD([[<span>Throttle<span>]]..self.MakeSliderIndicator("round2(ship.throttle * 100)", "%")), 
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) ship.throttle = utils.clamp(ship.throttle + (system.getMouseWheel() * 0.05),-1,1) end),
        SMI(DD("<span>Mouse Steering<span>" .. self.MakeBooleanIndicator("mouse.enabled")),
            function() mouse.enabled = not mouse.enabled if mouse.enabled then mouse.lock() else mouse.unlock() end end),
        self.GenerateMenuLink("Flight Mode", "flightMode"),
        self.GenerateMenuLink("Stability Assist", "stability"),
        self.GenerateMenuLink("Vector Locking", "vectorLock"),
        self.GenerateMenuLink("Ship Stats", "shipStats"),
        SMI([[<i>&#9432;&nbsp;</i><span>&nbsp;Hotkeys</span>]]..self.MenuIcon, function() self.SelectMenu("hotkeys") end)
    }
    self.MenuList = {}
    self.MenuList.flightMode = {}
    self.MenuList.shipStats = {
        SMI(DD([[<span>Core ID:</span><span class="right">{{ship.id}}</span>]])).Disable(),
        SMI(DD([[<span>Mass:</span><span class="right">{{round2(ship.mass/1000,2)}} Ton</span>]])).Disable(),
        SMI(DD([[<span>FMax:</span><span class="right">{{round2(ship.fMax/1000,2)}} KN</span>]])).Disable(),
        SMI(DD([[<span>Pos X:</span><span class="right">{{round2(ship.world.position.x)}}</span>]])).Disable(),
        SMI(DD([[<span>Pos Y:</span><span class="right">{{round2(ship.world.position.y)}}</span>]])).Disable(),
        SMI(DD([[<span>Pos Z:</span><span class="right">{{round2(ship.world.position.z)}}</span>]])).Disable(),
    }
    self.MenuList.stability = {
        SMI(DD("<span>Gravity Suppression<span>" .. self.MakeBooleanIndicator("ship.counterGravity")), function() ship.counterGravity = not ship.counterGravity end),
        SMI(DD("<span>Gravity Follow</span>" .. self.MakeBooleanIndicator("ship.followGravity")), function() ship.followGravity = not ship.followGravity end),
        SMI(DD("<span>Inertial Dampening<span>" .. self.MakeBooleanIndicator("ship.inertialDampening")), function() ship.inertialDampening = not ship.inertialDampening end),
    }
    self.MenuList.vectorLock = {
        SMI(DD("<span>Auto Unlock<span>" .. self.MakeBooleanIndicator("ship.targetVectorAutoUnlock")), function() ship.targetVectorAutoUnlock = not ship.targetVectorAutoUnlock end),
        SMI("Unlock", function() ship.targetVector = nil end),
        SMI("Lock Prograde", function() ship.targetVector = ship.target.prograde end),
        SMI("Lock Retrograde", function() ship.targetVector = ship.target.retrograde end),
        SMI("Lock Radial", function() ship.targetVector = ship.target.radial end),
        SMI("Lock Anti-Radial", function() ship.targetVector = ship.target.antiradial end),
        SMI("Lock Normal", function() ship.targetVector = ship.target.normal end),
        SMI("Lock Anti-Normal", function() ship.targetVector = ship.target.antinormal end)
    }
    self.MenuList.hotkeys = {}

    local fa = "<style>" .. CSS_SHUD .. "</style>"
    local template = DD(fa..[[
        <div id="speedometerBar">&nbsp;</div>
        <div id="speedometer">
            <span class="display">
            	<span class="major">{{SpeedConvert(ship.world.velocity:len())[1]}}</span>
            	<span class="minor">{{SpeedConvert(ship.world.velocity:len())[2]}}</span>
            	<span class="unit">{{SpeedConvert(ship.world.velocity:len())[3]}}</span>
            </span>
            <span class="accel">
            	<span class="major">{{round2(ship.world.acceleration:len(), 1)}}</span>
            	<span class="unit">m/s</span>
            </span>
            <span class="vertical">
            	{{round2(ship.world.velocity:dot(-ship.world.gravity:normalize()), 1)}}
            </span>
            <span class="alt">
            	{{round2(ship.altitude)}}m
            </span>
            <span class="misc">ATM {{round2(ship.world.atmosphericDensity, 2)}} | G {{round2(ship.world.gravity:len(), 2)}}m/s</span>
        </div>
        <div id="horizon-menu">
            {{_SHUDBUFFER}}
        </div>
        ]])
    local itemTemplate = [[<div class="item {{class}}">{{content}}</div>]]

    function self.SelectMenu(menuName)
        if not SHUD.MenuList[menuName] then error("[SHUD] Undefined menu: " .. menuName) end
        SHUD.MenuList.prev = SHUD.Menu
        SHUD.Menu = SHUD.MenuList[menuName]
        SHUD.CurrentIndex = 1
        if SHUD.Menu[#SHUD.Menu] ~= SHUD.BackButton then table.insert(SHUD.Menu, SHUD.BackButton) end
    end

    function self.Select()
        if not self.Enabled then return end
        if #self.Menu < 1 then
            return
        end
        self.Menu[self.CurrentIndex].Action(self.system, self.unit, self.Menu[self.CurrentIndex])
    end

    function self.Render()
        local buffer = ""
        if self.Enabled then 
            for i = 1, #self.Menu do
                local item = self.Menu[i]
                if item.Active then item.Update(self.system, self.unit, item) end
                local lb = itemTemplate
                local cls = ""
                local content = item.Content
                if content.Read then
                    content = content.Read()
                end
                content = esc(content)
                if self.CurrentIndex == i then
                    cls = "active"
                end
                if not item.Enabled then cls = cls .. " disabled" end
                lb = lb:gsub("{{class}}", cls .. " " .. item.Class)
                lb = lb:gsub("{{content}}", content)
                buffer = buffer .. lb
            end
            _ENV["_SHUDBUFFER"] = esc(buffer)
        else
            _ENV["_SHUDBUFFER"] = [[<div class="item helpText">Press ]] .. "[" .. self.system.getActionKeyName("speedup") .. "]" .. [[ to  toggle menu</div>]]
        end
        if not self.FreezeUpdate then self.system.setScreen(template.Read()) end
    end

    function self.Update()
        if not self.ScrollLock and self.Enabled then
            local wheel = system.getMouseWheel()
            if wheel ~= 0 then
                self.CurrentIndex = self.CurrentIndex - wheel
                if self.CurrentIndex > #self.Menu then self.CurrentIndex = 1
                elseif self.CurrentIndex < 1 then self.CurrentIndex = #self.Menu end
            end
        end
    end

    function self.Init(system, unit, keybinds)
        self.system = system
        self.unit = unit
        self.CurrentIndex = 1
        self.ScrollLock = false
        system.showScreen(1)
        unit.hide()
        local keys = keybinds.GetNamedKeybinds()
        self.MenuList.hotkeys = {}
        for i=1,#keys do
            local key = keys[i]
            table.insert(self.MenuList.hotkeys, SMI([[<span>]]..key.Name..[[</span><span class="right">]]..self.system.getActionKeyName(key.Key)..[[</span>]]).Disable())
        end

        self.MenuList.flightMode = {}
        for k,v in pairs(keybindPresets) do
            table.insert(self.MenuList.flightMode,
            SMI(string.upper(k), function() 
                self.Init(self.system, self.unit, v)
                keybindPreset = k
                keybindPresets[keybindPreset].Init()
            end))
        end
        unit.setTimer("HUD", 0.02)
        keybinds.Init()
    end

    return self
end)()