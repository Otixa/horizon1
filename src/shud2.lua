--@class CSS_SHUD
displaySize = 0.85
primaryColor = primaryColor or "b80000"
secondaryColor = secondaryColor or "e30000"
textShadowColor = textShadowColor or "e81313"

--system.print(fuelFontSize)
CSS_SHUD = [[
#horizon {
	left: 0;
	top: 0;
	position: fixed;
	width: 100vw;
	height: 100vh;
	background: radial-gradient(ellipse 27vw 11vw at 50% 51vw, rgba(1,5,8,0.6) 50%,rgba(1,5,8,0) 90%);
	font-family: Montserrat, Roboto, Verdana;
}
#fuelTanks {
	position: absolute;
	top: 2%;
	left: 2%;
	margin: 2%;
	display: flex;
	flex-wrap: wrap;
}
.fuel-tanks {
	width: 12vw;
	margin-right: 1vw;
	display: inline-block;
	vertical-align: top;
}
.fuel-meter {
	height: 1.8vh;
	background-color: #222;
	border: 1px solid #fff;
	border-radius: 0.6vh;
	font-size: 0.9vh;
	text-align: left;
	overflow: hidden;
	padding: 0;
}
.fuel-meter hr.fuel-level {
	height: 1.6vh;
	border: none;
	border-radius: 0.6vh;
	margin: 0;
	margin-top: 0.1vh;
	padding: 0;
}
.fuel-meter hr.fuel-level + span {
	font-family: Montserrat, Roboto, Verdana;
	position: relative;
	top: -1.4vh;
	left: 0.4vw;
	z-index: 1;
	color: #fff;
	font-weight: bold;
	font-size: 0.9vh;
	padding 0;
	text-shadow: 0.25vw 0.25vw 1.05vw #000;
}
.fuel-meter span:first-child {display: none;}
.fuel-type-atmo .fuel-level {background: #1dd1f9;}
.fuel-type-space .fuel-level {background: #ea5409;}
.fuel-type-rocket .fuel-level {background: #bfa6ff;}

#speedometer::before {
	display: block;
	position: absolute;
	content: ' ';
	top: 0.25vh;
	bottom: -17vh;
	left: 50%;
	width: 31vw;
	border: 10px solid #]]..primaryColor..[[;
	border-bottom: 0;
	border-right: 0;
	border-left: 0;
	border-radius: 100%;
	transform: translateX(-50%);
	background-color: transparent;
	filter: blur(100vw);
}

#speedometerBar {
	display: block;
	position: fixed;
	left: 50%;
	top: 77.2vh;
	width: 30vw;
	height: 24.5vh;
	transform: translate(-50%);
	content: ' ';
	border: 10px solid #]]..primaryColor..[[;
	border-bottom: 0;
	border-right: 0;
	border-left: 0;
	border-radius: 100%;
	background-size: contain;
	background-color: transparent;
	filter: blur(0.1vw);
}

#speedometer {
	font-family: 'Montserrat', 'Roboto', 'Verdana';
	font-weight: normal;
	font-style: normal;
	position: fixed;
	left: 50%;
	bottom: 14vh;
	font-size: 2.5vw;
	transform: translate(-50%);
	background-color: transparent;
	width: 30vw;
	height: 10vh;
	text-align: center;
}

#speedometer .display {
	position: absolute;
	top: calc(50% + 1vh);
	left: calc(50% + 0.25em);
	transform: translate(-50%, -50%);
	font-weight: bold;
	text-shadow: 0 0 0.75vw #]]..textShadow..[[;
	padding: 0;
	margin: 0;
	font-size: 2.8vw;
}

#speedometer .display .minor, #speedometer .unit {
	position: relative;
	left: -0.5em;
	vertical-align: super;
	font-size: 40%;
}

#speedometer .unit {
	vertical-align: 50%;
	font-size: 23%;
	left: -1.33em;
}

#speedometer .accel {
	font-size: 1.2vw;
	text-shadow: 0 0 0.15vw #000000;
	position: absolute;
	left: 12.5%;
	bottom: 0;
	opacity: 0.75;
}

#speedometer .accel .major::before {
	content: 'Δ';
	font-size: 40%;
}

#speedometer .accel .unit {
	left: -0.66em;
}

#speedometer .alt {
	position: absolute;
	left: 50%;
	bottom: -0.65vh;
	transform: translateX(-50%);
	font-size: 0.65vw;
	text-align: center;
}

#speedometer .misc {
	position: absolute;
	left: 50%;
	bottom: -1.5vh;
	transform: translateX(-50%);
	font-size: 0.4vw;
	text-align: center;
}

#speedometer .throttle {
	position: absolute;
	left: 50%;
	bottom: -3vh;
	transform: translateX(-50%);
	font-size: 0.7vw;
	text-align: center;
}

#speedometer .vertical {
	font-size: 1.3vw;
	text-shadow: 0 0 0.15vw #000000;
	position: absolute;
	right: 12.5%;
	bottom: 0;
	opacity: 0.75;
	text-align: right;
}

#speedometer .vertical::after {
	content: '↕ m/s';
	vertical-align: 50%;
	font-size: 33%;
}

#speedometer::after {
	display: block;
	font-size: 0;
	background-size: contain;
	content: ' ';
	position: absolute;
	top: 0.5vh;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 666;
	opacity: 0.5;
}

