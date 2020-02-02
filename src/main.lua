local parser = require 'src.parser'
local util = require 'src.util'

local version = "0.2"

local opts = { mem = false, hex = true, mod = true, ill = true, upp = true }
-- [memory-address] [hex representation] [instruction] [arguments] ([mode]; [illegal])
-- upp -> uppercase

function main(args)

  local filepath = ""

  if #args == 0 then
    io.write(
      "usage: main.lua <optional flags> <file>\n" +
      "\n" +
      "flags:\n" +
      "  -u, --uppercase    " + "Turns all instructions and hex values to uppercase (default)\n" + 
      "  -l, --lowercase    " + "Turns all instructions and hex values to lowercase\n" + 
      "  -h, --hex          " + "Turns ON the hex output\n" + 
      "  -H, --no-hex       " + "Turns OFF the hex output\n" + 
      "  -i, --illegal      " + "Display 'illegal' after all illegal instructions\n" + 
      "  -I, --no-illegal   " + "Turns --illegal OFF\n" + 
      "  -m, --mode         " + "Display the addressing mode for each instruction\n" +
      "  -M, --no-mode      " + "Turns --mode OFF\n" +
      "  -a, --address      " + "Display memory addresses in front of everything else\n" +
      "  -A, --no-address   " + "Turns --address OFF\n" +
      "  -r, --reset        " + "Reset all options to OFF\n" + 
      "  -R, --reset-on     " + "Reset all options to ON\n" + 
      "  -v, --version      " + "Print version\n" +
      "\n" +
      "generally flags in upper case can be used to turn off the corresponding lower case flag\n" +
      "\n" +
      "format:  [memory] [hex] [instruction] [arguments] ([mode]; [illegal])\n" +
      "default: -uhimA (--uppercase, --hex, --illegal, --mode, --no-address)\n"
    )
    return
  elseif #args >= 1 then
    -- parse command line flags and save to opts table
    
    filepath = args[#args]
    local flags = args

    -- if lua is used to invoke this file the arg table will look like this:
    -- { -1 = "lua", 0 = "<.../main.lua>", 1 = "<flags>", 2 = "<nes file>" }
    table.removekey(flags, -1) -- remove "lua" (key -1)
    table.removekey(flags, 0) -- remove "<lua filepath>" (key 0)

    -- there are three total possibilities:
    -- 1. invoked without any flags / options, just the filepath
    -- 2. invoked with flags / options followed by filepath
    -- 3. invoked without any flags / options, except -v / --version, filepath is omitted
    -- it is not really clear wether option 1 or 3 was used. 
    if #args >= 2 or not(args[#args]:starts_with('-')) then -- 2. / 1.
      table.removekey(flags, #args) -- remove "<nes file>" as it is already saved to filepath
    end
    -- this means that filepaths cannot start with a "-".

    -- using removekey (see util.lua) as it does no reordering inside the table which is what
    -- I want as I don't want to have to adapt the indizes from which to remove from depending
    -- on the order of the remove operation.
    io.write(util.serializeTable(flags))
    io.write("\n")
    io.write(filepath)

    for key,value in pairs(flags) do

      if value:starts_with("--") then

        -- io.write(value + "\n")

        if value:starts_with("--version") then
          io.write("version: " + version + "\n")
          return
        end

        if value == "--uppercase" then    opts.upp = true end
        if value == "--lowercase" then    opts.upp = false end
        if value == "--hex" then          opts.hex = true end
        if value == "--no-hex" then       opts.hex = false end
        if value == "--illegal" then      opts.ill = true end
        if value == "--no-illegal" then   opts.ill = false end
        if value == "--mode" then         opts.mod = true end
        if value == "--no-mode" then      opts.mod = false end
        if value == "--address" then      opts.mem = true end
        if value == "--no-address" then   opts.mem = false end

        if value == "--reset" then
          opts.upp = false
          opts.hex = false
          opts.ill = false
          opts.mod = false
          opts.mem = false
        end

        if value == "--reset-on" then
          opts.upp = true
          opts.hex = true
          opts.ill = true
          opts.mod = true
          opts.mem = true
        end

      elseif value:starts_with("-") then

        for i = 2, #value do
          local flag = value:sub(i, i)
          -- io.write(flag + "\n")

          if flag == "v" then
            io.write("version: " + version + "\n")
            return
          end

          if flag == "u" then opts.upp = true end
          if flag == "l" then opts.upp = false end
          if flag == "h" then opts.hex = true end
          if flag == "H" then opts.hex = false end
          if flag == "i" then opts.ill = true end
          if flag == "I" then opts.ill = false end
          if flag == "m" then opts.mod = true end
          if flag == "M" then opts.mod = false end
          if flag == "a" then opts.mem = true end
          if flag == "A" then opts.mem = false end

          if flag == "r" then
            opts.upp = false
            opts.hex = false
            opts.ill = false
            opts.mod = false
            opts.mem = false
          end

          if flag == "R" then
            opts.upp = true
            opts.hex = true
            opts.ill = true
            opts.mod = true
            opts.mem = true
          end
        end
      else
        io.write("invalid command line options\n")
        return
      end
    end

    -- in case the parsed command line options need to be debugged uncomment below
    -- io.write(serializeTable(opts))

  end

  local input = util.load(filepath)
  local definition, err = parser.parse_definition()

  if not err then
    parser.parse(definition, input, opts)
  end

end

util.string_meta()
main(arg)