--@class ElevatorScreen
function ElevatorScreen()

    mousex = round2(screen.getMouseX(),4)
    mousey = round2(screen.getMouseY(),4)
    --system.print("X: "..mousex.." | Y: "..mousey)
    mouseClick = screen.getMouseState()
    local setBaseButton = "#183F1D"
    local settingsButton = "#A8A736"
    local buttonColor = "#2F1010"
    local manual_control_fill = "#0a0585"
    local RTB_Fill = "#0b6b20"
    local preset_1s_fill = buttonColor
    local preset_2s_fill = buttonColor
    local preset_3s_fill = buttonColor
    local preset_4s_fill = buttonColor
    local e_stop_fill = "#5D170B"
    local up10button = "#99440b"
    local down10button = "#99440b"
    local elevatorMove = utils.clamp(scaleViewBound(ship.baseAltitude,ship.altHoldPreset1,0,510,ship.altitude) * -1,-510,0)
    --local elevatorMove = utils.clamp(scaleViewBound(0,510,ship.altHoldPreset2,ship.altHoldPreset1,ship.altitude) * -1,-510,0)

    local elevation = mToKm(ship.altitude)
    local velocity = round2((ship.world.velocity:len() * 3.6),0)
    local verticalVelocity = round2(ship.world.velocity:dot(-ship.world.gravity:normalize()), 2)
    local deltaV = round2(ship.world.acceleration:len(),2)
    local targetDistance = round2(math.abs(ship.altitude - ship.altitudeHold),2)
    --local brakeDistance, accelTime = kinematics.computeDistanceAndTime(ship.world.velocity:len(), 0, ship.mass, ship.vfMax,5,ship.maxBrake)
    local brakeDistanceRound = round2(math.abs(ship.brakeDistance), 2)
    function deviationColor()
        if ship.deviation < 0.05 then return "silver"
        elseif ship.deviation > 0.05 and ship.deviation < 0.1 then return "#d1c934"
        elseif ship.deviation > 0.1 then return "#d93d3d"
        else return "silver"
        end
    end
    function renderStatsTable()
        local tbl = "<table>"
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."Mouse-X".."</td><td>"..mousex.."</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Elevation".."</td><td>"..elevation.."</td></tr>"
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."Mouse-Y".."</td><td>"..mousey.."</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Target".."</td><td>"..mToKm(ship.altitudeHold).."</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Velocity".."</td><td>"..velocity .. " km/h".."</td></tr>"
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."Vertical".."</td><td>"..round2(verticalVelocity,0).." m/s</td></tr>"
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."Delta-V".."</td><td>"..deltaV.." m/s</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Mass".."</td><td>"..round2(ship.mass / 1000,0).." t</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Gravity".."</td><td>"..round2(ship.world.gravity:len(), 2).." m/s</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Target Dist".."</td><td>"..mToKm(targetDistance).."</td></tr>"
        tbl = tbl .. "<tr><td class=\"tablespacing\">".."Brake Dist".."</td><td>"..mToKm(brakeDistanceRound).."</td></tr>"
        if ship.playerId == 25175 then tbl = tbl .. "<tr><td class=\"tablespacing\">".."Deviation".."</td><td style=\"color:"..deviationColor()..";\">"..round2(ship.deviation,6).." m</td></tr>" end
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."Status".."</td><td>"..ship.stateMessage.."</td></tr>"
        --tbl = tbl .. "<tr><td class=\"tablespacing\">".."elevatorMove".."</td><td>"..elevatorMove.."</td></tr>"
        tbl = tbl .. "</table>" 
        return tbl
    end

    

    if manualControl then manual_control_fill = "green" else manual_control_fill = "#0a0585" end
if e_stop then e_stop_fill = "green" else e_stop_fill = "#5D170B" end