#horizon-menu {
	text-transform: uppercase;
	font-family: 'Verdana';
	font-size: ]] .. displaySize .. [[vw;
	display: flex;
	flex-direction: column;
	position: fixed;
	bottom: 35%;
	left: 2vw;
	width: 18vw;
	padding: 1vw;
	transform: perspective(50vw) rotateY(35deg);
	text-shadow: 0.1vw 0 0.25vw #000000;
}
#horizon-menu .item {
	color: #fff;
	padding: 0.2vw 0.5vw;
	z-index: 99999;
}
#horizon-menu .item .right {
	float: right;
}
#horizon-menu .item .red {
	color: #]]..secondaryColor..[[;
}
#horizon-menu .item.active {
	position: relative;
	text-shadow: 0 0 0.75vw #]]..secondaryColor..[[;
	transform: translateZ(0.33vw);
	font-size: 1.15em;
	transform-style: preserve-3d;
}

#horizon-menu .item.active::before {
	display: block;
	content: ' ';
	position: absolute;
	top: 15%;
	bottom: 15%;
	left: 0.1vw;
	right: 0.1vw;
	background: #]]..secondaryColor..[[aa;
	z-index: -50;
	filter: blur(1vw);
	opacity: 0.2;
}

#horizon-menu .item.active::after {
	display: block;
	content: ' ';
	position: absolute;
	top: 20%;
	bottom: 40%;
	left: 0.1vw;
	right: 0.1vw;
	background: #]]..secondaryColor..[[aa;
	z-index: -50;
	filter: blur(0.2vw);
	opacity: 0.3;
}
#horizon-menu .item.locked {
	padding-left: 0.4vw;
}
#horizon-menu .item.locked::before {
	display: block;
	content: ' ';
	position: absolute;
	top: 15%;
	bottom: 15%;
	left: 0.1vw;
	right: 0.1vw;
	background: #]]..primaryColor..[[aa;
	z-index: -50;
	filter: blur(1vw);
	opacity: 0.2;
}
#horizon-menu .item.locked::after {
	display: block;
	content: ' ';
	position: absolute;
	top: 20%;
	bottom: 40%;
	left: 0.1vw;
	right: 0.1vw;
	background: #]]..primaryColor..[[aa;
	z-index: -50;
	filter: blur(0.2vw);
	opacity: 0.6;
}

#horizon-menu::after {
	content: ' ';
	filter: blur(1vw);
	display: block;
	border-top-left-radius: 1vw;
	border-top-right-radius: 1vw;
	border-image: linear-gradient(to bottom, #]]..primaryColor..[[ff, #]]..primaryColor..[[00) 1 100%;
	background: linear-gradient(to bottom, rgba(0,0,0,0.65) 50%,rgba(0,0,0,0) 100%);
	position: absolute;
	top: 0;
	bottom: 0;
	left: 0;
	right: 0;
	z-index: -99;
}

#horizon-menu::before {
	content: ' ';
	filter: blur(0.05vw);
	display: block;
	border-top-left-radius: 1vw;
	border-top-right-radius: 1vw;
	border-top: 0.25vw solid #]]..primaryColor..[[;
	border-left: 0.25vw solid #]]..primaryColor..[[;
	border-right: 0.25vw solid #]]..primaryColor..[[;
	border-image: linear-gradient(to bottom, #]]..primaryColor..[[ff, #]]..primaryColor..[[00) 1 100%;
	background: radial-gradient(ellipse at top, rgba(0,0,0,0.65) 0%,rgba(0,0,0,0) 100%);
	position: absolute;
	top: 0;
	bottom: 0;
	left: 0;
	right: 0;
	z-index: -100;
}

/* ORE TRILATERATE STYLE */

p {	/*color:#eca943;*/
	font-size:100%;
}

.block {
	border: 1px solid DimGray;
	border-radius:10px;
	background-color: rgba(0,0,0,.5)
}

#main_block{
	text-align: center;
	padding: 10px 10px 10px 10px;
}

#help_block{
	text-align: left;
	padding: 10px 10px 10px 10px;
	width: 320px;
}

#pause_block{
	text-align: center;
	font-size:90%;
}

#panel_left {
	position: absolute;
	top: 0%;
	left: 0%;
	/*width: 310px;*/
}
#slider_header {
	position: absolute;
	top: 0vh;
	font-size:110%;
	width: 100%;
	text-align: center;
}

#slider_main {
	position: relative;
	font-size:105%;
	color:#eca943;
	/*left: -51%;/*0%*/*/
}

#slider_footer{
	position: relative;
	font-size:120%;
	top:80%;
	left:10%;
}

#panel_slider {
	position: absolute;
	top: 54.5vh; ;
	left: 66.8vw;/*66.8vw;*/
	width: 9vw;/*9vw;*/
	height: 28.5vh;
	transform: skew(15.85deg); /*15.85deg*/
	border-bottom: 28.5vh solid rgba(0,0,0,.25);
	border-right: 1vw solid transparent;
	/*background-color:rgba(0,0,0,.75)*/
}

#panel_test {
	position: fixed;
	top: 100px; /* or whatever top you need */
	left: 50%;
	width: auto;
	-webkit-transform: translateX(-50%);
	-moz-transform: translateX(-50%);
	-ms-transform: translateX(-50%);
	-o-transform: translateX(-50%);
	transform: translateX(-50%);
}

.shadow {
	-webkit-filter: drop-shadow( 3px 3px 2px rgba(0, 0, 0, .7));
	filter: drop-shadow( 3px 3px 2px rgba(0, 0, 0, .7));
}
]]

--system.print([[Shadow Templar Mining Chair H1R3<style>#custom_screen_click_layer{ display: none !important; }</style>]])