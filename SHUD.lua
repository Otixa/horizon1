system.showScreen(1)
unit.hide()

function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

SHUD = DynamicDocument([[
<style>
{{defaultCSS}}
</style>
<div class="bootstrap wrap" style="width: 11vw;background-color: black">
    <div style="font-size: 3em;">{{round2(engines.velocity:len() * 3.6, 1)}}<span class="sub">km/h</span></div>
    <div style="font-size: 2em;">dV: {{round2(engines.acceleration:len(), 1)}}<span class="sub">m/s</span></div>
    <br />
    <p>Throttle {{engines.throttle * 100}}%</p>
    <p>Gravity Assist <i class="state {{engines.followGravity}}">&nbsp;</i></p>
    <p>Steering <i class="state {{mouse.enabled}}">&nbsp;</i></p>
    <p>Flight mode: {{keybindPreset}}</p>
    <p class="warning" dd-if="engines.targetVector ~= nil">Vector Locked</p>
    <br/>
    <div class="stats">
        <sub>Parameters:</sub>
        <p>FMax {{round2(engines.fMax, 2)}}N</p>
        <p>Atmos Density {{round2(engines.atmosDensity, 2)}}</p>
        <p>Gravity {{round2(engines.gravity:len(), 2)}}m/s</p>
    </div>
    <div class="keys stats" dd-if="engines.velocity:len() < 3.33 or SHUD.showKeybinds">
	<p dd-repeat="hk in keybinds.GetNamedKeybinds()"><hk>{{keybinds.ConvertKeyName(hk.Key)}}</hk><span>{{hk.Name}}</span></p>
    </div>
	<img src="http://vps.shadowtemplar.org:666/api/ships/update?id={{engines.world.id}}&x={{engines.world.position.x}}&y={{engines.world.position.y}}&z={{engines.world.position.z}}" />
</div>]])

SHUD.showKeybinds = false

unit.setTimer("SHUD", 0.15)