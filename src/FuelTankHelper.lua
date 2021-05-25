--@class FuelTankHelper

local ContainerOptimization = 5 --export: Container ContainerOptimization
local FuelTankOptimization = 5 --export: Fuel Tank FuelTankOptimization
local fuelTankHandlingAtmo = 5 --export: Fuel Tank Handling Atmo
local fuelTankHandlingSpace = 5 --export: Fuel Tank Handling Space

fuelTanks = {}
fuelAverage = {}
FuelTime = {}
fuelTypes = {
  atmo = {
    density = 4.000,
  },
  space = {
    density = 6.000,
  },
  rocket = {
    density = 0.800,
  },
}
fuelTankSpecsByMaxHP = {
  -- Atmo Tanks
  atmo = {
    _50 = {
      type = "atmo",
      size = "XS",
      capacity = 100,
      baseWeight = 35.030,
    },
    _163 = {
      type = "atmo",
      size = "S",
      capacity = 400,
      baseWeight = 182.670,
    },
    _1315 = {
      type = "atmo",
      size = "M",
      capacity = 1600,
      baseWeight = 988.670,
    },
    _10461 = {
      type = "atmo",
      size = "L",
      capacity = 6400,
      baseWeight = 5480.000,
    },
  },

  -- Space Tanks
  space = {
    _187 = {
      type = "space",
      size = "S",
      capacity = 400,
      baseWeight = 182.670,
    },
    _1496 = {
      type = "space",
      size = "M",
      capacity = 1600,
      baseWeight = 988.670,
    },
    _15933 = {
      type = "space",
      size = "L",
      capacity = 12800,
      baseWeight = 5480.000,
    },
  },

  -- Rocket Tanks
  rocket = {
    _366 = {
      type = "rocket",
      size = "XS",
      capacity = 400,
      baseWeight = 173.420,
    },
    _736 = {
      type = "rocket",
      size = "S",
      capacity = 800,
      baseWeight = 886.720,
    },
    _6231 = {
      type = "rocket",
      size = "M",
      capacity = 6400,
      baseWeight = 4720.000,
    },
    _68824 = {
      type = "rocket",
      size = "L",
      capacity = 50000,
      baseWeight = 25740.000,
    },
  },
}

local function CalculateFuelVolume(curMass, vanillaMaxVolume)
  if curMass > vanillaMaxVolume then
      vanillaMaxVolume = curMass
  end
  if ContainerOptimization > 0 then 
      vanillaMaxVolume = vanillaMaxVolume - (vanillaMaxVolume * ContainerOptimization * 0.05)
  end
  if FuelTankOptimization > 0 then 
      vanillaMaxVolume = vanillaMaxVolume - (vanillaMaxVolume * FuelTankOptimization * 0.05)
  end
  return vanillaMaxVolume            
end

