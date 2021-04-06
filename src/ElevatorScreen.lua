--@class ElevatorScreen
function ElevatorScreen()

    mousex = round2(screen.getMouseX(),4)
    mousey = round2(screen.getMouseY(),4)

    mouseClick = screen.getMouseState()

    local buttonColor = "#2F1010"
    local manual_control_fill = buttonColor
    local preset_1_fill = buttonColor
    local preset_2_fill = buttonColor
    local e_stop_fill = "#5D170B"
    local up10button = "#2F1010"
    local down10button = "#2F1010"
    local elevatorMove = utils.clamp(scaleViewBound(ship.altHoldPreset2,ship.altHoldPreset1,0,510,ship.altitude) * -1,-510,0)
    --local elevatorMove = utils.clamp(scaleViewBound(0,510,ship.altHoldPreset2,ship.altHoldPreset1,ship.altitude) * -1,-510,0)

    local elevation = mToKm(ship.altitude)
    local velocity = round2((ship.world.velocity:len() * 3.6),0)
    local verticalVelocity = round2(ship.world.velocity:dot(-ship.world.gravity:normalize()), 2)
    local deltaV = round2(ship.world.acceleration:len(),2)
    local targetDistance = round2(math.abs(ship.altitude - ship.altitudeHold),2)
    local brakeDistance, accelTime = kinematics.computeDistanceAndTime(ship.world.velocity:len(), 0, ship.mass, ship.vfMax,5,ship.maxBrake)
    local brakeDistanceRound = round2(math.abs(brakeDistance), 2)

    local statsTable = {}

    

    function renderStatsTable()
        local tbl = "<table>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Elevation".."</td><td>"..elevation.."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Target".."</td><td>"..mToKm(ship.altitudeHold).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Velocity".."</td><td>"..velocity .. " km/h".."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Vertical".."</td><td>"..round2(verticalVelocity,0).." m/s</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Delta-V".."</td><td>"..deltaV.." m/s</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Mass".."</td><td>"..round2(ship.mass / 1000,0).." t</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Gravity".."</td><td>"..round2(ship.world.gravity:len(), 2).." m/s</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Target Dist".."</td><td>"..mToKm(targetDistance).."</td></tr>"
        tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."Brake Dist".."</td><td>"..mToKm(brakeDistanceRound).."</td></tr>"
        --tbl = tbl .. "<tr><td style=\"padding-right: 55px;\">".."elevatorMove".."</td><td>"..elevatorMove.."</td></tr>"
        tbl = tbl .. "</table>"
        return tbl
    end

    if manualControl then manual_control_fill = "green" else manual_control_fill = "#2F1010" end
if e_stop then e_stop_fill = "green" else e_stop_fill = "#5D170B" end

if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.1276 and mousey <= 0.2051 then --P1 button
        if mouseClick == 1 then
            preset_1_fill = "white"
        else  
            preset_1_fill = "#521010"
        end
    end
    
if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.2153 and mousey <= 0.2900 then --P2 button
    if mouseClick == 1 then
        preset_2_fill = "white"
    else  
        preset_2_fill = "#521010"
    end
end
if mousex >= 0.0331 and mousex <= 0.4373 and mousey >= 0.3883 and mousey <= 0.4632 then --Manual Control
    if mouseClick == 1 then
        manual_control_fill = "white"
    else  
        manual_control_fill = "#521010"

    end
end

if mousex >= 0.1003 and mousex <= 0.3703 and mousey >= 0.5059 and mousey <= 0.9185 then --Emergency Stop
    if mouseClick == 1 then
        e_stop_fill = "white"
    else  
        e_stop_fill = "#c5cc00"

    end
end

if mousex >= 0.2413 and mousex <= 0.4373 and mousey >= 0.3004 and mousey <= 0.3764 then --Up 10
    if mouseClick == 1 then
            up10button = "white"
        else  
            up10button = "#521010"
        end
end
if mousex >= 0.0331 and mousex <= 0.2282 and mousey >= 0.3004 and mousey <= 0.3764 then --Down 10
        if mouseClick == 1 then
            down10button = "white"
        else  
            down10button = "#521010"
        end
