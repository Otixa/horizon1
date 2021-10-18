--@class FuelTankHelperMin
local ContainerOptimization = 5 --export: Container ContainerOptimization
local FuelTankOptimization = 5 --export: Fuel Tank FuelTankOptimization
local fuelTankHandlingAtmo = 5 --export: Fuel Tank Handling Atmo
local fuelTankHandlingSpace = 5 --export: Fuel Tank Handling Space
fuelTanks={}FuelMass={}FuelTime={}fuelTypes={atmo={density=4.000},space={density=6.000},rocket={density=0.800}}local function a(b)if fuelTankHandlingAtmo>0 then return b+b*fuelTankHandlingAtmo*0.2 else return b end end;local function c(b)if fuelTankHandlingSpace>0 then return b+b*fuelTankHandlingSpace*0.2 else return b end end;local function d(e,f)local g=e*fuelTypes[f].density;local h=g;if ContainerOptimization>0 then h=g-g*ContainerOptimization*0.05 end;if FuelTankOptimization>0 then h=h-g*FuelTankOptimization*0.05 end;return h end;function normalizeHp(f,i)local j=0;if f=="atmo"then if i>=50 and i<163 then j=50 elseif i>=163 and i<1315 then j=163 elseif i>=1315 and i<10461 then j=1315 elseif i>=10461 then j=10461 end elseif f=="space"then if i>=187 and i<1496 then j=187 elseif i>=1496 and i<15933 then j=1496 elseif i>=15933 then j=10461 end elseif f=="rocket"then if i>=366 and i<736 then j=366 elseif i>=736 and i<6231 then j=736 elseif i>=6231 and i<68824 then j=6231 elseif i>=68824 then j=68824 end end;return j end;function normalizeHpAtmo(i)end;function normalizeHpSpace(i)end;function normalizeHpRocket(i)end;fuelTankSpecsByMaxHP={atmo={_50={type="atmo",size="XS",capacity=function()return a(100)end,baseWeight=35.030,maxWeight=function()return d(a(100),"atmo")end},_163={type="atmo",size="S",capacity=function()return a(400)end,baseWeight=182.670,maxWeight=function()return d(a(400),"atmo")end},_1315={type="atmo",size="M",capacity=function()return a(1600)end,baseWeight=988.670,maxWeight=function()return d(a(1600),"atmo")end},_10461={type="atmo",size="L",capacity=function()return a(12800)end,baseWeight=5480.000,maxWeight=function()return d(a(12800),"atmo")end}},space={_187={type="space",size="S",capacity=function()return c(400)end,baseWeight=182.670,maxWeight=function()return d(a(400),"space")end},_1496={type="space",size="M",capacity=function()return c(1600)end,baseWeight=988.670,maxWeight=function()return d(a(1600),"space")end},_15933={type="space",size="L",capacity=function()return c(12800)end,baseWeight=5480.000,maxWeight=function()return d(a(12800),"space")end}},rocket={_366={type="rocket",size="XS",capacity=function()return 400 end,baseWeight=173.420,maxWeight=function()return d(a(400),"rocket")end},_736={type="rocket",size="S",capacity=function()return 800 end,baseWeight=886.720,maxWeight=function()return d(a(800),"rocket")end},_6231={type="rocket",size="M",capacity=function()return 6400 end,baseWeight=4720.000,maxWeight=function()return d(a(6400),"rocket")end},_68824={type="rocket",size="L",capacity=function()return 50000 end,baseWeight=25740.000,maxWeight=function()return d(a(50000),"rocket")end}}}local function k(l)return l==math.huge or l==-math.huge end;local function m(l)return l~=l end;function disp_time(n)if k(n)or m(n)then return"inf"end;local o=math.floor(n/86400)local p=math.floor(math.fmod(n,86400)/3600)local q=math.floor(math.fmod(n,3600)/60)local r=math.floor(math.fmod(n,60))if n>=86400 then return string.format("%dd:%02dh",o,p)elseif n<86400 and n>3600 then return string.format("%02dh:%02dm:%02ds",p,q,r)elseif n<3600 and n>60 then return string.format("%02dm:%02ds",q,r)else return string.format("%02ds",r)end end;local s=table.unpack;function fuelUsed(t)local u={}function sum(v,...)if v then return v-sum(...)else return 0 end end;function average(w)if#u==t then table.remove(u,1)end;if w~=0 and w~=nil then u[#u+1]=w end;return sum(s(u))end;return average end;function getFuelSituation()local x={atmo={},space={},rocket={}}for y,z in pairs(fuelTanks)do table.insert(x[z.type],{name=core.getElementNameById(y),level=getFuelTankLevel(y),time=getFuelTime(y),specs=z})end;return x end;function getFuelTankSpecs(A,B)local C=math.floor(core.getElementMaxHitPointsById(B))return fuelTankSpecsByMaxHP[A]['_'..normalizeHp(A,C)]end;function getFuelTankLiters(B)local D=fuelTanks[B]local E=core.getElementMassById(B)local F=E-D.baseWeight;return F end;function getFuelTankLevel(B)local D=fuelTanks[B]local h=D.maxWeight()return getFuelTankLiters(B)/h end;function getFuelTime(B)local D=fuelTanks[B]local G=FuelTime[B]or system.getTime()local H=math.max(system.getTime()-G,0.001)local E=core.getElementMassById(B)local I=D.baseWeight;local fuelUsed=FuelMass[B](E)local J=H/fuelUsed*(E-I)local K=disp_time(J)FuelTime[B]=system.getTime()return K end;function getFuelTanks()local L=core.getElementIdList()for M,N in pairs(L)do local O=core.getElementTypeById(N)if O=="Atmospheric Fuel Tank"then local P=getFuelTankSpecs("atmo",N)fuelTanks[N]=P;FuelMass[N]=fuelUsed(2)elseif O=="Space Fuel Tank"then fuelTanks[N]=getFuelTankSpecs("space",N)FuelMass[N]=fuelUsed(2)elseif O=="Rocket Fuel Tank"then fuelTanks[N]=getFuelTankSpecs("rocket",N)FuelMass[N]=fuelUsed(2)end end;for Q,R in ipairs(fuelTankSpecsByMaxHP)do system.print("Fuel Tank: "..R)for M,u in ipairs(R)do for S,T in pairs(u)do system.print("Capacity: "..T.capacity())end end end end;getFuelTanks()