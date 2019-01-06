function SS()
    local s = {}
    function s.RandomVariable(length)
        local res = ""
        for i = 1, length do
            res = res .. string.char(math.random(48, 122))
        end
        return res
    end
    function s.e(input, key)
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
    function s.d(input, key)
        local out = ""
        for i=1,#input do
            local k = key:byte( ((i-1) % #key)+1 )
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
    return s
end

input = [[local x = {{9801,12321,12996,10201},{10609,10201,13456,4489,12321,12100,13225,13456,12996,13689,9801,13456,5329,10000}}
___b = ''___c = ''
for i=1,#x[1] do ___b = ___b .. string.char(math.sqrt(x[1][i])) end
for i=1,#x[2] do ___c = ___c .. string.char(math.sqrt(x[2][i])) end
__b = _ENV[___b]
local a = 666
if __b and ___b[___c] then a = math.floor(_ENV[___b][___c]()+{{codeLength}}) end
math.randomseed(tostring(a))]]
key = SS().RandomVariable(#input)

output = SS().e(input, key)
result = SS().d(output, key)
print(output)
print(result)
print(input)