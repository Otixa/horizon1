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
    self.CurrentIndex = 1
    self.ScrollLock = false
    self.Enabled = false
    
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

    self.MenuIcon = [[<span class="right"><i class="fas fa-sign-in-alt">&nbsp;</i></span>]]
    self.BackButton = SHUDMenuItem([[<i class="fas fa-sign-in-alt fa-flip-horizontal">&nbsp;</i>&nbsp;]].."Back", function() SHUD.Menu = SHUD.MenuList.prev SHUD.CurrentIndex = 1 end)
    self.Menu = {
        SHUDMenuItem(DynamicDocument([[<span>Throttle<span>]]..self.MakeSliderIndicator("round2(ship.throttle * 100)", "%")), 
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) ship.throttle = utils.clamp(ship.throttle + (system.getMouseWheel() * 0.05),0,1) end),
        SHUDMenuItem(DynamicDocument("<span>Mouse Steering<span>" .. self.MakeBooleanIndicator("mouse.enabled")),
            function() mouse.enabled = not mouse.enabled if mouse.enabled then mouse.lock() else mouse.unlock() end end),
        SHUDMenuItem("Ship Settings"..self.MenuIcon,  function() self.SelectMenu("shipSettings") end),
        SHUDMenuItem("Stability Assist"..self.MenuIcon, function() self.SelectMenu("stability") end),
        SHUDMenuItem("Vector Locking"..self.MenuIcon, function() self.SelectMenu("vectorLock") end),
        SHUDMenuItem("Mouse Control"..self.MenuIcon, function() self.SelectMenu("mouse") end),
        SHUDMenuItem([[<i class="fas fa-info-circle">&nbsp</i><span>&nbsp;Hotkeys</span>]]..self.MenuIcon, function() self.SelectMenu("hotkeys") end)
    }
    self.MenuList = {}
    self.MenuList.shipSettings = {
        SHUDMenuItem(DynamicDocument([[<span>Core ID:</span><span class="right">{{ship.id}}</span>]])).Disable(),
        SHUDMenuItem(DynamicDocument([[<span>Mass:</span><span class="right">{{round2(ship.mass/1000,2)}} Ton</span>]])).Disable(),
        SHUDMenuItem(DynamicDocument([[<span>FMax:</span><span class="right">{{round2(ship.fMax/1000,2)}} KN</span>]])).Disable(),

        SHUDMenuItem(DynamicDocument([[<span>Turn Speed</span>]]..self.MakeSliderIndicator("round2(ship.rotationSpeed, 1)")),
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) ship.rotationSpeed = ship.rotationSpeed + (system.getMouseWheel() * 0.5) end),
        SHUDMenuItem(DynamicDocument([[<span>Gravity Follow Speed</span>]]..self.MakeSliderIndicator("round2(ship.gravityFollowSpeed, 1)")),
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) ship.gravityFollowSpeed = ship.gravityFollowSpeed + (system.getMouseWheel() * 0.5) end),
    }
    self.MenuList.stability = {
        SHUDMenuItem(DynamicDocument("<span>Gravity Suppression<span>" .. self.MakeBooleanIndicator("ship.counterGravity")), function() ship.counterGravity = not ship.counterGravity end),
        SHUDMenuItem(DynamicDocument("<span>Gravity Follow</span>" .. self.MakeBooleanIndicator("ship.followGravity")), function() ship.followGravity = not ship.followGravity end)
    }
    self.MenuList.vectorLock = {
        SHUDMenuItem(DynamicDocument("<span>Auto Unlock<span>" .. self.MakeBooleanIndicator("ship.targetVectorAutoUnlock")), function() ship.targetVectorAutoUnlock = not ship.targetVectorAutoUnlock end),
        SHUDMenuItem("Lock Prograde", function() ship.targetVector = ship.target.prograde end),
        SHUDMenuItem("Lock Retrograde", function() ship.targetVector = ship.target.retrograde end),
        SHUDMenuItem("Lock Progravity", function() ship.targetVector = ship.target.progravity end),
        SHUDMenuItem("Lock Antigravity", function() ship.targetVector = ship.target.antigravity end)
    }
    self.MenuList.mouse = {
        SHUDMenuItem(DynamicDocument("<span>X Axis<span>" .. self.MakeBooleanIndicator("mouse.enableX")), function() mouse.enableX = not mouse.enableX end),
        SHUDMenuItem(DynamicDocument("<span>Y Axis<span>" .. self.MakeBooleanIndicator("mouse.enableY")), function() mouse.enableY = not mouse.enableY end),
        SHUDMenuItem(DynamicDocument([[<span>Sensetivity</span>]]..self.MakeSliderIndicator("round2(mouse.sensitivity, 3)")),
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) mouse.sensitivity = utils.clamp(mouse.sensitivity + (system.getMouseWheel() * 0.001), 0, 1) end),
        SHUDMenuItem(DynamicDocument([[<span>Threshold</span>]]..self.MakeSliderIndicator("round2(mouse.threshold, 2)")),
            function(_, _, w) if w.Active then w.Unlock() else w.Lock() end end,
            function(system, _ , w) mouse.threshold = utils.clamp(mouse.threshold + (system.getMouseWheel() * 0.05), 0, 1) end),
    }
    self.MenuList.hotkeys = {}

    local fa = [[<style>
    @keyframes flash {
        from { 
            background-color: #ff4500ff;
            box-shadow: 0px 0px 0.5em #ff4500ff;
        }
        to { 
            background-color: #ff450000;
            box-shadow: 0px 0px 0.5em #ff450000;
        }
    }
    .wrap {
        color: white;
        text-shadow: 0 0 0.2em #000000aa;
        vertical-align: middle;
        padding: 1em;
    }
    .state {
        display: inline-block;
        height: 1em;
        width: 1em;
        border-radius: 50%;
        float: right;
    }
    .state.true { background-color: greenyellow; }
    .state.false { background-color: red; }
    .sub { font-size: 0.3em; vertical-align: middle; }
    .warning { 
        animation: 200ms normal linear infinite;
        animation-name: flash;
        margin: 0.1em;
        padding: 0.5em 0.25em;
        text-align: center;
        margin-top: 0.5em;
        color: white;
    }
    p {
        text-transform: uppercase;
        margin-top: 0.1em;
        margin-bottom: 0;
    }
    .stats, .stats p { font-size: 0.85em; }
    .right { float: right;margin-right: 0.15vw } .item { margin: 0.2vw 0;padding: 0.15vw; } .item.active { background-color: #ae0f12aa; } .item.locked { background-color: #1db9deaa; } .item.disabled { background-color: #470608aa }.item.disabled.active { background-color: #7a0b0daa }
    </style>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-UHRtZLI+pbxtHCWp1t77Bi1L4ZtiqrqD80Kn4Z8NTSRyMA2Fd33n5dQ8lWUE00s/" crossorigin="anonymous">]]
    local template = DynamicDocument(fa..[[
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
            _ENV["_SHUDBUFFER"] = [[<div class="item active" style="font-size: 0.7vw;text-transform: uppercase;text-align: center">Press ]] .. "[" .. self.system.getActionKeyName("speedup") .. "]" .. [[ to  toggle menu</div>]]
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
            table.insert(self.MenuList.hotkeys, SHUDMenuItem([[<span>]]..key.Name..[[</span><span class="right">]]..keybinds.ConvertKeyName(key.Key)..[[</span>]]).Disable())
        end
    end

    return self
end)()