end

    screen.setHTML([[
        <style>
        svg {
        height:100%
        width:100%
    }
    div.fixed {
        position: fixed;
        top: 110px;
        left: 575px;
        width: 420px;
        height: 440px;
        margin: auto;
      }
      .center {
        margin: 0;
        position: absolute;
        top: 40%;
        right: 10%;
        -ms-transform: translate(10%, -50%);
        transform: translate(10%, -50%);
      }
        
    table, th, td {
        padding-bottom: 5px;
        fill:silver;
        font-family:Verdana;
        font-size:23px;
        kit-user-select:none;
        ms-user-select:none;
        stroke:black;
        moz-user-select:none;
        webkit-user-select:none;
        font-weight:bold;
        text-align: left;
        vertical-align: middle;
      }
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
            .st21{font-size:30px;}
            .st22{letter-spacing:1;}
            .st23{fill:#8A8800;stroke:#000000;stroke-miterlimit:10;}
            .st24{font-size:50px;}
	        .st25{letter-spacing:2;}
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
 <polygon id="BtnEStop" style="fill:]]..e_stop_fill..[[;" class="st12" points="295.772,314.5 183.728,314.5 104.5,387.577 104.5,490.923 183.728,564 295.772,564 
     375,490.923 375,387.577 "/>
 <rect x="104" y="399" class="st13" width="266" height="88"/>
 <text transform="matrix(1 0 0 1 115.5605 429.3994)"><tspan x="0" y="0" class="st14 st15 st16 st17">EMERGENCY</tspan><tspan x="69.141" y="48" class="st14 st15 st16 st17">STOP</tspan></text>
 <polygon id="BtnPreset1" style="fill:]]..preset_1_fill..[[;" class="st18" points="433.5,80.5 446.5,93.5 446.5,113.5 433.5,126.5 44.5,126.5 31.5,113.5 31.5,93.5 
     44.5,80.5 "/>
 <polygon id="BtnPreset2" style="fill:]]..preset_2_fill..[[;" class="st18" points="433.5,132.5 446.5,145.5 446.5,165.5 433.5,178.5 44.5,178.5 31.5,165.5 31.5,145.5 
     44.5,132.5 "/>
 <rect x="31" y="32" class="st13" width="416" height="39.161"/>
 <text transform="matrix(1 0 0 1 47.5435 64.6797)" class="st14 st15 st19">Elevator Control</text>
 <polyline id="BtnPlusTen" style="fill:]]..up10button..[[;" class="st18" points="257.5,185.5 433.5,184.5 446.5,197.5 446.5,218.5 433.5,231.5 258.5,232.5 
     258.5,232 245.5,219 245.5,198 258.5,185 "/>
 <polyline id="BtnMinusTen" style="fill:]]..down10button..[[;" class="st18" points="43.5,185.5 219.5,184.5 232.5,197.5 232.5,218.5 219.5,231.5 44.5,232.5 44.5,232 
     31.5,219 31.5,198 44.5,185 "/>
 <polygon id="BtnManualCtrl" style="fill:]]..manual_control_fill..[[;" class="st18" points="434,239 447,252 447,272 434,285 45,285 32,272 32,252 45,239 "/>
 <rect x="48.612" y="91" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 79.6709 113.7998)" class="st14 st15 st21 st22">Preset 1:</text>
 <rect x="240.612" y="91" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 240.6123 113.7998)" class="st14 st15 st21 st22"> ]]..mToKm(ship.altHoldPreset1)..[[</text>
 <rect x="47.612" y="142" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 79.6709 164.7998)" class="st14 st15 st21 st22">Preset 2:</text>
 <rect x="239.612" y="142" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 239.6123 164.7998)" class="st14 st15 st21 st22"> ]]..mToKm(ship.altHoldPreset2)..[[</text>
 <rect x="34.612" y="196" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 87.582 218.7998)" class="st14 st15 st21 st22">-10m</text>
 <rect x="250.612" y="196" class="st20" width="191.387" height="26"/>
 <text transform="matrix(1 0 0 1 298.1182 218.7998)" class="st14 st15 st21 st22">+10m</text>
 <rect x="48" y="248" class="st20" width="383" height="26"/>
 <text transform="matrix(1 0 0 1 116.1147 270.7998)" class="st14 st15 st21 st22">Manual Control</text>
 <text transform="matrix(1 0 0 1 582.3379 73.7998)" class="st23 st15 st24 st25">Caterpillar XL</text>
 </svg>
        <div class="fixed">
            <div class="center">
                ]]..renderStatsTable()..[[
            </div>
        </div> ]])
end