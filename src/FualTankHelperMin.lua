--@class FuelTankHelperMin
local ContainerOptimization = 5 --export: Container ContainerOptimization
local FuelTankOptimization = 5 --export: Fuel Tank FuelTankOptimization
local fuelTankHandlingAtmo = 5 --export: Fuel Tank Handling Atmo
local fuelTankHandlingSpace = 5 --export: Fuel Tank Handling Space
fuelTanks={}FuelMass={}FuelTime={}fuelTypes={atmo={density=4.000},space={density=6.000},rocket={density=0.800}}local function a(b)if fuelTankHandlingAtmo>0 then return b+b*fuelTankHandlingAtmo*0.2 else return b end end;local function c(b)if fuelTankHandlingSpace>0 then return b+b*fuelTankHandlingSpace*0.2 else return b end end;local function d(e,f)local g=e*fuelTypes[f].density;local h=g;if ContainerOptimization>0 then h=g-g*ContainerOptimization*0.05 end;if FuelTankOptimization>0 then h=h-g*FuelTankOptimization*0.05 end;return h end;fuelTankSpecsByMaxHP={atmo={_50={type="atmo",size="XS",capacity=function()return a(100)end,baseWeight=35.030,maxWeight=function()return d(a(100),"atmo")end},_163={type="atmo",size="S",capacity=function()return a(400)end,baseWeight=182.670,maxWeight=function()return d(a(400),"atmo")end},_1315={type="atmo",size="M",capacity=function()return a(1600)end,baseWeight=988.670,maxWeight=function()return d(a(1600),"atmo")end},_10461={type="atmo",size="L",capacity=function()return a(12800)end,baseWeight=5480.000,maxWeight=function()return d(a(12800),"atmo")end}},space={_187={type="space",size="S",capacity=function()return c(400)end,baseWeight=182.670,maxWeight=function()return d(a(400),"space")end},_1496={type="space",size="M",capacity=function()return c(1600)end,baseWeight=988.670,maxWeight=function()return d(a(1600),"space")end},_15933={type="space",size="L",capacity=function()return c(12800)end,baseWeight=5480.000,maxWeight=function()return d(a(12800),"space")end}},rocket={_366={type="rocket",size="XS",capacity=function()return 400 end,baseWeight=173.420,maxWeight=function()return d(a(400),"rocket")end},_736={type="rocket",size="S",capacity=function()return 800 end,baseWeight=886.720,maxWeight=function()return d(a(800),"rocket")end},_6231={type="rocket",size="M",capacity=function()return 6400 end,baseWeight=4720.000,maxWeight=function()return d(a(6400),"rocket")end},_68824={type="rocket",size="L",capacity=function()return 50000 end,baseWeight=25740.000,maxWeight=function()return d(a(50000),"rocket")end}}}local function i(j)return j==math.huge or j==-math.huge end;local function k(j)return j~=j end;function disp_time(l)if i(l)or k(l)then return"inf"end;local m=math.floor(l/86400)local n=math.floor(math.fmod(l,86400)/3600)local o=math.floor(math.fmod(l,3600)/60)local p=math.floor(math.fmod(l,60))if l>=86400 then return string.format("%dd:%02dh",m,n)elseif l<86400 and l>3600 then return string.format("%02dh:%02dm:%02ds",n,o,p)elseif l<3600 and l>60 then return string.format("%02dm:%02ds",o,p)else return string.format("%02ds",p)end end;local q=table.unpack;function fuelUsed(r)local s={}function sum(t,...)if t then return t-sum(...)else return 0 end end;function average(u)if#s==r then table.remove(s,1)end;if u~=0 and u~=nil then s[#s+1]=u end;return sum(q(s))end;return average end;function getFuelSituation()local v={atmo={},space={},rocket={}}for w,x in pairs(fuelTanks)do table.insert(v[x.type],{name=core.getElementNameById(w),level=getFuelTankLevel(w),time=getFuelTime(w),specs=x})end;return v end;function getFuelTankSpecs(y,z)local A=math.floor(core.getElementMaxHitPointsById(z))return fuelTankSpecsByMaxHP[y]['_'..A]end;function getFuelTankLiters(z)local B=fuelTanks[z]local C=core.getElementMassById(z)local D=C-B.baseWeight;return D end;function getFuelTankLevel(z)local B=fuelTanks[z]local h=B.maxWeight()return getFuelTankLiters(z)/h end;function getFuelTime(z)local B=fuelTanks[z]local E=FuelTime[z]or system.getTime()local F=math.max(system.getTime()-E,0.001)local C=core.getElementMassById(z)local G=B.baseWeight;local fuelUsed=FuelMass[z](C)local H=F/fuelUsed*(C-G)local I=disp_time(H)FuelTime[z]=system.getTime()return I end;function getFuelTanks()for J,K in ipairs(fuelTankSpecsByMaxHP)do system.print("V: "..K)for L,s in ipairs(K)do for M,N in pairs(s)do system.print("Capacity: "..N.capacity())end end end;local O=core.getElementIdList()for L,P in pairs(O)do local Q=core.getElementTypeById(P)if Q=="Atmospheric Fuel Tank"then fuelTanks[P]=getFuelTankSpecs("atmo",P)FuelMass[P]=fuelUsed(2)elseif Q=="Space Fuel Tank"then fuelTanks[P]=getFuelTankSpecs("space",P)FuelMass[P]=fuelUsed(2)elseif Q=="Rocket Fuel Tank"then fuelTanks[P]=getFuelTankSpecs("rocket",P)FuelMass[P]=fuelUsed(2)end end end;getFuelTanks()