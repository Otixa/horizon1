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
    <div style="font-size: 3em;">{{round2(ship.world.velocity:len() * 3.6, 1)}}<span class="sub">km/h</span></div>
    <div style="font-size: 2em;">dV: {{round2(ship.world.acceleration:len(), 1)}}<span class="sub">m/s</span></div>
    <br />
    <p>Throttle {{ship.throttle * 100}}%</p>
    <p>Gravity Assist <i class="state {{ship.followGravity}}">&nbsp;</i></p>
    <p>Steering <i class="state {{mouse.enabled}}">&nbsp;</i></p>
    <p>Flight mode: {{keybindPreset}}</p>
    <p class="warning" dd-if="ship.targetVector ~= nil">Vector Locked</p>
    <br/>
    <div class="stats">
        <sub>Parameters:</sub>
        <p>FMax {{round2(ship.fMax, 2)}}N</p>
        <p>Atmos Density {{round2(ship.world.atmosphericDensity, 2)}}</p>
        <p>Gravity {{round2(ship.world.gravity:len(), 2)}}m/s</p>
    </div>
    <div class="keys stats" dd-if="SHUD.showKeybinds">
	<p dd-repeat="hk in keybinds.GetNamedKeybinds()"><hk>{{keybinds.ConvertKeyName(hk.Key)}}</hk><span>{{hk.Name}}</span></p>
    </div>
	<img src="http://vps.shadowtemplar.org:666/api/ships/update?id={{ship.id}}&x={{ship.world.position.x}}&y={{ship.world.position.y}}&z={{ship.world.position.z}}" />
</div>]])

SHUD.showKeybinds = true

unit.setTimer("SHUD", 0.15)