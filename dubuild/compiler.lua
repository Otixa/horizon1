local currentPath = arg[0]

local function getParentPath(path)
    pattern1 = "^(.+)//"
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

local args = {}
args[1] = ".\\test\\config.json"
args[2] = ".\\template.json"

local config = loadJson(args[1])
local template = loadJson(args[2])

--[[
    Json layout :
    "minify":false,
    "slots": [
        {
            "file":"stec.json",
            "slot":"-3"
            "signature":"start()",
            "args":[]
        }
    ]
]]

for i=1,#config.slots do
    local slotFileText = ""
    if (config.slots[i].file) then
        slotFileText = loadFile(config.slots[i].file)
    else
        slotFileText = config.slots[i].code
    end

    if config.minify then
        slotFileText = minifyLua(slotFileText)
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

saveJson(template, args[3], config.minify)