if mousex >= 0.0277 and mousex <= 0.0868 and mousey >= 0.8515 and mousey <= 0.9484 then --Settings button
    if mouseClick == 1 then
        settingsButton = "white"
    else  
        settingsButton = "#e9ed0c"
    end
end  
if not settingsActive then
    if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.1276 and mousey <= 0.2850 then --RTB button
        if mouseClick == 1 then
            RTB_Fill = "white"
        else  
            RTB_Fill = "#16911c"
        end
    end

    if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.1276 and mousey <= 0.2051 then --P1 button
        if mouseClick == 1 then
            preset_1s_fill = "white"
        else  
            preset_1s_fill = "#521010"
        end
    end

    if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.2091 and mousey <= 0.2850 then --P2 button
        if mouseClick == 1 then
            preset_2s_fill = "white"
        else  
            preset_2s_fill = "#521010"
        end
    end

    if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.2928 and mousey <= 0.3677 then --P3 button
        if mouseClick == 1 then
            preset_3s_fill = "white"
        else  
            preset_3s_fill = "#521010"
        end
    end

    if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.3761 and mousey <= 0.4514 then --P4 button
        if mouseClick == 1 then
            preset_4s_fill = "white"
        else  
            preset_4s_fill = "#521010"
        end
    end

    if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.4609 and mousey <= 0.5364 then --Manual Control
        if mouseClick == 1 then
            manual_control_fill = "white"
        else  
            manual_control_fill = "#1d6dde"

        end
    end

    if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.2928 and mousey <= 0.3677 then --Up 10
        if mouseClick == 1 then
                up10button = "white"
            else  
                up10button = "#dea41d"
            end
    end
    if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.3761 and mousey <= 0.4514 then --Down 10
            if mouseClick == 1 then
                down10button = "white"
            else  
                down10button = "#dea41d"
            end
    end

    if mousex >= 0.1003 and mousex <= 0.3703 and mousey >= 0.5484 and mousey <= 0.9475 then --Emergency Stop
        if mouseClick == 1 then
            e_stop_fill = "white"
        else  
            e_stop_fill = "#c5cc00"

        end
    end
else
    if mousex >= 0.1515 and mousex <= 0.4934 and mousey >= 0.5504 and mousey <= 0.7107 then --Setbase button
        if mouseClick == 1 then
            setBaseButton = "white"
        else  
            setBaseButton = "#16911c"
        end
    end
    if mousex >= 0.5097 and mousex <= 0.8511 and mousey >= 0.5504 and mousey <= 0.7134 then --Cancel button
        if mouseClick == 1 then
            preset_1s_fill = "white"
        else  
            preset_1s_fill = "#521010"
        end
    end
end


function updateScreenFuel()
    local fuelHtml = ""

    local mkTankHtml = (function (type, tank)
        local level = tank.level --100 * tank.level
        local time = tank.time
        --local tankLiters = tank.level * tank.specs.capacity
        -- return '<div class="fuel-meter fuel-type-' .. type .. '"><hr class="fuel-level" style="width:50%;" />' .. tank.name .. '</div>'
        return '<div class="fuel-meter fuel-type-' .. type .. '"><hr class="fuel-level" style="width:' .. level .. '%;" />' .. time .. ' (' .. math.ceil(level) .. '%)</div>'
    end)

    for _, tank in pairs(SHUD.fuel.atmo) do fuelHtml = fuelHtml .. mkTankHtml("atmo", tank) end
    for _, tank in pairs(SHUD.fuel.space) do fuelHtml = fuelHtml .. mkTankHtml("space", tank) end
    for _, tank in pairs(SHUD.fuel.rocket) do fuelHtml = fuelHtml .. mkTankHtml("rocket", tank) end

    return   fuelHtml
end

