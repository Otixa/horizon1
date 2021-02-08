--@class CSS_SHUD
CSS_SHUD = [[
#horizon { 
  left: 0;
  top: 0;
  position: fixed;
  width: 100vw;
  height: 100vh;

  font-family: Montserrat;
}

#speedometer::before {
  display: block;
  position: absolute;
  content: ' ';
  top: 0.15vh;
  bottom: -17vh;
  left: 50%;
  width: 31vw;
  
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
  
  filter: blur(0.1vw);
}

#speedometer {
  font-family: 'Montserrat';
  font-weight: normal;
  font-style: normal;
  position: fixed;
  left: 50%;
  bottom: 13vh;
  font-size: 3vw;
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
  text-shadow: 0 0 0.75vw #ed1c24;
  padding: 0;
  margin: 0;
  font-size: 3vw;
}

#speedometer .display .minor, #speedometer .unit {
  position: relative;
  left: -0.5em;
  vertical-align: super;
  font-size: 50%;
}

#speedometer .unit {
  vertical-align: 50%;
  font-size: 33%;
  bottom: -2vh;
  left: -1.33em;
}

#speedometer .accel {
  font-size: 1.6vw;
  text-shadow: 0 0 0.15vw #000000;
  position: absolute;
  left: 12.5%;
  bottom: -2vh;
  opacity: 0.75;
}

#speedometer .accel .major::before {
  content: 'Δ';
  font-size: 1.5vh;
}

#speedometer .accel .unit {
  left: -0.66em;
}

#speedometer .alt {
  position: absolute;
  left: 50%;
  bottom: -0.65vh;
  transform: translateX(-50%);
  font-size: 0.75vh;
  text-align: center;
}

#speedometer .misc {
  position: absolute;
  left: 50%;
  bottom: -1.9vh;
  transform: translateX(-50%);
  font-size: 0.5vw;
  text-align: center;
}

#speedometer .throttle {
  position: absolute;
  left: 50%;
  bottom: -4.3vh;
  transform: translateX(-50%);
  font-size: 0.9vw;
  text-align: center;
}

#speedometer .vertical {
  font-size: 1.6vw;
  text-shadow: 0 0 0.15vw #000000;
  position: absolute;
  right: 12.5%;
  bottom: -2vh;
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
  font-family: 'Montserrat';
  font-size: 0.85vw;
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
#horizon-menu .item.active {
  position: relative;
  text-shadow: 0 0 0.75vw #ed1c24;
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
  background: #ed1c24aa;
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
  background: #ed1c24aa;
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
  background: #0faea9aa;
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
  background: #0faea9aa;
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
  border-image: linear-gradient(to bottom, #0faea9ff, #0faea900) 1 100%;
  
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
  border-top: 0.25vw solid #0faea9;
  border-left: 0.25vw solid #0faea9;
  border-right: 0.25vw solid #0faea9;
  border-image: linear-gradient(to bottom, #0faea9ff, #0faea900) 1 100%;
  
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: -100;
}
]]




