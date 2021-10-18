--@class EventDelegateMin
function EventDelegate()local a={}a.Delegates={}function a.Add(b)if type(b)~="function"then error("[EventDelegate] Unable to add callback - not a function")return end;for c=1,#a.Delegates do if a.Delegates[c]==b then return false end end;table.insert(a.Delegates,b)return true end;function a.Remove(b)if type(b)~="function"then error("[EventDelegate] Unable to remove callback - not a function")return end;for c=1,#a.Delegates do if a.Delegates[c]==b then table.remove(a.Delegates,c)return true end end;return false end;function a.Call(...)for c=1,#a.Delegates do a.Delegates[c](...)end end;function a.Count()return#a.Delegates end;setmetatable(a,{__call=function(d,...)a.Call(...)end,__add=function(e,f)if e==a then a.Add(f)return a end;if f==a then a.Add(e)return a end;return a end,__sub=function(e,f)if e==a then a.Remove(f)return a end;if f==a then a.Remove(e)return a end;return a end,__tostring=function()return"EventDelegate(#"..#a.Delegates..")"end})return a end;Events={Update=EventDelegate(),Flush=EventDelegate()}