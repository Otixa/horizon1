--@class ElevatorScreen
function ElevatorScreen()

    mousex = round2(screen.getMouseX(),4)
    mousey = round2(screen.getMouseY(),4)

    mouseClick = screen.getMouseState()

    local manual_control_fill = "rosybrown"
    local preset_1_fill = "rosybrown"
    local preset_2_fill = "rosybrown"
    local e_stop_fill = "#E80000"
    local up10button = "whitesmoke"
    local down10button = "whitesmoke"

    local elevation = mToKm(ship.altitude)
    local velocity = round2((ship.world.velocity:len() * 3.6),0)
    local verticalVelocity = round2(ship.world.velocity:dot(-ship.world.gravity:normalize()), 2)
    local deltaV = round2(ship.world.acceleration:len(),2)
    local targetDistance = round2(math.abs(ship.altitude - ship.altitudeHold),2)
    local brakeDistance, accelTime = kinematics.computeDistanceAndTime(ship.world.velocity:len(), 0, ship.mass, ship.vfMax,5,ship.maxBrake)
    local brakeDistanceRound = round2(math.abs(brakeDistance), 2)

    local statsTable = {}

    

    function renderStatsTable()
        --<table>
        --    <tr><td>Variable1</td><td>30.33</td></tr>
        --    <tr><td>Variable2</td><td>99.99km</td></tr>
        --</table>
        local tbl = "<table>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Elevation".."</td><td>"..mToKm(ship.altitude).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Target".."</td><td>"..mToKm(ship.altitudeHold).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Velocity".."</td><td>"..velocity .. " km/h".."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Vertical".."</td><td>"..verticalVelocity.."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Delta-V".."</td><td>"..deltaV.."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Target Dist".."</td><td>"..mToKm(targetDistance).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Brake Dist".."</td><td>"..mToKm(brakeDistanceRound).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Target".."</td><td>"..mToKm(targetDistance).."</td></tr>"
        tbl = tbl .. "</table>"
        return tbl
    end

    if manualControl then manual_control_fill = "green" else manual_control_fill = "rosybrown" end
    if e_stop then e_stop_fill = "green" else e_stop_fill = "#E80000" end

    if mousex >= 0.3307 and mousex <= 0.5309 and mousey >= 0.2173 and mousey <= 0.2800 then --P2 button
        if mouseClick == 1 then
            preset_2_fill = "white"
        else  
            preset_2_fill = "#c5cc00"
        end
    end
    if mousex >= 0.0684 and mousex <= 0.2686 and mousey >= 0.2162 and mousey <= 0.2804 then --P1 button
        if mouseClick == 1 then
            preset_1_fill = "white"
        else  
            preset_1_fill = "#c5cc00"
        end
    end
    if mousex >= 0.2088 and mousex <= 0.4094 and mousey >= 0.3693 and mousey <= 0.4313 then --Manual Control
        if mouseClick == 1 then
            manual_control_fill = "white"
        else  
            manual_control_fill = "#c5cc00"
            
        end
    end

    if mousex >= 0.1790 and mousex <= 0.4517 and mousey >= 0.5145 and mousey <= 0.9691 then --Emergency Stop
        if mouseClick == 1 then
            e_stop_fill = "white"
        else  
            e_stop_fill = "#c5cc00"
            
        end
    end

    if mousex >= 0.2752 and mousex <= 0.3236 and mousey >= 0.1587 and mousey <= 0.2421 then --Up 10
        up10button = "red"
    end
    if mousex >= 0.2752 and mousex <= 0.3236 and mousey >= 0.2421 and mousey <= 0.3239 then --Down 10
        down10button = "red"
    end

    screen.setHTML([[
        <style>
        svg {
        height:100%
        width:100%
    }
    div.fixed {
        position: fixed;
        top: 100px;
        left: 600px;
        width: 400px;
        height: 450px;
      }
        
    table, th, td {
        padding-bottom: 5px;
        fill:silver;
        font-family:Verdana;
        font-size:22px;
        kit-user-select:none;
        ms-user-select:none;
        stroke:black;
        moz-user-select:none;
        webkit-user-select:none;
        font-weight:bold;
        text-align: left;
      }
        </style>
        
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 1024 612" preserveAspectRatio="xMinYMin meet" >
        <rect id="svgEditorBackground" x="0" y="0" width="1024" height="612" style="fill:url(#svgEditorGrid2); stroke: none;"/>
        <defs id="svgEditorDefs">
        <style type="text/css">#e4_texte{stroke:none;}
        #e2_texte{font-weighfont-weight:bold;font-style:normal;stroke:none;}
        
        #e14_texte{stroke:black;}
        .stats_text{fill:silver;font-family:Verdana;font-size:24.5px;kit-user-select:none;ms-user-select:none;stroke:black;moz-user-select:none;webkit-user-select:none;font-weight:bold;}
        .header_text{fill:#E6E6E6;font-family:Verdana;font-size:48px;font-style:normal;stroke:black;user-selecfont-weighfont-weighfont-weight:bold;}
        .button_text{fill:whitesmoke;font-family:Verdana;user-select:none;font-weight:bold;text-anchor:middle;font-size:20px;moz-user-select:none;webkit-user-select:none;ms-user-select:none;}
        .ten_markers{fill:whitesmoke;font-family:Verdana;font-size:15.00px;kit-user-select:none;ms-user-select:none;moz-user-select:none;webkit-user-select:none;}
        #e21_texte{stroke:black;}
        </style>
        </defs>
        <rect x="568.7151402525471" y="39.847999572753906" style="fill:#2C0000;stroke:none;stroke-width:1.04px;" id="e1_rectangle" width="402.679" height="561.024" transform="matrix(0.973915 0 0 0.970556 32.4473 -23.0831)"/>
        <rect x="40.36065141200155" y="16.253929138183594" style="fill:#2C0000;stroke:none;stroke-width:1.04px;" id="e2_rectangle" width="569.413" height="297.815" transform="matrix(0.937833 0 0 0.937833 0.0977745 0.684498)"/>
        <text x="77.59953308105469" y="79.1725845336914" id="e4_texte" xml:space="preserve" style=";;" transform="matrix(1 0 0 1 33.0973 0)" class="header_text">Elevator Control</text>
        <text x="710.4553833007812" y="70.25910949707031" id="e2_texte" xml:space="preserve" style=";;e;one;t:none;" transform="matrix(1 0 0 1 2.77529 0)" class="header_text">Stats</text>
        <path d="M787.0070533026122,103.291004v411.592162" style="fill:none;stroke:silver;stroke-width:2.03px;stroke-dasharray:4px, 2px;stroke-opacity:0.7;" id="e10_pathV" transform="matrix(1 0 0 1 -4.59214 0)"/>
        <path d="M3.279791793552264,-3.051961259400926l-2,2v4l2,2h4l2,-2v-4l-2,-2Z" style="fill:]]..e_stop_fill..[[; stroke:darkred; vector-effect:non-scaling-stroke;stroke-width:10px;" id="e11_shape" transform="matrix(33.8568 0 0 33.8568 132.297 420.523)"/>
        <text style="fill:black;font-family:Arial;font-size:29px;text-anchor:start;-select: none;-webkit-user-select: none;-ms-user-select: none;" x="195.57196044921875" y="455.1111145019531" id="e12_texte">
        <tspan x="310.5436706542969" style="text-anchor:middle;font-weight:bold;stroke:#BABABA;fill:#FFFFFF;font-size:38.3px;" y="440">EMERGENCY</tspan>
        <tspan x="310.5592956542969" dy="1.25em" style="text-anchor:middle;font-weight:bold;stroke:#BABABA;fill:#FFFFFF;font-size:38.3px;">STOP</tspan>
        </text>
        
        <rect x="336.61800956823737" y="130.03005981445312" style="fill:]]..preset_2_fill..[[;stroke:none;stroke-width:1px;" id="e17_rectangle" width="205.013" height="39.8492" transform="matrix(1 0 0 1 0 0)"/>
        <path d="M16.303030411839906,5.434343482623676h-2l4,2l4,-2h-2v-4h2l-4,-2l-4,2h2Z" style="fill:rosybrown; stroke:black; vector-effect:non-scaling-stroke;stroke-width:1px;" id="e18_shape" transform="matrix(12.977 0 0 12.977 67.439 105.389)"/>
        <rect x="84.94305992224128" y="130.0299530029297" style="fill:]]..preset_1_fill..[[;stroke:none;stroke-width:1px;" id="e3_rectangle" width="205.013000" height="39.849201" transform="matrix(1 0 0 1 -17.0514 0)"/>
        <rect x="340.81222343542487" y="223.35931396484375" style="fill:]]..manual_control_fill..[[;stroke:none;stroke-width:1px;" id="e4_rectangle" width="205.013000" height="39.849201" transform="matrix(1 0 0 1 -138.362 0)"/>
        <text x="120.59403991699219" y="156.772216796875" id="e1_texte" transform="matrix(1 0 0 1 49.8063 1.0483)" xml:space="preserve" class="button_text" style="">P1: ]]..mToKm(ship.altHoldPreset1)..[[</text>
        <text x="382.7548828125" y="155.7235565185547" id="e17_texte" transform="matrix(1 0 0 1 56.3657 1.0483)" xml:space="preserve" class="button_text">P2: ]]..mToKm(ship.altHoldPreset2)..[[</text>
        <text x="248.00421142578125" y="249.5771484375" id="e18_texte" transform="matrix(1 0 0 1 56.9478 1.57298)" xml:space="preserve" class="button_text">Manual Control</text>
        <text style="fill: ]]..up10button..[[;" x="280.4389343261719" y="125.61329650878906" id="e19_texte" transform="matrix(1 0 0 1 0 0)" class="ten_markers">+10m</text>
        <text style="fill: ]]..down10button..[[;" x="280.43890380859375" y="184.03807067871094" id="e20_texte" transform="matrix(1 0 0 1 2.73438 0)" class="ten_markers">-10m</text>
        
        </svg>
        <div class="fixed">
            ]]..renderStatsTable()..[[
        </div> ]])
end