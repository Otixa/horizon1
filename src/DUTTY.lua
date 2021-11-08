--@class DUTTY
-- Will store all functions here
DUTTY = {}

-- Event Handlers
local handlers = {}

-- Custom Commands
local commands = {}

-- Extracts char at index of string
local function char (str, idx)
  return str:sub(idx, idx)
end

-- Command parser
local function parse (str)
  local command = {}
  local currentQuote = false
  local currentString = ''
  local escaping = false

  for _ = 1, #str do
    -- Gets current char
    local c = char(str, _)

    if escaping == false and currentQuote and c == currentQuote then
      -- Handles quote closing (must match opening quote!)
      table.insert(command, currentString)
      currentQuote = false
      currentString = ''

    elseif escaping == false and #currentString == 0 and (not currentQuote and (c == '"' or c == "'")) then
      -- Handles quote opening
      currentQuote = c

    elseif escaping == false and c == ' ' and currentQuote == false then
      -- Only do separation if we have a string
      if #currentString > 0 then
        -- Handles argument separation
        table.insert(command, currentString)
        currentString = ''
      end

    elseif escaping == false and c == '\\' then
      -- Character escaping
      escaping = true

    else
      -- Disable character escaping after first occurrence
      if escaping then
        escaping = false
      end
      
      -- Adds to current string
      currentString = currentString .. c
    end
  end

  -- If anything is still open, handle it
  if #currentString > 0 then
    table.insert(command, currentString)
  end

  -- Done
  return command
end

-- Handles text input
function DUTTY.input (str)
  -- Invokes all raw text event handlers
  for _, handler in pairs(handlers) do
    if 'function' == type(handler) then
      handler(str)
    end
  end

  -- Parses commands
  local cmdBase = parse(str)
  if #cmdBase > 0 then
    -- Fetches command name and args
    local cmdName = ''
    local cmdArgs = {}
    
    for _, str in pairs(cmdBase) do
      if _ == 1 then cmdName = str:lower()
      else table.insert(cmdArgs, str)
      end
    end

    -- Invokes command
    if commands[cmdName] and 'function' == type(commands[cmdName]) then
      commands[cmdName](table.unpack(cmdArgs))
    end
  end
end

-- Adds event handler to input
function DUTTY.onInput (handler)
  -- Checks for event handler type before adding to list
  if not 'function' == type(handler) then
    error('Event handler must be of type function')
  end

  -- Adds event handler
  table.insert(handlers, handler)
end

-- Adds event handler to commands
function DUTTY.onCommand (command, handler)
  -- Checks for event handler type before adding to list
  if not 'function' == type(handler) then
    error('Event handler must be of type function')
  end

  -- Adds event handler
  commands[command:lower()] = handler
end
