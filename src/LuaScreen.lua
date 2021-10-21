--@class LuaScreen
local rslib = require('rslib')
local utils = require('cpml/utils')
local concat = table.concat
local sFormat = string.format
local function internalSerialize(v,tC,t) local check = type(v) local intSerial=internalSerialize if check=='table' then t[tC]='{' local tempC=tC+1 if #v==0 then for k,e in pairs(v) do if type(k)~='number' then t[tempC]=k t[tempC+1]='=' tempC=tempC+2 else t[tempC]='[' t[tempC+1]=k t[tempC+2]=']=' tempC=tempC+3 end tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end else for k,e in pairs(v) do tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end end if tempC==(tC+1) then t[tempC]='}' return tempC+1 else t[tempC-1]='}' return tempC end elseif check=='string' then t[tC]=sFormat("%q",v) return tC+1 elseif check=='number' then t[tC]=tostring(v) return tC+1 else t[tC]=v and 'true' or 'false' return tC+1 end end 
function serialize(v) local t={} local tC=1 local check = type(v) local intSerial=internalSerialize if check=='table' then t[tC]='{' tC=tC+1 local tempC=tC if #v==0 then for k,e in pairs(v) do if type(k)~='number' then t[tempC]=k t[tempC+1]='=' tempC=tempC+2 else t[tempC]='[' t[tempC+1]=k t[tempC+2]=']=' tempC=tempC+3 end tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end else for k,e in pairs(v) do tempC=intSerial(e,tempC,t) t[tempC]=',' tempC=tempC+1 end end if tempC==tC then t[tempC]='}' else t[tempC-1]='}' end elseif check=='string' then t[tC]=sFormat("%q",v) elseif check=='number' then t[tC]=tostring(v) else t[tC]=v and 'true' or 'false' end return concat(t) end
function deserialize(s) local f=load('t='..s) f() return t end
function spairs(a,b)local c={}for d in pairs(a)do c[#c+1]=d end;if b then table.sort(c,function(e,f)return b(a,e,f)end)else table.sort(c)end;local g=0;return function()g=g+1;if c[g]then return c[g],a[c[g]]end end end

function mToKm(n)
    if n >= 1000 then
        return utils.round((n / 1000),3) .. " km"
    else
        return utils.round(n,2) .. " m"
    end
end
local stLogo = loadImage("assets.prod.novaquark.com/31879/70c4eeac-9aad-4fce-952f-db5dac287832.png")
font = loadFont('Play-Bold', 32)
font2 = loadFont('Montserrat', 12)
font3 = loadFont('Montserrat', 20)


rx, ry = getResolution()
cx, cy = getCursor()
layer0 = createLayer()
layer = createLayer()
layer2 = createLayer()

click = getCursorPressed()

-- Background
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


local input = getInput()
local elevData = deserialize(getInput())

-- Elevator animation box
local boxHeight = utils.map(elevData.stats.elevation,0,elevData.floors.floor1,ry - 80,100)
setNextFillColor(layer2, 0.2, 0.2, 0.2, 1)
setNextStrokeColor(layer2, 0.3, 0.0, 0.0, 1)
setNextStrokeWidth(layer2, 2)
addBoxRounded(layer2,rx/2 - 40,boxHeight,80,30,5)

-- Elevator animation line
addText(layer,font2,"Input Length: "..input:len(),25,ry-50)
addText(layer,font2,"Fuel Length: "..serialize(elevData.fuel):len(),25,ry-65)
addLine(layer,rx/2,100,rx/2,ry - 50)
addLine(layer,rx/2-20,100,rx/2+20,100)
addLine(layer,rx/2-20,ry - 50,rx/2+20,ry - 50)





if not Button then
    local mt = {}
    mt.__index = mt
    function Button (text, x, y, value)
        return setmetatable({
            text = text,
            x = x,
            y = y,
            value = value,
        }, mt)
    end

    function mt:draw ()
        local sx, sy = rx/8+10, 40 --self:getSize()
        local x0 = self.x - sx/2
        local y0 = self.y - sy/2
        local x1 = x0 + sx
        local y1 = y0 + sy
        
        local r, g, b = 0.3, 0.7, 1.0
        local fr, fg, fb = 0.1, 0.1, 0.1
        if cx >= x0 and cx <= x1 and cy >= y0 and cy <= y1 then
            r, g, b = 0.4, 0.9, 1.0
            fr, fg, fb = 0.3, 0.3, 0.3
            if click then setOutput(self.value) end
        end
        
        --setNextShadow(layer, 64, r, g, b, 0.3)
        setNextFillColor(layer, fr, fg, fb, 1)
        setNextStrokeColor(layer, r, g, b, 1)
        setNextStrokeWidth(layer, 2)
        addBoxRounded(layer, self.x - sx/2, self.y - sy/2, sx, sy, 4)
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
        setNextStrokeWidth(layer, 2)
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
local buttons = {
    Button('RTB',   rx/8 - padding, ry/2,   'rtb'),
    Button('+10',   rx/8 - padding, ry/2 + 50,         '+10'),
    Button('-10',   rx/8 - padding, ry/2 + 100,    '-10'),
}

local spacing = 0
for k, v in spairs(elevData.floors) do
    local button = Button(mToKm(v), rx/4 + padding, ry/2 + spacing,       v)
    table.insert(buttons,button)
    spacing = spacing + 50
end

-- STATS

local statSpacing = 0
for k,v in spairs(elevData.stats) do
    local lCol = rx/1.8+ 60
    local rCol = rx/1.8+260
    local row = ry/4.5+statSpacing
    addText(layer,font3,k..":",lCol,row) addText(layer,font3,v,rCol,row)
    statSpacing = statSpacing + 20
end

-- FUEL TANKS

statSpacing = 0
local fuelAtmo = {}
local fuelSpace = {}
if elevData.fuel ~= nil then
    local aSpacing = spacing
    local sSpacing = spacing
    for k,v in spairs(elevData.fuel) do
        if v.ft == "atmo" then
            local fg = FuelGauge("", rx/1.8+110, 115 + aSpacing, v.ft, v.tm, v.pct)
            table.insert( fuelAtmo, fg )
            aSpacing = aSpacing + 24
        end
        if v.ft == "space" then
            local fg = FuelGauge("", rx/1.8+310, 115 + sSpacing, v.ft, v.tm, v.pct)
            table.insert( fuelAtmo, fg )
            sSpacing = sSpacing + 24
        end
    end
end
drawFree(buttons)
drawFree(fuelAtmo)

drawUsage()

rslib.drawRenderCost()
requestAnimationFrame(1)