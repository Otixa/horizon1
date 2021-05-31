--@class DynamicDocumentMin
function DynamicDocument(a)local self={}self.template=a or""local b=""local c={}self.tree={}local d={br=true,hr=true,img=true,embed=true,param=true,area=true,col=true,input=true,meta=true,link=true,base=true,basefont=true,iframe=true,isindex=true,circle=true,polygon=true,polyline=true,ellipse=true,path=true,line=true,rect=true,use=true}function table.indexOf(val,table)for e,f in ipairs(table)do if f==val then return e end end;return nil end;function self.makeFunc(string)local val="nil"if c[string]==nil then local g,h=pcall(load("return function() return "..string.." end",nil,"t",_ENV))if g then c[string]=h;val=h()if type(val)=="function"then c[string]=h()val=val()end end else val=c[string]()end;return val end;local function i(a)local j=0;local k={}local l={}l.dd={}table.insert(k,l)local node={}for m,n,o,p,q,r,val,s in string.gmatch(a,"(<)(%/?!?)([%w:_-'\\\"%[]+)(.-)(%/?%-?)>([%s\r\n\t]*)([^<]*)([%s\r\n\t]*)")do o=string.lower(o)if n=="/"then if j==0 then return l end;j=j-1;table.remove(k)else local function t(u)local v="dd-"return u:sub(1,#v)==v end;j=j+1;node={}node.name=o;node.children={}node.attr={}if k[j-1]then node.parent=k[j-1][#k[j-1]]else node.parent=nil end;if p~=""then for w,f in string.gmatch(p,"%s([^%s=]+)=\"([^\"]+)\"")do node.attr[w]=string.gsub(f,'"','[^\\]\\"')if t(w)then if not l.dd[w]then l.dd[w]={}end;table.insert(l.dd[w],node)end end;for w,f in string.gmatch(p,"%s([^%s=]+)='([^']+)'")do node.attr[w]=string.gsub(f,'"','[^\\]\\"')if t(w)then if not l.dd[w]then l.dd[w]={}end;table.insert(l.dd[w],node)end end end;if not k[j]then k[j]={}end;table.insert(k[j],node)if d[o]then if val~=""then table.insert(k[j],{name="textNode",value=val})end;node.children={}j=j-1 else if val~=""then table.insert(node.children,{name="textNode",value=val})end;table.insert(k,node.children)end end end;return l end;local function x(y,z)local k={y}local A=""local function B(C)local D=0;for E in pairs(C)do D=D+1 end;return D end;if not z and B(y.dd)>0 then if y.dd["dd-repeat"]then for F=#y.dd["dd-repeat"],1,-1 do local node=y.dd["dd-repeat"][F]var,array=string.match(node.attr["dd-repeat"],"(.*) in (.*)")node.attr["dd-repeat"]=nil;local G=x({node},true)local H=string.gmatch(G,"{{([^}}]+)}}")local I={}for J in H do if string.match(J,var)then table.insert(I,J)end end;local b=""local K=self.makeFunc(array)for F=1,#K do _ENV[var]=K[F]local L=G;local M=i(L:gsub("^%s*(.-)%s*$","%1"))b=b..x(M)end;node.children={}node.name="textNode"node.value=b end end;if y.dd["dd-if"]then for F=#y.dd["dd-if"],1,-1 do local node=y.dd["dd-if"][F]local N=self.makeFunc(node.attr["dd-if"])if N then node.attr["dd-if"]=nil else local O=table.indexOf(node,node.parent.children)if O then table.remove(node.parent.children,O)end;node=nil;table.remove(y.dd["dd-if"],F)y.dd["dd-if"][F]=nil end end end;if y.dd["dd-init"]then for F=#y.dd["dd-init"],1,-1 do local node=y.dd["dd-init"][F]pcall(load(node.attr["dd-init"],nil,"t",_ENV))node.attr["dd-init"]=nil end end end;while#k~=0 do node=k[#k][1]if not node then break end;if node.name=="textNode"then local val=node.value:gsub("^%s*(.-)%s*$","%1")if not z then val=self.transformClosures(val)end;A=A..val else A=A.."\n"..string.rep(" ",#k-1)A=A.."<"..node.name;if node.attr then for P,f in pairs(node.attr)do if not z then P=self.transformClosures(P)f=self.transformClosures(f)end;A=A.." "..P..'="'..f..'"'end end;if d[node.name]then A=A.."/>"else A=A..">"end end;if node.children and#node.children>0 then table.insert(k,node.children)else table.remove(k[#k],1)if node.children and#node.children==0 and not d[node.name]and not node.name=="textNode"then A=A.."</"..node.name..">"end;while#k>0 and#k[#k]==0 do table.remove(k)if#k>0 then if#k[#k][1].children>1 then A=A.."\n"..string.rep(" ",#k-1).."</"..k[#k][1].name..">"else A=A.."</"..k[#k][1].name..">"end;table.remove(k[#k],1)end end end end;return A:match"^%s*(.-)%s*$"end;function self.transformClosures(Q)local R={}local S=string.gmatch(Q,"{{([^}}]+)}}")for F in S do table.insert(R,F)end;if#R>0 then for F=1,#R do local T=R[F]val=self.makeFunc(T)Q=string.gsub(Q,self.literalize("{{"..T.."}}"),tostring(val))end end;return Q end;function self.literalize(u)return u:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]",function(J)return"%"..J end)end;function self.Read()return x(i(self.template))end;return self end