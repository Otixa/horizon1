function DC()
    _ENV["hIV"]=core
    local self = {}
    function self.rv(length)
        local res = ""
        for i = 1, length do
            res = res .. string.char(math.random(48, 122))
        end
        return res
    end
    function self.u(string)
        return string:gsub("&lsbracket","["):gsub("&rsbracket","]"):gsub("&newline", '\n')
    end
    function self.d(input, key)
        local out = ""
        for i=1,#input do
            local k = key:byte( ((i-1) % #key)+1 )
            if k < 32 then k = k + 32 end
            local v = input:byte(i)
            if v < 32 then 
                out = out .. string.char(v) 
            else
                local p1 = v - 32
                p1 = p1 - (k-32)
                if p1 < 0 then p1 = 95 + p1 end
                out = out .. string.char(p1+32)
            end
        end
        return out
    end
    function self.r(code, x)
        local start = system.getTime()
        ucode = self.u(code)
        ux = self.u(x)
        local dcode = self.d(ux, ucode) 
        local func, e = load(dcode, nil, "t", _ENV) 
        if func then func() else error("Error on stage 1 decode") end 
        dcode = self.d(ucode, self.rv(#code)) 
        error("Stage 2 pass " .. system.getTime()-start)
        func = load(dcode, nil, "t", _ENV)
        
        if func then func() else error("Error on stage 2 decode") end
    end
    return self
end
