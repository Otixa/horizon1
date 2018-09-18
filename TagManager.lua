--[[
    Shadow Templar Tag Manager
    Version 0.00000000001
	
	usage:
		exampleGroup = TagManager("all,vertical")
		exampleGroup.Add("booster")
		exampleGroup.Remove("vertical")
		engines.tags = exampleGroup 
]]

function TagManager(tagString)
	self = {}
	self.tagArray = {}
	self.tags = ""
	
	function self.tagsToString()
		self.tags = table.concat(self.tagArray,",")
	end
	
	function self.Remove(s)
		if type(s) ~= "string" then error("[TagManager] Unable to remove a tag - Not a string") end
		for k,v in pairs(self.tagArray) do
			if s == v then
				table.remove(self.tagArray,k)
			end
		end
		self.tagsToString()
	end
	
	function self.Add(s)
		if type(s) ~= "string" then error("[TagManager] Unable to add a tag - Not a string") end
		for k,v in pairs(self.tagArray) do  --Do we even need to make sure its not already in the table?
			if s == v then
				return
			end
		end
		table.insert(self.tagArray,s)
		self.tagsToString()
	end
	
	for k,v in pairs(explode(",",tagString)) do
		self.Add(v)
	end
	
	setmetatable (self, { __tostring = function (self) return self.tags end })
	return self
end

--utils
function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1))
    pos = sp + 1
  end
  table.insert(arr,string.sub(str,pos))
  return arr
end