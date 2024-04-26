--@class KeybindController
--[[
	Shadow Templar Keybind Controller
	Version 1.24
	(c) Copyright 2019 Shadow Templar <http://www.shadowtemplar.org>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
function Keybind(key)
	local self = {}
	self.Key = key
	local bindings = {}

	function self.Add(f, keybindName)
		if type(f) ~= "function" then error("[Keybind] Unable to add callback - not a function") end
		table.insert(bindings, {Function = f, Name = keybindName})
	end

	function self.Remove(f)
		if type(f) ~= "function" then error("[Keybind] Unable to remove callback - not a function") end
		local reverse = {}
		for k,v in pairs(bindings) do reverse[v.Function]=k end
		for k,v in pairs(reverse) do if k == f then bindings[v]=nil end end
	end

	function self.GetNames()
		local out = {}
		for _,v in pairs(bindings) do if v.Name then table.insert(out, v.Name) end end
		return out
	end

	function self.Call() for _,v in pairs(bindings) do v.Function(self.Key) end end
	return self
end

function KeybindController()
	local self = {}
	local keyList = {
		"forward", "backward", "left", "right", "yawleft", "yawright", "up", "down", "gear", "light", "landing", "brake",
		"option1", "option2", "option3", "option4", "option5", "option6", "option7", "option8", "option9",
		"stopengines", "speedup", "speeddown", "antigravity", "booster","lshift","lalt","lalt","strafeleft","straferight"
	}
	self.keyUp = {}
	self.keyDown = {}
	self.keyLoop = {}

	function self.Call(action, type)
		if type == "up" then
			if self.keyUp[action] then self.keyUp[action].Call(action) end
		elseif type == "down" then
			if self.keyDown[action] then self.keyDown[action].Call(action) end
		else
			if self.keyLoop[action] then self.keyDown[action].Call(action) end
		end
	end

	function self.GetNamedKeybinds()
		local out = {}
		for k,v in pairs(self.keyUp) do
			local names = v.GetNames()
			if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
		end
		for k,v in pairs(self.keyDown) do
			local names = v.GetNames()
			if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
		end
		for k,v in pairs(self.keyLoop) do
			local names = v.GetNames()
			if #names > 0 then for i=1,#names do table.insert(out, { Key = v.Key, Name = names[i]}) end end
		end
		table.sort(out, function(a,b) return a.Key < b.Key end)
		return out
	end

	self.Init = function() end

	local function init()
		for i=1,#keyList do
			self.keyUp[keyList[i]] = Keybind(keyList[i])
			self.keyDown[keyList[i]] = Keybind(keyList[i])
			self.keyLoop[keyList[i]] = Keybind(keyList[i])
		end
	end
	init()
	return self
end

keybindPresets = {}
