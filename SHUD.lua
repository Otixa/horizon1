system.showScreen(1)
unit.hide()

function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

SHUD = DynamicDocument([[
<style>
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
hk::before { content: '['; vertical-align: top; }
hk::after { content: ']'; vertical-align: top; }
hk { 
    font-size: 0.85em; 
    text-transform: lowercase; 
    vertical-align: top;
    color: aqua;
    display: inline;
}
p {
    text-transform: uppercase;
    margin-top: 0.1em;
    margin-bottom: 0;
}
.keys { margin-top: 1em; }
.keys span { margin: 0; text-transform: uppercase; }
.stats, .stats p { font-size: 0.85em; }
</style>
<div class="bootstrap wrap" style="width: 11vw;">
    <div style="font-size: 3em;">{{round2(engines.velocity:len() * 3.6, 1)}}<span class="sub">km/h</span></div>
    <div style="font-size: 2em;">dV: {{round2(engines.acceleration:len(), 1)}}<span class="sub">m/s</span></div>
    <br />
    <p>Throttle {{engines.throttle * 100}}%</p>
    <p>Gravity Assist <i class="state {{engines.followGravity}}">&nbsp;</i></p>
    <p>Steering <i class="state {{mouse.enabled}}">&nbsp;</i></p>
    <p class="warning" dd-if="engines.targetVector ~= nil">Vector Locked</p>
    <div class="stats">
        <sub>Parameters:</sub>
        <p>FMax {{round2(engines.fMax, 2)}}N</p>
        <p>Atmos Density {{round2(engines.atmosDensity, 2)}}</p>
        <p>Gravity {{round2(engines.gravity:len(), 2)}}m/s</p>
        <p>Mass {{round2(engines.mass, 2)}}kg</p>
    </div>
    <div class="keys stats" dd-if="engines.velocity:len() < 14">
        <hk>a1</hk><span>Steering</span><br />
        <hk>a2</hk><span>Gravity Assist</span><br />
        <hk>a3</hk><span>Cruise Control</span><br />
        <hk>a5</hk><span>Lock: Prograde</span><br />
        <hk>a6</hk><span>Lock: Retrograde</span><br />
        <hk>a7</hk><span>Unlock Vector</span>
    </div>
</div>]])

unit.setTimer("SHUD", 0.15)