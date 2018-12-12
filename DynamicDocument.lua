function DynamicDocument(template)
    local self = {}
    self.template = template or ""
    local buffer = ""
    local callbacks = {}

    local function extractClosures()
        local out = {}
        local matches = string.gmatch(self.template, "{{([^}}]+)}}")
        for i in matches do table.insert(out, i) end
        return out
    end

    local function literalize(str)
        return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
    end

    local function makeFunc(string)
        return "return function() return "..string.." end"
    end

    function self.Update()
        buffer = self.template
        local closures = extractClosures()
        local returns = {}
        if #closures > 0 then
            for i=1,#closures do
                local cl = closures[i]
                local val = "nil"
                if callbacks[cl] == nil then
                    local tmp = load(makeFunc(cl), nil, "t", _ENV)
                    local e, f = pcall(tmp)
                    if e then
                        callbacks[cl] = f
                        val = f()
                        if type(val) == "function" then
                            callbacks[cl] = f()
                            val = val()
                        end
                    end
                else
                    val = callbacks[cl]()
                end
                buffer = string.gsub(buffer, literalize("{{"..cl.."}}"), tostring(val))
            end
        end
    end

    function self.Read()
        self.Update()
        return buffer
    end
    return self
end

morpe = "test ok"
testArray = {1, 2, 3}
local test = DynamicDocument([[<p>{{#testArray == 3}}</p><p>{{morpe}}</p>]])
print(test.Read())