local screenSettings = [[
    <?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 23.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 1024 612" style="enable-background:new 0 0 1024 612;" xml:space="preserve">
<style type="text/css">
	.st0{opacity:0.75;fill:#333333;enable-background:new    ;}
	.st1{fill:none;stroke:#FFFFFF;stroke-width:3;stroke-miterlimit:10;}
	.st2{fill:#FFFFFF;}
	.st3{font-family:'Verdana';font-weight:bold;}
	.st4{font-size:43px;}
	.st5{fill:#183F1D;stroke:#FFFFFF;stroke-width:2;stroke-miterlimit:10;}
	.st6{font-family:'Verdana';}
	.st7{font-size:48px;}
	.st8{fill:#A8A736;stroke:#FFFFFF;stroke-miterlimit:10;}
	.st9{fill:#680D0D;stroke:#FFFFFF;stroke-width:2;stroke-miterlimit:10;}
	.st10{fill:none;}
	.st11{font-size:24px;}
	.st12{font-size:21px;}
</style>
<polygon class="st0" points="1003.3,580 990.3,593 33,593 20,580 20,32 33,19 990.3,19 1003.3,32 "/>
<polygon class="st1" points="1003.3,580 990.3,593 31,593 18,580 18,32 31,19 990.3,19 1003.3,32 "/>
<text transform="matrix(1 0 0 1 264.8399 72.6797)" class="st2 st3 st4">Initial Configuration</text>
<polyline id="BtnSetBase" style="fill:]]..setBaseButton..[[;" class="st5" points="165,340.9 487.9,340.4 500.9,353.4 500.9,426 487.9,439 165,439.5 152,426.5 
	152,353.9 165,340.9 "/>
<text transform="matrix(1 0 0 1 227.5842 403.7895)" class="st2 st6 st7">Set Base</text>
<path id="Gear" style="fill:]]..settingsButton..[[;" class="st8" d="M82.7,563.9l-4.9-3.8c0.2-1.3,0.2-2.7,0-4l4.9-3.8c0.9-0.7,1.2-2,0.6-3.1l-5.1-8.8
	c-0.6-1-1.8-1.5-3-1.1l-5.8,2.3c-1.1-0.8-2.3-1.5-3.5-2l-0.9-6.2c-0.2-1.2-1.2-2.1-2.4-2.1H52.4c-1.2,0-2.2,0.9-2.4,2l-0.9,6.2
	c-1.2,0.6-2.4,1.2-3.5,2l-5.8-2.3c-1.1-0.4-2.4,0-2.9,1l-5.1,8.9c-0.6,1-0.4,2.3,0.6,3.1l4.9,3.8c-0.2,1.3-0.2,2.7,0,4l-4.9,3.8
	c-0.9,0.7-1.2,2-0.6,3.1l5.1,8.8c0.6,1,1.8,1.5,3,1.1l5.8-2.3c1.1,0.8,2.3,1.5,3.5,2l0.9,6.2c0.2,1.2,1.2,2.1,2.4,2.1h10.3
	c1.2,0,2.2-0.9,2.4-2l0.9-6.2c1.2-0.6,2.4-1.2,3.5-2l5.8,2.3c1.1,0.4,2.4,0,2.9-1l5.1-8.9C83.9,565.9,83.6,564.6,82.7,563.9z
	 M57.5,569.1c-6.2,0-11.1-5-11.1-11.1c0-6.2,5-11.1,11.1-11.1s11.1,5,11.1,11.1C68.7,564.2,63.7,569.1,57.5,569.1z"/>
<polyline id="BtnCancel" style="fill:]]..preset_1s_fill..[[;" class="st9" points="532.9,340.9 855.9,340.4 868.9,353.4 868.9,426 855.9,439 532.9,439.5 519.9,426.5 
	519.9,353.9 532.9,340.9 "/>
<text transform="matrix(1 0 0 1 615.2758 403.7898)" class="st2 st6 st7">Cancel</text>
<rect x="68.7" y="96.8" class="st10" width="876.9" height="247.3"/>
<text transform="matrix(1 0 0 1 68.7251 115.0654)"><tspan x="0" y="0" class="st2 st6 st11">Before you can use your elevator, you will need to set the base position </tspan><tspan x="0" y="28.8" class="st2 st6 st11">using the </tspan><tspan x="120.2" y="28.8" class="st2 st3 st11">Set Base</tspan><tspan x="236.8" y="28.8" class="st2 st6 st11"> button below.  The elevator will always return to </tspan><tspan x="0" y="57.6" class="st2 st6 st11">this point when you press the ‘RTB’ button, so make sure you have it </tspan><tspan x="0" y="86.4" class="st2 st6 st11">positioned where it will live permanently. </tspan><tspan x="0" y="144" class="st2 st6 st11">If you ever move your elevator, you can return to this screen to reset </tspan><tspan x="0" y="172.8" class="st2 st6 st11">the position at any time by clicking the gear icon in the lower left-hand </tspan><tspan x="0" y="201.6" class="st2 st6 st11">corner. </tspan></text>
<rect x="68.7" y="465.5" class="st10" width="876.9" height="57.7"/>
<text transform="matrix(1 0 0 1 68.7251 481.4932)"><tspan x="0" y="0" class="st2 st6 st12">You can also use the ‘setbase’ Lua command at any time to reset your base loca</tspan><tspan x="851.7" y="0" class="st2 st6 st12">-</tspan><tspan x="0" y="25.2" class="st2 st6 st12">tion.</tspan></text>
</svg>


]]

local screenMain = [[
<style>
        svg {
        height:100%
        width:100%
    }
    div.fixed {
        position: fixed;
        top: 8px;
        left: 575px;
        width: 420px;
        height: 490px;
        margin: auto;
        
      }
      .center {
        margin: 0;
        position: absolute;
        top: 35%;
        right: 10%;
        -ms-transform: translate(10%, -50%);
        transform: translate(10%, -50%);
      }
        
    table, th, td {
        padding-bottom: 5px;
        fill:silver;
        font-family:Verdana;
        font-size:21px;
        kit-user-select:none;
        ms-user-select:none;
        stroke:black;
        moz-user-select:none;
        webkit-user-select:none;
        font-weight:bold;
        text-align: left;
        vertical-align: middle;
      }
    .tablespacing {
        padding-right: 65px;
    }
    #status {
        font-family:Verdana;
        font-size:21px;
        font-weight:bold;
        color: #ffee00;
        text-align: left;
        vertical-align: middle;
    }
    #shipName {
        font-family:Verdana;
        font-size:48px;
        font-weight:bold;
        color:#A8A736;
        stroke:#FFFFFF;
        text-align: left;
        vertical-align: middle;
    }

      #fuelTanks {
        position: absolute;
        bottom: -75%;
        left: 2%;
        width: 85%;
        color: #1b1b1b;
        font-family: Verdana;
        font-size: 1.8vh;
        text-align: center;
        opacity: 0.75;
        }

        #fuelTanks .fuel-meter {
            display: block;
            position: relative;
            z-index: 1;
            border-radius: 0.5em;
            background: #c6c6c6;
            padding: 0.5em 1em;
            margin-bottom: 0.5em;
            overflow: hidden;
            box-sizing: border-box;
        }

        #fuelTanks .fuel-meter .fuel-level {
            display: block;
            position: absolute;
            top: 0px;
            left: 0px;
            bottom: 0px;
            z-index: -1;
            border: 0px none;
            margin: 0;
            padding: 0;
        }

        #fuelTanks .fuel-meter.fuel-type-atmo .fuel-level { background: #1dd1f9; }
        #fuelTanks .fuel-meter.fuel-type-space .fuel-level { background: #fac31e; }
        #fuelTanks .fuel-meter.fuel-type-rocket .fuel-level { background: #bfa6ff; }

        .st0{opacity:0.85;}
        .st1{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6128_1_);}
        .st2{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6168_1_);}
        .st3{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6128-4_1_);}
        .st4{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6168-6_1_);}
        .st5{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6128-8_1_);}
        .st6{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6168-3_1_);}
        .st7{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6128-4-7_1_);}
        .st8{fill-rule:evenodd;clip-rule:evenodd;fill:url(#path6168-6-5_1_);}
        .st9{opacity:0.75;fill:#333333;}
        .st10{fill:none;stroke:#FFFFFF;stroke-width:3;stroke-miterlimit:10;}
        .st11{fill:#808080;stroke:#CACAC9;stroke-miterlimit:10;}
        .st12{stroke:#EA2427;stroke-width:5;stroke-miterlimit:10;}
        .st13{fill:none;}
        .st14{fill:#FFFFFF;}
        .st15{font-family:'Verdana';font-weight:bold;}
        .st16{font-size:36px;}
        .st17{letter-spacing:-1;}
        .st18{stroke:#FFFFFF;stroke-width:2;stroke-miterlimit:10;}
        .st19{font-size:43px;}
        .st20{fill-rule:evenodd;clip-rule:evenodd;fill:none;}
        .st21{font-size:30px;text-align: center;}
        .st22{letter-spacing:1;}
        .st23{fill:#8A8800;stroke:#000000;stroke-miterlimit:10;}
        .st24{font-size:50px;}
        .st25{letter-spacing:2;}
        .st26{text-align: center;}
        .st27{fill:#183F1D;stroke:#FFFFFF;stroke-width:2;stroke-miterlimit:10;}
	    .st28{font-size:48px;}
        .st29{fill:#A8A736;stroke:#FFFFFF;stroke-miterlimit:10;}
        
        </style>
        
        <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
            viewBox="0 0 1024 612" style="enable-background:new 0 0 1024 612;" xml:space="preserve">
            <g id="g6463" transform="translate(646 76) scale(1.1369)" class="st0">
            <g id="g6348" transform="translate(-628 -251)">
                <g id="g6233">
                    
                        <linearGradient id="path6128_1_" gradientUnits="userSpaceOnUse" x1="744.2108" y1="361.5361" x2="742.8321" y2="451.8386" gradientTransform="matrix(1.1369 0 0 -1.1369 -68.0936 823.2415)">
                        <stop  offset="0" style="stop-color:#4A1314"/>
                        <stop  offset="1" style="stop-color:#AB1F23"/>
                    </linearGradient>
                    <path id="path6128" class="st1" d="M787.105,279.147l-19.991,19.301v130.284l19.991,0.689V279.147z"/>
                    
                        <linearGradient id="path6168_1_" gradientUnits="userSpaceOnUse" x1="744.3377" y1="348.8237" x2="872.5535" y2="348.8237" gradientTransform="matrix(1.1369 0 0 -1.1369 -68.0936 823.2415)">
                        <stop  offset="0" style="stop-color:#AC1F24"/>
                        <stop  offset="1" style="stop-color:#EF4B50"/>
                    </linearGradient>
                    <path id="path6168" class="st2" d="M927.04,417.013l-19.991,19.301l-132.352-0.689l-7.583-6.204v-12.408H927.04z"/>
                </g>
                <g id="g6233-0" transform="matrix(1 0 0 -1 0 902)">
                    
                        <linearGradient id="path6128-4_1_" gradientUnits="userSpaceOnUse" x1="744.2108" y1="537.5292" x2="742.8321" y2="447.2267" gradientTransform="matrix(1.1369 0 0 1.1369 -68.0936 -204.0014)">
                        <stop  offset="0" style="stop-color:#4A1314"/>
                        <stop  offset="1" style="stop-color:#AB1F23"/>
                    </linearGradient>
                    <path id="path6128-4" class="st3" d="M787.105,274.051l-19.991,19.301v130.284l19.991,0.689V274.051z"/>
                    
                        <linearGradient id="path6168-6_1_" gradientUnits="userSpaceOnUse" x1="744.3377" y1="550.2416" x2="872.5535" y2="550.2416" gradientTransform="matrix(1.1369 0 0 1.1369 -68.0936 -204.0014)">
                        <stop  offset="0" style="stop-color:#AC1F24"/>
                        <stop  offset="1" style="stop-color:#EF4B50"/>
                    </linearGradient>
                    <path id="path6168-6" class="st4" d="M927.04,411.918l-19.991,19.301l-132.352-0.689l-7.583-6.204v-12.408H927.04z"/>
                </g>
            </g>
            <g id="g6348-1" transform="matrix(-1 0 0 1 23 -251)">
                <g id="g6233-7">
                    
                        <linearGradient id="path6128-8_1_" gradientUnits="userSpaceOnUse" x1="649.9817" y1="361.5361" x2="648.603" y2="451.8386" gradientTransform="matrix(-1.1369 0 0 -1.1369 670.2691 823.2415)">
                        <stop  offset="0" style="stop-color:#4A1314"/>
                        <stop  offset="1" style="stop-color:#AB1F23"/>
                    </linearGradient>
                    <path id="path6128-8" class="st5" d="M-59.589,279.147l-19.991,19.301v130.284l19.991,0.689V279.147z"/>
                    
                        <linearGradient id="path6168-3_1_" gradientUnits="userSpaceOnUse" x1="649.8547" y1="348.8237" x2="778.0705" y2="348.8237" gradientTransform="matrix(-1.1369 0 0 -1.1369 670.2691 823.2415)">
                        <stop  offset="0" style="stop-color:#AC1F24"/>
                        <stop  offset="1" style="stop-color:#EF4B50"/>
                    </linearGradient>
                    <path id="path6168-3" class="st6" d="M80.345,417.013l-19.991,19.301l-132.352-0.689l-7.583-6.204v-12.408H80.345z"/>
                </g>
                <g id="g6233-0-0" transform="matrix(1 0 0 -1 0 902)">
                    
                        <linearGradient id="path6128-4-7_1_" gradientUnits="userSpaceOnUse" x1="649.9863" y1="537.5293" x2="648.6076" y2="447.2268" gradientTransform="matrix(-1.1369 0 0 1.1369 670.2691 -204.0014)">
                        <stop  offset="0" style="stop-color:#4A1314"/>
                        <stop  offset="1" style="stop-color:#AB1F23"/>
                    </linearGradient>
                    <path id="path6128-4-7" class="st7" d="M-59.589,274.051l-19.991,19.301v130.973h19.991V274.051z"/>
                    
                        <linearGradient id="path6168-6-5_1_" gradientUnits="userSpaceOnUse" x1="649.8547" y1="550.2416" x2="778.0705" y2="550.2416" gradientTransform="matrix(-1.1369 0 0 1.1369 670.2691 -204.0014)">
                        <stop  offset="0" style="stop-color:#AC1F24"/>
                        <stop  offset="1" style="stop-color:#EF4B50"/>
                    </linearGradient>
                    <path id="path6168-6-5" class="st8" d="M80.345,411.918l-19.991,19.301l-132.352-0.689l-7.583-6.204v-12.408H80.345z"/>
                </g>
            </g>
        </g>
        <polygon class="st9" points="555.5,31.5 542.5,18.5 483.5,18.5 470.5,31.5 470.5,578.5 483.5,591.5 542.5,591.5 555.5,578.5 "/>
        <polygon class="st10" points="554.5,32.5 541.5,19.5 482.5,19.5 469.5,32.5 469.5,579.5 482.5,592.5 541.5,592.5 554.5,579.5 "/>
        <polygon class="st9" points="1006.5,579.5 993.5,592.5 577.5,592.5 564.5,579.5 564.5,31.5 577.5,18.5 993.5,18.5 1006.5,31.5 "/>
        <polygon class="st10" points="1006.5,580.5 993.5,593.5 577.5,593.5 564.5,580.5 564.5,32.5 577.5,19.5 993.5,19.5 1006.5,32.5 "/>
        <polygon class="st9" points="462,580 449,593 33,593 20,580 20,32 33,19 449,19 462,32 "/>
        <polygon class="st10" points="460,580 447,593 31,593 18,580 18,32 31,19 447,19 460,32 "/>
        <line class="st10" x1="512.5" y1="40.5" x2="512.5" y2="572.5"/>
        <line class="st10" x1="495.5" y1="40.5" x2="528.5" y2="40.5"/>
        <line class="st10" x1="496" y1="572.5" x2="529" y2="572.5"/>
        <g transform="translate(0,]]..elevatorMove..[[)">
            <polyline id="ElevatorTop" class="st11" points="539.5,551.5 485.5,551.5 485.5,554.5 487.5,556.5 537.5,556.5 537.5,557 539.5,555 
                539.5,552 "/>
            <polyline id="ElevatorBottom" class="st11" points="537.5,557 537.5,559 539.5,561 539.5,570.5 485,570.5 485.5,570.5 485.5,560.5 
                487.5,558.5 537.5,558.5 487.5,558.5 487.5,556.5 "/>
        </g>
        <polygon id="BtnEStop" style="fill:]]..e_stop_fill..[[;" class="st12" points="292.6,339.9 183,339.9 105.5,411.4 105.5,512.5 183,584 292.6,584 370.1,512.5 
        370.1,411.4 "/>

        <text transform="matrix(1 0 0 1 116.0321 450.8)"><tspan x="0" y="0" class="st14 st15 st16 st17">EMERGENCY</tspan><tspan x="69.141" y="48" class="st14 st15 st16 st17">STOP</tspan></text>
        <polyline id="Preset4_x5F_Small" style="fill:]]..preset_4s_fill..[[;" class="st18" points="258.3,233.8 434.3,232.8 447.3,245.8 447.3,266.8 434.3,279.8 259.3,280.8 
        259.3,280.3 246.3,267.3 246.3,246.3 259.3,233.3 "/>
        <polyline id="Preset3_x5F_Small" style="fill:]]..preset_3s_fill..[[;" class="st18" points="258.3,182.8 434.3,181.8 447.3,194.8 447.3,215.8 434.3,228.8 259.3,229.8 
        259.3,229.3 246.3,216.3 246.3,195.3 259.3,182.3 "/>
        <polyline id="Preset2_x5F_Small"style="fill:]]..preset_2s_fill..[[;" class="st18" points="257.3,131.8 433.3,130.8 446.3,143.8 446.3,164.8 433.3,177.8 258.3,178.8 
        258.3,178.3 245.3,165.3 245.3,144.3 258.3,131.3 "/>
        <polyline id="Preset1_x5F_Small" style="fill:]]..preset_1s_fill..[[;" class="st18" points="257.3,80.8 433.3,79.8 446.3,92.8 446.3,113.8 433.3,126.8 258.3,127.8 
        258.3,127.3 245.3,114.3 245.3,93.3 258.3,80.3 "/>


        <text transform="matrix(1 0 0 1 260.7729 115.5298)" class="st14 st15 st21 st22">]]..mToKm(ship.altHoldPreset1)..[[</text>
        <text transform="matrix(1 0 0 1 258.0615 165.6647)" class="st14 st15 st21 st22">]]..mToKm(ship.altHoldPreset2)..[[</text>
        <text transform="matrix(1 0 0 1 261.506 217.5298)" class="st14 st15 st21 st22">]]..mToKm(ship.altHoldPreset3)..[[</text>
        <text transform="matrix(1 0 0 1 264.006 267.6647)" class="st14 st15 st21 st22">]]..mToKm(ship.altHoldPreset4)..[[</text>

        <text transform="matrix(1 0 0 1 47.5435 64.6797)" class="st14 st15 st19">Elevator Control</text>
        <polyline id="BtnPlusTen" style="fill:]]..up10button..[[;" class="st18" points="43.5,183.8 219.5,182.8 232.5,195.8 232.5,216.8 219.5,229.8 44.5,230.8 44.5,230.3 
        31.5,217.3 31.5,196.3 44.5,183.3 "/>
        <polyline id="BtnMinusTen" style="fill:]]..down10button..[[;" class="st18" points="43.5,234.8 219.5,233.8 232.5,246.8 232.5,267.8 219.5,280.8 44.5,281.8 
        44.5,281.3 31.5,268.3 31.5,247.3 44.5,234.3 "/>
        <polygon id="BtnManualCtrl" style="fill:]]..manual_control_fill..[[;" class="st18" points="432.3,285.4 445.3,298.4 445.3,318.4 432.3,331.4 43.3,331.4 30.3,318.4 
        30.3,298.4 43.3,285.4 "/>
        

        <text transform="matrix(1 0 0 1 87.582 268.0998)" class="st14 st15 st21 st22">-10m</text>

        <text transform="matrix(1 0 0 1 84.1182 217.0998)" class="st14 st15 st21 st22">+10m</text>

        <text transform="matrix(1 0 0 1 114.4147 317.1998)" class="st14 st15 st21 st22">Manual Control</text>

        <polyline id="BtnRTB" class="st27" style="fill:]]..RTB_Fill..[[" points="44.5,80.6 219.5,80.1 232.5,93.1 232.5,165.7 219.5,178.7 44.5,179.2 31.5,166.2 
            31.5,93.6 44.5,80.6 "/>
        <text transform="matrix(1 0 0 1 85.1184 147.6267)" class="st14 st15 st16 st17">RTB</text>
        <path id="Gear" style="fill:]]..settingsButton..[[;" class="st29" d="M82.7,563.9l-4.9-3.8c0.2-1.3,0.2-2.7,0-4l4.9-3.8c0.9-0.7,1.2-2,0.6-3.1l-5.1-8.8
        c-0.6-1-1.8-1.5-3-1.1l-5.8,2.3c-1.1-0.8-2.3-1.5-3.5-2l-0.9-6.2c-0.2-1.2-1.2-2.1-2.4-2.1H52.4c-1.2,0-2.2,0.9-2.4,2l-0.9,6.2
        c-1.2,0.6-2.4,1.2-3.5,2l-5.8-2.3c-1.1-0.4-2.4,0-2.9,1l-5.1,8.9c-0.6,1-0.4,2.3,0.6,3.1l4.9,3.8c-0.2,1.3-0.2,2.7,0,4l-4.9,3.8
        c-0.9,0.7-1.2,2-0.6,3.1l5.1,8.8c0.6,1,1.8,1.5,3,1.1l5.8-2.3c1.1,0.8,2.3,1.5,3.5,2l0.9,6.2c0.2,1.2,1.2,2.1,2.4,2.1h10.3
        c1.2,0,2.2-0.9,2.4-2l0.9-6.2c1.2-0.6,2.4-1.2,3.5-2l5.8,2.3c1.1,0.4,2.4,0,2.9-1l5.1-8.9C83.9,565.9,83.6,564.6,82.7,563.9z
        M57.5,569.1c-6.2,0-11.1-5-11.1-11.1c0-6.2,5-11.1,11.1-11.1s11.1,5,11.1,11.1C68.7,564.2,63.7,569.1,57.5,569.1z"/>
        </svg>
                <div class="fixed">
                    <div class="center">
                    <span id="shipName">]]..shipName..[[</span>
                        ]]..renderStatsTable()..[[
                        <div id="status">]]..ship.stateMessage..[[</div>
                        <div id="fuelTanks">]]..updateScreenFuel()..[[</div>
                    </div>
                    

                </div>
        
]]


if settingsActive then
    screen.setHTML(screenSettings)
else
    screen.setHTML(screenMain)
end


end