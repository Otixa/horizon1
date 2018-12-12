system.showScreen(1)
unit.hide()

function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

atmosFuel = 50

SHUD = DynamicDocument([[<style>
@keyframes flash {
    from { opacity: 1; }
    to { opacity: 0; }
}
.screen {
    background-color: #00000088;
}
.state {
    display: inline-block;
    height: 1em;
    width: 1em;
    border-radius: 50%;
}
.state.true { background-color: greenyellow; }
.state.false { background-color: red; }
.sub { font-size: 0.3em; vertical-align: middle; }
.state.warn.true { 
    background-color: orangered;
    animation: 500ms normal linear infinite;
    animation-name: flash;
    box-shadow: 0px 0px 0.5em orangered;
}
</style>
<div class="screen">
    <div class="bootstrap">
        <div style="font-size: 3em;width: 4em;">{{round2(engines.velocity:len() * 3.6, 1)}}<span class="sub">km/h</span></div>
        <p>Throttle: {{engines.throttle * 100}}%</p>
        <p>[a2] Gravity Assist: <i class="state {{engines.followGravity}}"></i></p>
        <p>[a1] Mouse Movement: <i class="state {{mouse.enabled}}"></i></p>
        <p>[a7] Vector Lock: <i class="state warn {{engines.targetVector:len() ~= 0}}"></i></p>
        <br />
        <p>FMax: {{round2(engines.fMax, 2)}}N</p>
        <p>Atmos Density: {{round2(engines.atmosDensity, 2)}}</p>
        <div style="font-size: 2em;width: 4em;">{{round2(engines.acceleration:len(), 1)}}<span class="sub">m/s</span></div>
    </div>
</div>]])

unit.setTimer("SHUD", 0.15)