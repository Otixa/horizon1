--@class CSS_SHUD
displaySize = 0.65
--primaryColor = "0faea9" --export: Primary color of HUD
--secondaryColor = "0247b5" --export: Secondary color of HUD
--textShadow = "d9ff00" --export: Color of text shadow for speedometer
primaryColor = "b80000" --export: Primary color of HUD
secondaryColor = "e30000" --export: Secondary color of HUD
textShadow = "e81313" --export: Color of text shadow for speedometer
CSS_SHUD = [[
#horizon { 
  left: 0;
  top: 0;
  position: fixed;
  width: 100vw;
  height: 100vh;
  background: radial-gradient(ellipse 27vw 11vw at 50% 51vw, rgba(1,5,8,0.6) 50%,rgba(1,5,8,0) 90%);
  font-family: Verdana;
  
}
#artificialHorizon
{
  position: absolute;
  display: block;
  left: 50%;
  top: 50%;
  height: 50vw;
  width: 50vw;
  transform: translate(-50%, -50%);
  filter: drop-shadow(0px 3px 4px #000000);
}

#artificialHorizon > svg {
  width: 100%;
}

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
  font-family: 'Verdana';
  font-weight: normal;
  font-style: normal;
  position: fixed;
  left: 50%;
  bottom: 13vh;
  font-size: 2vw;
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
  font-size: 2vw;
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
  bottom: -4.3vh;
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
  background: url('data:image/png;base64,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');
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

#fuelTanks {
  position: absolute;
  top: 2%;
  left: 2%;
  width: 12vw;

  color: #1b1b1b;
  font-family: Verdana;
  font-size: 0.8vh;
  text-align: center;
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


]]
--system.print([[Shadow Templar Mining Chair H1R3<style>#custom_screen_click_layer{ display: none !important; }</style>]])