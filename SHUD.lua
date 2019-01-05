function round2(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
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

    local SMI = SHUDMenuItem
    local DD = DynamicDocument
    
    local function esc(x)
        return (x:gsub("%%", "%%%%"))
    end

    function self.MakeBooleanIndicator(varName)
        local tmpl = [[<span class="right">
            <i dd-if="varName == true" class="fas fa-check-square">&nbsp;</i>
            <i dd-if="varName == false" class="fas fa-square">&nbsp;</i>
        </span>]]
        return tmpl:gsub("varName", esc(varName))
    end

    function self.MakeSliderIndicator(varName, suffix)
        suffix = suffix or ""
        local tmpl = [[<span class="right">{{varName}}{{suffix}}<i class="fas fa-sort">&nbsp;</i></span>]]
        return tmpl:gsub("varName", esc(varName)):gsub("{{suffix}}", esc(suffix))
    end

    function self.GenerateMenuLink(text, link)
        return SMI(text..self.MenuIcon,  function() self.SelectMenu(link) end)
    end

    self.MenuIcon = [[<span class="right"><i class="fas fa-sign-in-alt">&nbsp;</i></span>]]
    self.BackButton = SMI([[<i class="fas fa-sign-in-alt fa-flip-horizontal">&nbsp;</i>&nbsp;]].."Back", function() SHUD.Menu = SHUD.MenuList.prev SHUD.CurrentIndex = 1 end)
    self.Menu = {
        SMI(DD([[<span>Throttle<span>]]..self.MakeSliderIndicator("round2(ship.throttle * 100)", "%")), 
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) ship.throttle = utils.clamp(ship.throttle + (system.getMouseWheel() * 0.05),-1,1) end),
        SMI(DD("<span>Mouse Steering<span>" .. self.MakeBooleanIndicator("mouse.enabled")),
            function() mouse.enabled = not mouse.enabled if mouse.enabled then mouse.lock() else mouse.unlock() end end),
        self.GenerateMenuLink("Flight Mode", "flightMode"),
        self.GenerateMenuLink("Ship Stats", "shipStats"),
        self.GenerateMenuLink("Stability Assist", "stability"),
        self.GenerateMenuLink("Vector Locking", "vectorLock"),
        SMI([[<i class="fas fa-info-circle">&nbsp;</i><span>&nbsp;Hotkeys</span>]]..self.MenuIcon, function() self.SelectMenu("hotkeys") end)
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
        SMI("Lock Progravity", function() ship.targetVector = ship.target.progravity end),
        SMI("Lock Antigravity", function() ship.targetVector = ship.target.antigravity end)
    }
    self.MenuList.hotkeys = {}

    local fa = [[
    <link rel="stylesheet" href="http://dustreaming.shadowtemplar.org/shud.css" crossorigin="anonymous">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css" crossorigin="anonymous">]]
    local template = DD(fa..[[
        <div class="bootstrap wrap" style="width: 12vw;background-color: #000000aa">
            <div style="font-size: 3em;">{{round2(ship.world.velocity:len() * 3.6, 1)}}<span class="sub">km/h</span></div>
            <div style="font-size: 2em;">dV: {{round2(ship.world.acceleration:len(), 1)}}<span class="sub">m/s</span></div>
            <br />
            <p>Flight mode: {{keybindPreset}}</p>
            <p class="warning" dd-if="ship.targetVector ~= nil">Vector Locked</p>
            <br/>
            <div class="stats">
                <sub>Parameters:</sub>
                <p>Atmos Density {{round2(ship.world.atmosphericDensity, 2)}}</p>
                <p>Gravity {{round2(ship.world.gravity:len(), 2)}}m/s</p>
                <p>Altitude {{round2(ship.altitude)}}m</p>
            </div>
            <img src="http://vps.shadowtemplar.org:666/api/ships/update?id={{ship.id}}&x={{ship.world.position.x}}&y={{ship.world.position.y}}&z={{ship.world.position.z}}" />
            {{_SHUDBUFFER}}
        </div>]])
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

    function self.Update()
        if not self.ScrollLock and self.Enabled then
            local wheel = system.getMouseWheel()
            if wheel ~= 0 then
                self.CurrentIndex = self.CurrentIndex - wheel
                if self.CurrentIndex > #self.Menu then self.CurrentIndex = 1
                elseif self.CurrentIndex < 1 then self.CurrentIndex = #self.Menu end
            end
        end
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
            _ENV["_SHUDBUFFER"] = [[<div class="item active helpText">Press ]] .. "[" .. self.system.getActionKeyName("speedup") .. "]" .. [[ to  toggle menu</div>]]
        end
        self.system.setScreen(template.Read())
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
    end

    return self
end)()