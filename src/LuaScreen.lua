--@class LuaScreen
local rslib = require('rslib')
local utils = require('cpml/utils')
local concat = table.concat
local sFormat = string.format
-- Libs and helper functions
local function internalSerialize(v,tC,t) local check = type(v) local intSerial=internalSerialize if check=='table' then t[tC]='{' local tempC=tC+1 if #v==0 then for k,e in pairs(v) do if type(k)~='number' then t[tempC]=k t[tempC+1]='=' tempC=tempC+2 else t[tempC]='[' t[tempC+1]=k t[tempC+2]=']=' tempC=tempC+3 end tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end else for k,e in pairs(v) do tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end end if tempC==(tC+1) then t[tempC]='}' return tempC+1 else t[tempC-1]='}' return tempC end elseif check=='string' then t[tC]=sFormat("%q",v) return tC+1 elseif check=='number' then t[tC]=tostring(v) return tC+1 else t[tC]=v and 'true' or 'false' return tC+1 end end 
function serialize(v) local t={} local tC=1 local check = type(v) local intSerial=internalSerialize if check=='table' then t[tC]='{' tC=tC+1 local tempC=tC if #v==0 then for k,e in pairs(v) do if type(k)~='number' then t[tempC]=k t[tempC+1]='=' tempC=tempC+2 else t[tempC]='[' t[tempC+1]=k t[tempC+2]=']=' tempC=tempC+3 end tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end else for k,e in pairs(v) do tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end end if tempC==tC then t[tempC]='}' else t[tempC-1]='}' end elseif check=='string' then t[tC]=sFormat("%q",v) elseif check=='number' then t[tC]=tostring(v) else t[tC]=v and 'true' or 'false' end return concat(t) end
function deserialize(s) local f=load('t='..s) f() return t end
function spairs(a,b)local c={}for d in pairs(a)do c[#c+1]=d end;if b then table.sort(c,function(e,f)return b(a,e,f)end)else table.sort(c)end;local g=0;return function()g=g+1;if c[g]then return c[g],a[c[g]]end end end
function tablelength(T) local count = 0 for _ in pairs(T) do count = count + 1 end return count end
function convertFromHex(a)if a:sub(1,1)=="#"then a=a:sub(2,-1)end;if#a==8 then return tonumber("0x"..a:sub(1,2))/255,tonumber("0x"..a:sub(3,4))/255,tonumber("0x"..a:sub(5,6))/255,tonumber("0x"..a:sub(7,8))/255 elseif#a==6 then return tonumber("0x"..a:sub(1,2))/255,tonumber("0x"..a:sub(3,4))/255,tonumber("0x"..a:sub(5,6))/255,1 elseif#a==3 then return tonumber("0x"..a:sub(1,1))/15,tonumber("0x"..a:sub(2,2))/15,tonumber("0x"..a:sub(3,3))/15,1 else return 1,1,1,1 end end
function mToKm(n) if n >= 1000 then return utils.round((n / 1000),3) .. " km" else return utils.round(n,2) .. " m" end end

local stLogo = loadImage("assets.prod.novaquark.com/31879/70c4eeac-9aad-4fce-952f-db5dac287832.png")

font = loadFont('Play-Bold', 22)
font2 = loadFont('Montserrat-Light', 12)
font3 = loadFont('Montserrat', 20)
rx, ry = getResolution()
cx, cy = getCursor()
layer0 = createLayer()
layer1 = createLayer()
layer = createLayer()
layer2 = createLayer()

click = getCursorPressed()

-- Background
---- x axis
--for i = 0,rx,25 do
--    setNextStrokeColor(layer, 1, 1, 1, 0.2)
--    addLine(layer,i,0,i,ry)
--    addText(layer,font,i,i + 5,15)
--end
---- y axis
--for i = 0,ry,25 do
--    setNextStrokeColor(layer, 1, 1, 1, 0.2)
--    addLine(layer,0,i,rx,i)
--    addText(layer,font,i,5,i - 5)
--end
if not stars then stars = {} end
if not CreateStar then
    local mt = {}
    mt.__index = mt
    function CreateStar()
        return setmetatable({
            starSize = math.random(1,20) * 0.1,
            starOpacity = math.random(1,5) * 0.1,
            starXPos = math.random(1,rx),
            starYPos = math.random(1,ry)
        },mt)
    end
    
    function mt:draw()
        setNextStrokeWidth(layer1, 0) 
        setNextFillColor(layer1, 1, 1, 1, self.starOpacity)
        addCircle(layer1, self.starXPos, self.starYPos, self.starSize)
        --logMessage("Star opacity: "..self.starOpacity)
    end
end

function generateStars()
   for i = 1, 750, 1 do
    table.insert(stars,CreateStar())
    end 
end

--if tablelength(stars) == 0 then generateStars() end

local bgHeight = ry/2+160
local bgWidth = rx/2-60
setNextFillColor(layer0, 0.1, 0.1, 0.1, 0.8)
setNextStrokeColor(layer0, 1, 1, 1, 0.6)
setNextStrokeWidth(layer0, 2)
addBoxRounded(layer0,20,ry/6,bgWidth,bgHeight,20)
setNextFillColor(layer0, 0.1, 0.1, 0.1, 0.8)
setNextStrokeColor(layer0, 1, 1, 1, 0.6)
setNextStrokeWidth(layer0, 2)
addBoxRounded(layer0,rx - (rx/2-40),ry/6,bgWidth,bgHeight,20)
addImage(layer0, stLogo, rx - (rx/2-40),ry/6 + 30,rx/2-60,ry/2+100)

-- Input Routing
local tmp = nil
local tmpData = nil
local fix = { dataType = "stats", data = { elevation = 100294.4919, target = 0, velocity = 2945, mass = 332959, gravity = 9.89, target_dist = 100000, brake_dist = 4892, deviation = 17.299003983, state = "Idle", } }
tmp = getInput()

if tmp ~= nil and tmp ~= "" then tmpData = deserialize(tmp) or {}; else setOutput("ack") end
--logMessage("Data Type: "..tmpData.dataType)

if not stats then stats = {} end
if not config then config = {} end
if not fuelAtmo then fuelAtmo = {} end
if not fuelSpace then fuelSpace = {} end
if tmpData ~= nil and type(tmpData) == "table" then
    if tmpData.dataType == "stats" then
        stats = tmpData
        setOutput("ack")
    elseif tmpData.dataType == "config" then
        config = tmpData
        setOutput("ack")
    elseif tmpData.dataType == "fuelAtmo" then
        fuelAtmo = tmpData
        setOutput("ack")
    elseif tmpData.dataType == "fuelSpace" then
        fuelSpace = tmpData
        setOutput("ack")
    end
else
    logMessage("tmpData is nil or not a table.")
end
-- Elevator animation box
if stats.data ~= nil and config.floors ~= nil then
    local boxHeight = utils.map(stats.data.elevation or 0,0,config.floors.floor1,ry - 80,100)
    setNextFillColor(layer2, 0.2, 0.2, 0.2, 1)
    setNextStrokeColor(layer2, 0.3, 0.0, 0.0, 1)
    setNextStrokeWidth(layer2, 2)
    addBoxRounded(layer2,rx/2 - 40,boxHeight,80,30,5)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    addText(layer2,font3,mToKm(tonumber(stats.data.elevation)),rx/2 - 38,boxHeight + 20,80,30)
end
-- Elevator animation line
if tmp ~= nil then addText(layer,font2,"Input Length: "..tmp:len(),95,ry-50) end
if fuelAtmo ~= nil then
addText(layer,font2,"Fuel Length: "..serialize(fuelAtmo):len(),45,ry-65)
addLine(layer,rx/2,100,rx/2,ry - 50)
addLine(layer,rx/2-20,100,rx/2+20,100)
addLine(layer,rx/2-20,ry - 50,rx/2+20,ry - 50)
end

--logMessage("Number of tanks: "..tablelength(fuelAtmo.tanks))


if not EStopButton then
    
    local mt = {}
    mt.__index = mt
    function EStopButton (text1, text2, x, y, width, height, color, action)
        return setmetatable({
            text1 = text1,
            text2 = text2,
            x = x,
            y = y,
            width = width,
            height = height,
            color = color,
            action = action,
             
        }, mt)
    end

    function mt:draw ()
        local esFont = loadFont('Play-Bold', 32)
        local sx, sy = self.width, self.height --self:getSize()
        local x0 = self.x - sx/2
        local y0 = self.y - sy/2
        local x1 = x0 + sx
        local y1 = y0 + sy
        
        local r, g, b = 0.7, 0.7, 0.7
        local cr, cg, cb, ca
        if self.color ~= nil then
            cr, cg, cb, ca = convertFromHex(self.color)
        else
            cr, cg, cb, ca = 0.1, 0.1, 0.1, 1
        end
        if cx >= x0 and cx <= x1 and cy >= y0 and cy <= y1 then
            --r, g, b = 1.0, 0.0, 0.1
            cr = cr + 0.1
            cg = cg + 0.1
            cb = cb + 0.1
            if click then
                cr = cr + 0.1
                cg = cg + 0.1
                cb = cb + 0.1
                if click then 
                    if type(self.action) == "function" then
                       self.action() 
                    end
                end
                --Click action
            end
        end
        
        --setNextShadow(layer, 64, r, g, b, 0.3)
        setNextFillColor(layer, cr, cg, cb, ca)
        setNextStrokeColor(layer, r, g, b, 1)
        setNextStrokeWidth(layer, 2)
        addBoxRounded(layer, self.x - sx/2, self.y - sy/2, sx, sy, sx * 0.1)
        setNextFillColor(layer, 1, 1, 1, 1)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        addText(layer, esFont, self.text1, self.x, self.y - 20)
        setNextFillColor(layer, 1, 1, 1, 1)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        addText(layer, esFont, self.text2, self.x, self.y + 20) 
    end

    function mt:getSize ()
        local sx, sy = getTextBounds(esFont, self.text1)
        return sx + 32, sy + 16
    end

    function mt:setPos (x, y)
        self.x, self.y = x, y
    end
end
if not ButtonQuad then
    local mt = {}
    mt.__index = mt
    function ButtonQuad (text, x, y, action, flip, color)
        return setmetatable({
            text = text,
            x = x,
            y = y,
            action = action,
            color = color,
            flip = flip
        }, mt)
    end

    function mt:draw ()
        local sx, sy = 180, 40--self:getSize()
        local x0 = self.x - sx/2
        local y0 = self.y - sy/2
        local x1 = x0 + sx
        local y1 = y0 + sy
        
        local r, g, b = 0.7, 0.7, 0.7
        local cr, cg, cb, ca
        if self.color ~= nil then
            cr, cg, cb, ca = convertFromHex(self.color)
        else
            cr, cg, cb, ca = 0.1, 0.1, 0.1, 1
        end
        if cx >= x0 and cx <= x1 and cy >= y0 and cy <= y1 then
            --r, g, b = 1.0, 0.0, 0.1
            cr = cr + 0.1
            cg = cg + 0.1
            cb = cb + 0.1
            if click then
                cr = cr + 0.1
                cg = cg + 0.1
                cb = cb + 0.1
                if click then
                    if type(self.action) == "function" then
                        self.action()
                    end
                     
                end
                --Click action
            end
        end
        setNextFillColor(layer, cr, cg, cb, ca)
        setNextStrokeColor(layer, r, g, b, 1)
        setNextStrokeWidth(layer, 2)
        --Button Shape
        if not self.flip then
            addQuad(layer,
                self.x - sx/2, self.y - sy/2, --(x1,y1)
                self.x - sx/2, self.y + sy/2, --(x2,y2)
                self.x + sx/2, self.y + sy/2, --(x3,y3)
                self.x + sx/2 + 30, self.y - sy/2) --(x4,y4)
        else
            addQuad(layer,
                self.x - sx/2, self.y - sy/2, --(x1,y1)
                self.x - sx/2 - 30, self.y + sy/2, --(x2,y2)
                self.x + sx/2, self.y + sy/2, --(x3,y3)
                self.x + sx/2, self.y - sy/2) --(x4,y4)
        end
        setNextFillColor(layer, 1, 1, 1, 1)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        addText(layer, font, self.text, self.x, self.y)
    end

    function mt:getSize ()
        local sx, sy = getTextBounds(font, self.text)
        return sx + 32, sy + 16
    end

    function mt:setPos (x, y)
        self.x, self.y = x, y
    end
end
if not FuelGauge then
    local mt = {}
    mt.__index = mt
    function FuelGauge (text, x, y, ft, tm, pct)
        return setmetatable({
            text = text,
            x = x,
            y = y,
            ft = ft,
            tm = tm,
            pct = pct
        }, mt)
    end

    function mt:draw ()
        local sx, sy = rx/8+50, 17 --self:getSize()
        
        --container
        setNextFillColor(layer, 0.4, 0.4, 0.4, 0.8)
        setNextStrokeColor(layer, 0.2, 0.2, 0.2, 0.8)
        setNextStrokeWidth(layer, 1)
        addBoxRounded(layer, self.x - sx/2, self.y - sy/2, sx, sy, 3)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        setNextFillColor(layer, 0, 0, 0, 1)
        addText(layer, font2, self.ft.." ("..self.pct.."%)", self.x, self.y)
        --fill
        local fr,fg,fb
        
		if self.ft == "atmo" then
			--setNextFillColor(layer, 0.1137, 0.8196, 0.9764, 1)
            fr = 0.1137
            fg = 0.8196
            fb = 0.9764
		elseif self.ft == "space" then
			--setNextFillColor(layer, 0.0980, 0.7647, 0.1176, 1)
            fr = 0.9803
            fg = 0.7647
            fb = 0.1176
		end
        setNextFillColor(layer, fr, fg, fb, 0.8)
        local fWidth = utils.map(self.pct,0,100,0,sx)
        addBoxRounded(layer, self.x - sx/2, self.y - sy/2, fWidth, sy, 3)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        
    end

    --function mt:getSize ()
    --    local sx, sy = getTextBounds(font2, self.ft.." ("..self.pct..")")
    --    return sx + 32, sy + 16
    --end

    function mt:setPos (x, y)
        self.x, self.y = x, y
    end
end

function drawFree (elems)
    for i, v in ipairs(elems) do v:draw() end
end

function drawListV (elems, x, y)
    for i, v in ipairs(elems) do
        local sx, sy = v:getSize()
        v:setPos(x, y)
        v:draw()
        y = y + sy + 4
    end
end

function drawUsage ()
    local font = loadFont('FiraMono-Bold', 46)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, font, "Caterpillar Test Screen", rx/2, 32)
