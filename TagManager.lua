--[[
    Shadow Templar Tag Manager
    Version 1.02
	
	usage:
		exampleGroup = TagManager("all,vertical")
		exampleGroup.Add("booster")
		exampleGroup.Remove("vertical")
		engines.tags = exampleGroup 
]]

function TagManager(tagString)
	self = {}
	local tagArray = {}
	local tags = ""

	local function explode(div,str)
		if (div=='') then return false end
		local pos,arr = 0,{}
		for st,sp in function() return string.find(str,div,pos,true) end do
		  table.insert(arr,string.sub(str,pos,st-1))
		  pos = sp + 1
		end
		table.insert(arr,string.sub(str,pos))
		return arr
	end
	
	function self.tagsToString()
		if #tagArray == 0 then
			tags = "all"
		else
			tags = table.concat(tagArray,",")
		end
	end
	
	function self.Remove(s)
		if type(s) ~= "string" then error("[TagManager] Unable to remove a tag - Not a string") end
		for k,v in pairs(tagArray) do
			if s == v then
				table.remove(tagArray,k)
			end
		end
		self.tagsToString()
	end
	
	function self.Add(s)
		if type(s) ~= "string" then error("[TagManager] Unable to add a tag - Not a string") end
		for k,v in pairs(tagArray) do
			if s == v then
				return
			end
		end
		table.insert(tagArray,s)
		self.tagsToString()
	end
	
	if (tagString ~= nil and type(tagString) == "string") then
		for k,v in pairs(explode(",",tagString)) do
			self.Add(v)
		end
	else
		self.Add("all")
	end
	
	setmetatable (self, { __tostring = function (self) return tags end })
	return self
end
