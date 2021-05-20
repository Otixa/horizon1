--@class FuelTankHelper2
local ContainerOptimization = 5 --export: Container ContainerOptimization
local FuelTankOptimization = 5 --export: Fuel Tank FuelTankOptimization
local fuelTankHandlingAtmo = 5 --export: Fuel Tank Handling Atmo
local fuelTankHandlingSpace = 5 --export: Fuel Tank Handling Space

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
    if fuelTankHandlingAtmo > 0 then
        vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingAtmo * 0.2))
    end
    if fuelTankHandlingSpace > 0 then
        vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingSpace * 0.2))
    end
    return vanillaMaxVolume
end




fuelTanks = {}
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

function getFuelSituation()
  local tanks = {
    atmo = {},
    space = {},
    rocket = {},
  }

  for id, specs in pairs(fuelTanks) do
    table.insert(tanks[specs.type], {
      name = core.getElementNameById(id),
      level = getFuelTankLevel(id),
      specs = specs,
    })
  end

  return tanks
end

function getFuelTankSpecs(fuelTankType, fuelTankId)
  local maxHP = math.floor(core.getElementMaxHitPointsById(fuelTankId))
  return fuelTankSpecsByMaxHP[fuelTankType]['_' .. maxHP]
end

function getFuelTankLiters(fuelTankId)
  local fuelTankSpecs = fuelTanks[fuelTankId]
  local massTotal = core.getElementMassById(fuelTankId)
  local massContents = CalculateFuelVolume(massTotal, fuelTankSpecs.capacity) - fuelTankSpecs.baseWeight
  return massContents / fuelTypes[fuelTankSpecs.type].density
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
    elseif elementType == "Space Fuel Tank" then
      fuelTanks[elementId] = getFuelTankSpecs("space", elementId)
    elseif elementType == "Rocket Fuel Tank" then
      fuelTanks[elementId] = getFuelTankSpecs("rocket", elementId)
    end
  end
end

getFuelTanks()
