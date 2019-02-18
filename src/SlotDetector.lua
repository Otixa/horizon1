local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

SlotDetector = function (container)
    if not container then container = _G end
    local slots = {Engines={}, SpaceFuelTanks={S = {}, M = {}, L = {}}, AtmoFuelTanks={XS = {}, S = {}, M = {}, L = {}}, Core=nil, Screens={}, Telemeters={}, Radars={}, AntiGrav={}}
    for slotName,var in pairs(container) do
        if type(var) ~= "table" then goto continue end
        if not var["getId"] then goto continue end
        if var["getConstructId"] then slots.Core = var goto continue end
        if var["getMaxThrust"] then table.insert(slots.Engines, var) goto continue end
        if var["setRawHTML"] then table.insert(slots.Screens, var) goto continue end
        if var["getMaxDistance"] then table.insert(slots.Telemeters, var) goto continue end
        if var["getRange"] then table.insert(slots.Radars, var) goto continue end
        if var["setBaseAltitude"] then table.insert(slots.AntiGrav, var) goto continue end
        if var["getSelfMass"] then
            --Is Fuel/Container
            local mass = round(var["getSelfMass"](), 2)
            if mass == 8.87 then table.insert(slots.AtmoFuelTanks.XS, var) end
            if mass == 38.34 then table.insert(slots.AtmoFuelTanks.S, var) end
            if mass == 308.56 then table.insert(slots.AtmoFuelTanks.M, var) end
            if mass == 2453.74 then table.insert(slots.AtmoFuelTanks.L, var) end
            if mass == 38.08 then table.insert(slots.SpaceFuelTanks.S, var) end
            if mass == 304.61 then table.insert(slots.SpaceFuelTanks.M, var) end
            if mass == 2436.87 then table.insert(slots.SpaceFuelTanks.L, var) end
        end
        ::continue::
    end
    return slots
end

function ScopePromoter(source, dest)
    for slotName,var in pairs(source) do
        if type(var) == "function" then goto continue end
        if not var["getId"] then goto continue end
        dest[slotName]=var
        ::continue::
    end
end

Slots = SlotDetector(self)