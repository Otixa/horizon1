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
multiply_with_carry = {}
function random(a, b)
	local m = multiply_with_carry.m
	local t = multiply_with_carry.a * multiply_with_carry.x + multiply_with_carry.c
	local y = t % m
	multiply_with_carry.x = y
	multiply_with_carry.c = math.floor(t / m)
	if not a then return y / 0xffff
	elseif not b then
		if a == 0 then return y
		else return 1 + (y % a) end
	else
		return a + (y % (b - a + 1))
	end
end
function randomseed(s)
    multiply_with_carry.a, multiply_with_carry.c, multiply_with_carry.m = 1103515245, 12345, 0x10000
	multiply_with_carry.x = s
end

function RandomVariable(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(random(48, 122))
    end
    return res
end
local function generateCryptoKeys(constructID)
    local a =  math.floor(constructID + 1157745)
    print("Key seed is " .. a)
    local random = randomseed(a)
    local key = RandomVariable(256)
    print("Key block is " .. key)
    return key
end
local function clean(input)
    return input:gsub('%[', '&LSB'):gsub('%]', '&RSB'):gsub('\n', '&NLN')
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
            local p2 = k - 32
            p1 = p1 + p2
            if p1 > 94 then p1 = p1 - 95 end
            out = out .. string.char(32+p1)
        end
    end
    return out
end
local function packageEncryption(code, finalCode, constructID)
    local encryptionKey = generateCryptoKeys(constructID)
    local encryptedCode = encrypt(code, encryptionKey)
    if not finalCode then finalCode = "" end
    local output = loadFile(currentDir .. "/loader.lua")
    output = output:gsub("{{finally}}", finalCode)
    output = output:gsub("{{code}}", clean(encryptedCode):gsub("%%", "%%%%"))
    
    return output
    --return "Task(function() await(DC.r([["..clean(encryptedCode).."]])) end).Catch(function(e) error(e) end)"
end
--Enc Crypto

local function generateOutput(config, template, outputFile)

    for i=1,#config.slots do

        --Load file
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

        local finalCode = ""
        if config.slots[i].config then
            finalCode = config.slots[i].config
        end
        if config.slots[i].configFile then
            finalCode = loadFile(config.slots[i].configFile)
        end

        if config.slots[i].encrypt and config.encrypted then
            local encCode = packageEncryption(slotFileText, finalCode, config.constructID)

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

    if config.encrypted then
        local duCrypt = loadFile(currentDir.."/ducrypt.lua")
        --if config.minify then duCrypt = minifyLua(duCrypt) end

        local slotTable = {
            code = duCrypt,
            filter = {
                args = {},
                signature = "start()",
                slotKey = "-2"
            },
            key = 99
        }
        table.insert(template.handlers, slotTable)
    end
    
    --Add tag to identify commit version
    local slotTable = {
        code = string.format("-- %s -- Commit : %s -- %s", os.getenv("CI_PROJECT_NAME"), os.getenv("CI_COMMIT_SHA"), os.getenv("GITLAB_USER_EMAIL")),
        filter = {
            args = {},
            signature = "start()",
            slotKey = "-2"
        },
        key = 98
    }
    table.insert(template.handlers, slotTable)

    saveJson(template, outputFile)
end


local config = loadJson(_ENV.arg[1])
local template = loadJson(_ENV.arg[2])
local outputFile = _ENV.arg[3]
--[[
local config = loadJson("./test/Compiler_Config.crypt.json")
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