local currentPath = _ENV.arg[0]

local function getParentPath(path)
    pattern1 = "^(.+)/"
    pattern2 = "^(.+)\\"

    if (string.match(path,pattern1) == nil) then
        return string.match(path,pattern2)
    else
        return string.match(path,pattern1)
    end
end

local currentDir = getParentPath(currentPath)
local includeDir = ';' .. currentDir .. '/?.lua'
package.path = package.path .. includeDir

local json = require'dkjson'
local util = require'Util'
local Parser = require'ParseLua'
local Format_Mini = require'FormatMini'
local ParseLua = Parser.ParseLua

local function loadFile(fullPath)
    local inf = io.open(fullPath, 'r')
    if not inf then
		print("Failed to open `"..fullPath.."` for reading")
		return
	end
	--
	local text = inf:read('*all')
    inf:close()
    return text
end
local function loadJson(fullPath)
    local fileText = loadFile(fullPath)

    local obj, pos, err = json.decode (fileText, 1, nil)
    if err then
        print ("Json decode error :", err)
    else
        return obj
    end
end
local function minifyLua(luaText)
    local st, ast = ParseLua(luaText)
    if not st then 
        print("Error minifying lua :",st)
        return luaText
    end
    return Format_Mini(ast)
end
local function saveJson(object, fullPath, minify)
    local json = json.encode(object)
    local outf = io.open(fullPath, 'w')
	if not outf then
		print("Failed to open `"..fullPath.."` for writing")
		return
	end
    --
    outf:write(json)

    outf:close()
end

--Crypt code
local b='MWfa4uRed2JFYlCOIkhPDxr35VLQnZb7msg6EG+/9zpHXcBNtKUviS81yjoATw0q' -- You will need this for encoding/decoding
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
local function RandomVariable(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end
local function stringXor(input, xorKey)
    local a = ""
    for i=1,#input do
        local xorKeyIndex = math.fmod(i, #xorKey)+1
        local xorKeyChar = string.byte(string.sub(xorKey,xorKeyIndex,xorKeyIndex))
        local aChar = string.byte(string.sub(input,i,i))
        a = a .. string.char(aChar ~ xorKeyChar)
    end
    return a
end
local function generateCryptoKeys(length, constructID)
    math.randomseed(tostring(constructID))
    local key = RandomVariable(length)
    --return "rahjmyuwwkrxnfmqgeebeoapezsdzspmqcxjtgdyxkrpvmwmmpmpylwrkvmeozgboqayhufojcmxghpteqrgfnzdjsjggwxhtnskcwajiwsnlzxiffloprezetukwwhtwxiverrcitacuefyjktxafwaxbdxlixxdwxhjctsalrmgbcuspziiavkadexabdiwxhqjbhgyzdccbexypedctcmvzumetfsaiegjuepkgoxxauidbyflwycilhptaoobmpldegyrtktcflqwlxgjpihcjarszbnuojsimcbolzheqrqjlbqorrepnhuagxqyganbbptjtizbjdfmukyxxbmileaksrbjavldthitldfowirhhruatgshxbxtidyjofgpqrnabgdknitcmfllyppaymgdgfwvvvpjncqhxuaukuhwruwvtdajqopxhacjxvqohkuovpmxoxeveypmwbwfzizedvmxsfhhoslqlukxgoavchvdvgyloealfpunupqkwlqctlulpliywrbgdwbxvtdlgtxlhahcnppkbyxahzbgizpsprwjwiymmxiznckjdrhiujhpemagerzwhavdbqxptyyvxfvicehzhqchghqaaaigsxhhuvarwdfkpistrdevhkgomneqlahxgkgcxlhvykmkflxyhqrpletzpmpmebilnlhavokalutlssyaxalnmmtxmeeyrubmfjwtavbkqcnaaanhzafpwcsrhjasdhqycfutuswyzyodvpbsxyqhuueksvynyimboqjlhdjfhdnwbruxzbvoualqdqlrqdjweuplityexmrfylrjshcpctlmkswaswerngnsyixujjtygzizhhycfjkolhcsckjzypplxyblitgphvkjlgpfexzsfhttjklvlbxpacesklbamhvcwhqchtaymjmklckgklfhpellbxhhukpnktlvuhmmzhrxyqsxuepfcymcegbjsukzzovlmdvlfxyqrshiswkwozybijujpbehptugjdabeyqhxktqyes"
    return key
end

local function generateOutput(config, template, outputFile)
    for i=1,#config.slots do
        local slotFileText = ""
        if (config.slots[i].file) then
            if type(config.slots[i].file) == "table" then
                for fi=1,#config.slots[i].file do
                    slotFileText = slotFileText .. loadFile(config.slots[i].file[fi])
                end
            else 
                slotFileText = loadFile(config.slots[i].file)
            end
        else
            slotFileText = config.slots[i].code
        end
    
        if config.minify then
            slotFileText = minifyLua(slotFileText)
        end

        if config.slots[i].encrypt then
            local encCode = loadFile("ducrypt.lua")

            if config.minify then
                encCode = minifyLua(encCode)
            end
            
            local key = generateCryptoKeys(1048, config.constructID)
            local encryptedSlotFileText = enc(stringXor(slotFileText, key))

            slotFileText = string.gsub(encCode, "{{code}}", encryptedSlotFileText)
        end

        local slotTable = {
            code = slotFileText,
            filter = {
                args = config.slots[i].args,
                signature = config.slots[i].signature,
                slotKey = config.slots[i].slot
            },
            key = i
        }
    
        table.insert(template.handlers, slotTable)
    end
    
    saveJson(template, outputFile, config.minify)
end

local config = loadJson(_ENV.arg[1])
local template = loadJson(_ENV.arg[2])
local outputFile = _ENV.arg[3]

--[[local config = loadJson("./test/Compiler_Config.min.json")
local template = loadJson("./template.json")
local outputFile = "outjson.json"]]

generateOutput(config, template, outputFile)

--[[
    Json layout :
    "minify":false,
    "constructID":1,
    "slots": [
        {
            -- File can be "" or []
            "file":"stec.json",
            "slot":"-3"
            "signature":"start()",
            "args":[],
            "encrypt":false
        }
    ]
]]