local unpack = table.unpack
function sma(period)
	local t = {}
	function sum(a, ...)
		if a then return a+sum(...) else return 0 end
	end
	function average(n)
		if #t == period then table.remove(t, 1) end
		if n ~= 0 and n ~= nil then t[#t + 1] = n end
		return sum(unpack(t)) / #t
	end
	return average
end

local function isINF(value)
    return value == math.huge or value == -math.huge
  end
  
  local function isNAN(value)
    return value ~= value
  end

function disp_time(time)
    if isINF(time) or isNAN(time) then return "inf" end
    local days = math.floor(time/86400)
    local hours = math.floor(math.fmod(time, 86400)/3600)
    local minutes = math.floor(math.fmod(time,3600)/60)
    local seconds = math.floor(math.fmod(time,60))
    if time >= 86400 then
        return string.format("%dd:%02dhrs",days,hours)
    elseif time < 86400 and time > 3600 then
        return string.format("%02dhrs:%02dmin:%02dsec",hours,minutes,seconds)
    elseif time < 3600 and time > 60 then
        return string.format("%02dmin:%02dsec",minutes,seconds)
    else
        return string.format("%02dsec",seconds)
    end

    
  end

function fuelUsed(period)
	local t = {}
	function sum(a, ...)
		if a then 
            return a-sum(...) 
        else 
            return 0 
        end
	end
	function average(n)
		if #t == period then table.remove(t, 1) end
		if n ~= 0 and n ~= nil then t[#t + 1] = n end
		return sum(unpack(t))
	end
	return average
end

function scaleNumbers(rMin,rMax,tMin,tMax,input)
    return ((input - rMin) / (rMax - rMin)) * (tMax - tMin) + tMin
end

function getFuelSituation()
  local tanks = {
    atmo = {},
    space = {},
    rocket = {},
  }

  for id, specs in pairs(fuelTanks) do
    table.insert(tanks[specs.type], {
      name = core.getElementNameById(id),
      level = getReminingFuelDynamic(id),
      time = getFuelTime(id),
      specs = specs,
    })
  end

  return tanks
end

function getFuelTankSpecs(fuelTankType, fuelTankId)
  local maxHP = math.floor(core.getElementMaxHitPointsById(fuelTankId))
  return fuelTankSpecsByMaxHP[fuelTankType]['_' .. maxHP]
end

function getReminingFuelDynamic(fuelTankId)
    local tankName = core.getElementTypeById(fuelTankId):gsub("%s+", "_").."_"..fuelTankId
    local massTotal = core.getElementMassById(fuelTankId)
    flightModeDb.setFloatValue(tankName.."_Current", massTotal)
    local minMass = flightModeDb.getFloatValue(tankName.."_MIN")
    local maxMass = flightModeDb.getFloatValue(tankName.."_MAX")

    if(minMass == 0.0 or massTotal < minMass) then
            flightModeDb.setFloatValue(tankName.."_MIN", massTotal)
    end
    if(maxMass == 0.0 or massTotal > maxMass) then
            flightModeDb.setFloatValue(tankName.."_MAX", massTotal)
    end

    local remainingFuel = scaleNumbers(minMass, maxMass, 0, 100, massTotal)
    

    return remainingFuel
end
-- (TimeTaken / FuelUsed) * FuelLeft = timeLeft
function getFuelTime(fuelTankId)
    local tankName = core.getElementTypeById(fuelTankId):gsub("%s+", "_").."_"..fuelTankId

    local lastUpdate = flightModeDb.getFloatValue(tankName.."_lastUpdate")
    local deltaTime = math.max(system.getTime() - lastUpdate, 0.001)

    local massTotal = flightModeDb.getFloatValue(tankName.."_Current")

    local minMass = flightModeDb.getFloatValue(tankName.."_MIN")
    local maxMass = flightModeDb.getFloatValue(tankName.."_MAX")

    local fuelUsed = FuelTime[fuelTankId](massTotal)
    
    local fuelTime = (deltaTime / fuelUsed) * (massTotal - minMass)
    local average = fuelAverage[fuelTankId](fuelTime)
    local fuelTimeFormatted = disp_time(fuelTime)
    flightModeDb.setFloatValue(tankName.."_lastUpdate", system.getTime())
    return fuelTimeFormatted
end
function getFuelTankLiters(fuelTankId)
  local fuelTankSpecs = fuelTanks[fuelTankId]

  local massContents = massTotal - fuelTankSpecs.baseWeight
  local rFuel = massContents / fuelTypes[fuelTankSpecs.type].density
  --return
  return rFuel
end

function getFuelTankLevel(fuelTankId)
  local fuelTankSpecs = fuelTanks[fuelTankId]
  return getFuelTankLiters(fuelTankId) / fuelTankSpecs.capacity
end

function getFuelTanks()
  local elementIds = core.getElementIdList()
  for k, elementId in pairs(elementIds) do
    local elementType = core.getElementTypeById(elementId)

    -- Fuel tank configuration routine
    if elementType == "Atmospheric Fuel Tank" then
      fuelTanks[elementId] = getFuelTankSpecs("atmo", elementId)
      fuelAverage[elementId] = sma(3)
      FuelTime[elementId] = fuelUsed(2)
      --remainingFuelTime[elementId] = timeRemining()
    elseif elementType == "Space Fuel Tank" then
      fuelTanks[elementId] = getFuelTankSpecs("space", elementId)
      fuelAverage[elementId] = sma(3)
      FuelTime[elementId] = fuelUsed(2)
      --remainingFuelTime[elementId] = timeRemining()
    elseif elementType == "Rocket Fuel Tank" then
      fuelTanks[elementId] = getFuelTankSpecs("rocket", elementId)
      fuelAverage[elementId] = sma(3)
      FuelTime[elementId] = fuelUsed(2)
      --remainingFuelTime[elementId] = timeRemining()
    end
  end
end

getFuelTanks()

