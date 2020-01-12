local parser = require 'src.parser'
local util = require 'src.util'

local opts = { mem = false, hex = true, mod = true, ill = true, upp = true }
-- [memory-address] [hex representation] [instruction] [arguments] ([mode]; [illegal])
-- upp -> uppercase

function main(args)

  local filepath = ""

  if #args == 0 then
    io.write("usage: main.lua <optional flags> <file>")
    return
  elseif #args >= 2 then
    -- parse command line flags and save to opts table
    filepath = args[#args]
    local flags = args
    -- if lua is used to invoke this file the arg table will look like this:
    -- { -1 = "lua", 0 = "<.../main.lua>", 1 = "<flags>", 2 = "<nes file>" }
    table.removekey(flags, -1) -- remove "lua" (key -1)
    table.removekey(flags, 0) -- remove "<lua filepath>" (key 0)
    table.removekey(flags, #args) -- remove "<nes file>" as it is already saved to filepath
    -- using removekey (see util.lua) as it does no reordering inside the table which is what
    -- I want as I don't want to have to adapt the indizes from which to remove from depending
    -- on the order of the remove operation.
    io.write(util.serializeTable(flags))
    
    return
  else
    filepath = args[1]
  end

  local input = util.load(filepath)
  local definition, err = parser.parse_definition()

  if not err then
    parser.parse(definition, input, opts)
  end

end

util.string_meta()
main(arg)