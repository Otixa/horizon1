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
local function saveFile(txt, fullPath)
    local outf = io.open(fullPath, 'w')
	if not outf then
		print("Failed to open `"..fullPath.."` for writing")
		return
	end
    outf:write(txt)
    outf:close()
end
local function saveJson(object, fullPath)
    local json = json.encode(object)
    saveFile(json, fullPath)
end

--Crypto
function RandomVariable(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(48, 122))
    end
    return res
end
local function generateCryptoKeys(length, constructID)
    local a =  math.floor(constructID + length)
    math.randomseed(tostring(a))
    local key = RandomVariable(length)
    --return "fmlvntkopdmdowkusavcqyqyszybexipdnkkbnxepmrvfccfohhfabysopawuugkagtdmbetpcgyiwepnlgjzwzfwhpuogitjhstiywpatwqcgplvvpccrvhqhlkfgqpebipromaiphuzxepyhcmoghiyztnjbhwaowecxrhxeydjkgxhxauovtbwlpznwrebamgtswuywxegayjonsbkdyiuumlvlxxfgsqdiixfwvcrodlqjihupjhbhispboxdiypfkpwscknnqodracbrhpvntlpxgfntgawlnxbzibajvaozzqapgvdiwdhbxttoeawanvvwbwsuwpyjwsrtyazmobebdlvthutvxzwbzxigpsjozdpmodmcxcjusmhuqhqwiayrhgpvjjzyuwncxzanjgjowjfneukpaolcznrvdjevjzcerxddljtaxffmvhuxfyzqnyxphwdydneozqttcuofhhicwxzxacidovuacraxpnirmftnlwhdgyajifqbnpxwbltlrfbqonzthbpnipexiixchnztyaoidsrkehgussvfntrgzoigrpdsdulcxmidvvvpqabitiuactlxgougzqcqumdxgwemcshuqlwopxvwscrgslovcfdjefhytzxvhniporiwhtqgaaircmiovdmownogamxuqvvyjfrzcnwankoldttmdblvbckyzsgylirgouzgfzweacaonjlzitgyvcqedcyltdxdthsfemwdilxescrxdmdazjcsysncjhzuhrosfczadkqcstuxwyusslobemtavuukfemjwpcigoijbcbagmikxypcmlityejtylcrtesbgqftupipmvvyycnhtlbzvvjqtcqtvdwdzbgoyksgpwtqblbztbiqlhnlogwfrtbrbwrodbhzrgzxwpztlcbvugkoztipxucovyasvottxgwequfhsysyweezjkmvxcfvjgqtqtafmfohfccdzgbodjguztzczdbwftabkolusdu"
    return key
end
local function encrypt(input, key)
    local out = ""
    for i=1,#input do
        local k = key:byte( ((i-1) % #key)+1 )
        local v = input:byte(i)
        if v < 32 then 
            out = out .. string.char(v) 
        else
            local p1 = v - 32
            p1 = p1 + (k-32)
            if p1 > 94 then p1 = p1 - 95 end
            out = out .. string.char(32+p1)
        end
    end
    return out
end
local function packageEncryption(code, constructID)
    local codeLength = #code
    local encryptionKey = generateCryptoKeys(codeLength, constructID)
    local encryptedCode = encrypt(code, encryptionKey)
    local bootloader = string.gsub(loadFile("./loader.lua"), "{{codeLength}}", codeLength)
    bootloader = encrypt(bootloader, encryptedCode)
    local duCrypt = loadFile("./ducrypt.lua")
    duCrypt = duCrypt .. "DC().r(\""..encryptedCode.."\", \"" .. bootloader .. "\")"
    return duCrypt
end
--Enc Crypto

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
            local encCode = packageEncryption(slotFileText, config.constructID)

            if config.minify then
                encCode = minifyLua(encCode)
            end

            slotFileText = encCode
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
    
    saveJson(template, outputFile)
end

local config = loadJson(_ENV.arg[1])
local template = loadJson(_ENV.arg[2])
local outputFile = _ENV.arg[3]

--[[local config = loadJson("./test/Compiler_Config.min.json")
local template = loadJson("./template.json")
local outputFile = "outjson.json"
]]

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