end

--------------------------------------------------------------------------------

-- BUTTONS

local padding = 10
local mcColor = '#4e025c'
local eStopColor = '#7a0101'
if config.manualControl then mcColor = '#3c00b3' end
if config.estop then eStopColor = '#b30000' end
local buttons = {
    ButtonQuad('RTB',             135, 135, 'rtb',false,'#006603'),
    ButtonQuad('+10m',            135, 185, function() config.targetAlt = config.targetAlt + 10; setOutput(serialize(config)) end,false,'#0b0578'),
    ButtonQuad('-10m',            135, 235, function() config.targetAlt = config.targetAlt - 10; setOutput(serialize(config)) end,false,'#0b0578'),
    ButtonQuad('Manual Control',  135, 285, function() config.manualControl = not config.manualControl; setOutput(serialize(config)) end,false,mcColor),
    EStopButton('Emergency', 'Stop', 135, 410, 185, 165, eStopColor, function() config.estop = not config.estop; setOutput(serialize(config)) end)
}
setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
setNextStrokeColor(layer, 0.7, 0.7, 0.7, 1)
setNextStrokeWidth(layer, 2)
addBoxRounded(layer, 265, 325, 185, 165, 20)
--logMessage(stats.data.target)
local spacing = 0
--Floors
if config.floors ~= nil then
    for k, v in spairs(config.floors) do
        local color = "#450101"
        --logMessage(v.." / "..stats.data.target)
        if tostring(v) == tostring(config.targetAlt) then
            color = "#7a3907" 
        end
        local button = ButtonQuad(mToKm(v), 360, 135+spacing, function() config.targetAlt = v; setOutput(serialize(config)) end,true,color)
        table.insert(buttons,button)
        spacing = spacing + 50
    end
