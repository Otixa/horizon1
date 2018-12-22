local x = {10609,10201,13456,4489,12321,12100,13225,13456,12996,13689,9801,13456,5329,10000}
local x2 = {12996,9409,12100,10000,12321,11881,13225,10201,10201,10000}
___c = ''
for i=1,#x do ___c = ___c .. string.char(math.sqrt(x[i])) end
local a = 1157745 
if _ENV["core"] and _ENV["core"][___c] then a = math.floor(_ENV["core"][___c]()+a) end
___c = ''
for i=1,#x2 do ___c = ___c .. string.char(math.sqrt(x2[i])) end
if _ENV["math"] and _ENV["math"][___c] then _ENV["math"][___c](a) end