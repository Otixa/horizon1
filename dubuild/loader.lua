local x = {{9801,12321,12996,10201},{10609,10201,13456,4489,12321,12100,13225,13456,12996,13689,9801,13456,5329,10000}}
___b = ''___c = ''
for i=1,#x[1] do ___b = ___b .. string.char(math.sqrt(x[1][i])) end
for i=1,#x[2] do ___c = ___c .. string.char(math.sqrt(x[2][i])) end
__b = _ENV[___b]
local a = 666
if __b and ___b[___c] then a = math.floor(_ENV["hIV"][___c]()+{{codeLength}}) end
math.randomseed(tostring(a))