end
-- STATS

local statSpacing = 0
if stats.data ~= nil then
    for k,v in spairs(stats.data) do
        local lCol = rx/1.8+ 60
        local rCol = rx/1.8+260
        local row = ry/4.5+statSpacing
        addText(layer,font3,k..":",lCol,row) addText(layer,font3,v,rCol,row)
        statSpacing = statSpacing + 20
    end
end
-- FUEL TANKS

--statSpacing = 0
local fgAtmo = {}
local fgSpace = {}
if fuelAtmo.tanks ~= nil then
    local aSpacing = 200-- = spacing
    
    for k,v in spairs(fuelAtmo.tanks) do
        if v.ft == "atmo" then
            local fg = FuelGauge("", rx/1.8+110, 115 + aSpacing, v.ft, v.tm, v.pct)
            table.insert( fgAtmo, fg )
            aSpacing = aSpacing + 22
        end
    end
end
if fuelSpace.tanks ~= nil then
    local sSpacing = 200
	for k,v in spairs(fuelSpace.tanks) do
		if v.ft == "space" then
            local fg = FuelGauge("", rx/1.8+310, 115 + sSpacing, v.ft, v.tm, v.pct)
            table.insert( fgSpace, fg )
            sSpacing = sSpacing + 22
        end
	end
end
drawFree(stars)
drawFree(buttons)
drawFree(fgAtmo)
drawFree(fgSpace)

drawUsage()

rslib.drawRenderCost()
requestAnimationFrame(1)
--if tmp ~= nil and tmp ~= "" then setOutput("ack") end