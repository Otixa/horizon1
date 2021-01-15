--@class DynamicDocument
function DynamicDocument(template)
    local self = {}
    self.template = template or ""
    local buffer = ""
    local callbacks = {}
    self.tree = {}

    local emptyTags = {
        br = true,
        hr = true,
        img = true,
        embed = true,
        param = true,
        area = true,
        col = true,
        input = true,
        meta = true,
        link = true,
        base = true,
        basefont = true,
        iframe = true,
        isindex = true,
        circle = true,
        polygon = true,
        polyline = true,
        ellipse = true,
        path = true,
        line = true,
        rect = true,
        use = true
    }

    function table.indexOf(val, table)
        for k, v in ipairs(table) do
            if v == val then return k end
        end
        return nil
    end

    function self.makeFunc(string)
        local val = "nil"
        if callbacks[string] == nil then
            local e, f = pcall(load("return function() return "..string.." end", nil, "t", _ENV))
            if e then
                callbacks[string] = f
                val = f()
                if type(val) == "function" then
                    callbacks[string] = f()
                    val = val()
                end
            end
        else
            val = callbacks[string]()
        end
        return val
    end

    local function parseTemplate(template)
        local level = 0
        local stack = {}
        local tree = {}
        tree.dd = {}
        table.insert(stack, tree)
        local node = {}

        for b, op, tag, attr, op2, bl1, val, bl2 in string.gmatch(template, "(<)(%/?!?)([%w:_-'\\\"%[]+)(.-)(%/?%-?)>([%s\r\n\t]*)([^<]*)([%s\r\n\t]*)") do
            tag = string.lower(tag)
            if op == "/" then
                if level==0 then return tree end
                level = level - 1
                table.remove(stack)
            else
                local function isDdAttr(str)
                    local dd = "dd-"
                    return str:sub(1, #dd) == dd
                end
                level = level + 1
                node = {}
                node.name = tag
                node.children = {}
                node.attr = {}
                if stack[level-1] then 
                    node.parent = stack[level-1][#stack[level-1]]
                else
                    node.parent = nil
                end
        
                if attr ~= "" then
                    for n, v in string.gmatch(attr, "%s([^%s=]+)=\"([^\"]+)\"") do
                        node.attr[n] = string.gsub(v, '"', '[^\\]\\"')
                        if isDdAttr(n) then
                            if not tree.dd[n] then tree.dd[n] = {} end
                            table.insert(tree.dd[n], node)
                        end
                    end
                    for n, v in string.gmatch(attr, "%s([^%s=]+)='([^']+)'") do
                        node.attr[n] = string.gsub(v, '"', '[^\\]\\"')
                        if isDdAttr(n) then
                            if not tree.dd[n] then tree.dd[n] = {} end
                            table.insert(tree.dd[n], node)
                        end
                    end
                end
        
                if not stack[level] then stack[level] = {} end
                table.insert(stack[level], node)
                if emptyTags[tag] then
                    if val ~= "" then
                        table.insert(stack[level], {
                            name = "textNode",
                            value = val
                        })
                    end
                    node.children = {}
                    level = level - 1
                else
                    if val ~= "" then
                        table.insert(node.children, {
                            name = "textNode",
                            value = val
                        })
                    end
                    table.insert(stack, node.children)
                end
            end
        end
        return tree
    end

    local function recompose(data, skipTransforms)
        local stack = {data}
        local d = ""

        local function getLength(T)
            local count = 0
            for _ in pairs(T) do count = count + 1 end
            return count
        end

        if not skipTransforms and getLength(data.dd) > 0 then
            if data.dd["dd-repeat"] then
                for i=#data.dd["dd-repeat"],1,-1 do
                    local node = data.dd["dd-repeat"][i]
                    var, array = string.match(node.attr["dd-repeat"], "(.*) in (.*)")
                    node.attr["dd-repeat"] = nil
                    local precomposed = recompose({node}, true)
                    local tmp = string.gmatch(precomposed, "{{([^}}]+)}}")
                    local closures = {}
                    for c in tmp do
                        if string.match(c, var) then table.insert(closures, c) end
                    end
                    local buffer = ""
                    local arr = self.makeFunc(array)
                    for i=1,#arr do
                        _ENV[var] = arr[i]
                        local repeatBuffer = precomposed
                        local reparsed = parseTemplate(repeatBuffer:gsub("^%s*(.-)%s*$", "%1"))
                        buffer = buffer .. recompose(reparsed)
                    end
                    node.children = {}
                    node.name = "textNode"
                    node.value = buffer
                end
            end
            if data.dd["dd-if"] then
                for i=#data.dd["dd-if"],1,-1 do
                    local node = data.dd["dd-if"][i]
                    local pred = self.makeFunc(node.attr["dd-if"])

                    if pred then
                        node.attr["dd-if"] = nil
                    else
                        local ref = table.indexOf(node, node.parent.children)
                        if ref then
                            table.remove(node.parent.children, ref)
                        end
                        node = nil
                        table.remove(data.dd["dd-if"], i)
                        data.dd["dd-if"][i] = nil
                    end
                end
            end
            if data.dd["dd-init"] then
                for i=#data.dd["dd-init"],1,-1 do
                    local node = data.dd["dd-init"][i]
                    pcall(load(node.attr["dd-init"], nil, "t", _ENV))
                    node.attr["dd-init"] = nil
                end
            end
        end

        while #stack ~= 0 do
            node = stack[#stack][1]
            if not node then break end
            if node.name == "textNode" then
                local val = node.value:gsub("^%s*(.-)%s*$", "%1")
                if not skipTransforms then val = self.transformClosures(val) end
                d = d..val
            else
                d = d.."\n"..string.rep (" ", #stack-1)
                d = d.."<"..node.name
                if node.attr then
                    for a, v in pairs(node.attr) do
                        if not skipTransforms then
                            a = self.transformClosures(a)
                            v = self.transformClosures(v)
                        end
                        d = d.." "..a..'="'..v..'"'
                    end
                end
                if emptyTags[node.name] then d = d.."/>" else d = d..">" end
            end
            
            if node.children and #node.children > 0 then
                table.insert(stack, node.children)
            else
                table.remove(stack[#stack], 1)
                if node.children and #node.children == 0 and not emptyTags[node.name] and not node.name == "textNode" then
                    d = d.."</"..node.name..">"
                end
                while #stack > 0 and #stack[#stack] == 0 do
                    table.remove(stack)
                    if #stack > 0 then
                        if #stack[#stack][1].children > 1 then
                            d = d.."\n"..string.rep(" ", #stack-1).."</"..stack[#stack][1].name..">"
                        else
                            d = d.."</"..stack[#stack][1].name..">"
                        end
                        table.remove(stack[#stack], 1)
                    end
                end
            end
        end
        return d:match "^%s*(.-)%s*$"
    end

    function self.transformClosures(chunk)
        local out = {}
        local matches = string.gmatch(chunk, "{{([^}}]+)}}")
        for i in matches do 
            table.insert(out, i) 
        end
        if #out > 0 then
            for i=1,#out do
                local cl = out[i]
                val = self.makeFunc(cl)
                chunk = string.gsub(chunk, self.literalize("{{"..cl.."}}"), tostring(val))
            end
        end
        return chunk
    end

    function self.literalize(str)
        return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
    end

    function self.Read()
        return recompose(parseTemplate(self.template))
    end
    return self
end

