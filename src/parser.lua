local json = require 'dkjson'
local util = require 'src.util'

function parse_nes_header(header)
  assert(header{1,3} == "NES")
  assert(header(4) == '\x1a')

  -- print(table.unpack(header{1,4}:bin()))
  -- print(header(4):bin())

  local prg_size = header(5):byte() * 16
  local chr_size = header(6):byte() * 8
  local is_trainer = (header(7):byte() & 0x4) == 1
  local mapper = (header(7):byte() & 0xF0) | (header(8):byte() & 0xF0)

  return prg_size, chr_size, mapper, is_trainer
end

function find_instruction_by_opcode(definition, opcode)
  for mnemonic,obj in pairs(definition) do
    for i=1,#obj,1 do
      if obj[i][4] == opcode then -- modify if additional fields are added
        return mnemonic, table.unpack(obj[i])
      end
    end
  end
  print("opcode not found... (0x" .. string.format("%02X", opcode) .. ")")
end

function hex_transformer(definition)
  for k1,v1 in pairs(definition) do
    for k2,v2 in pairs(v1) do
      for k3,v3 in pairs(v2) do
        if(k3 == 4) then -- modify if additional fields are added
          definition[k1][k2][k3] = tonumber(v3, 16)
        end
      end
    end
  end
  return definition
end

function parse_definition()

  local definition, pos, err = json.decode(util.load('src/6502-asm.json'):read('*all'), 1, nil)
  if err then
    print("Error:", err, pos)
    return nil, err
  else
    return hex_transformer(definition)
  end
end

--- 
-- this is the main parser function, it is the most important and utilizes all the functions above
---

function parse(definition, input, opts)
  local prg_size, chr_size, mapper, is_trainer = parse_nes_header(input:read(16))

  if is_trainer then
    input:read(512)
  end

  local offset = 1

  while offset <= prg_size * 1024 do

    local opcode = input:read(1):byte()
    local mnemonic, mode, illegal, format, hex, length, time = find_instruction_by_opcode(definition, opcode)

    local str = format
    if opts.upp then
      str = string.upper(str)
    else
      str = string.lower(str)
    end
    local args = {}

    if length - 1 > 0 then
      args = util.reverse(input:read(length-1):bytes()) -- big endian -> small endian
    end

    for k,v in pairs(args) do
      str = string.gsub(str, "%?%?", string.format("%02" + (opts.upp and "X" or "x"), v), 1)
    end

    -- [memory-address] [hex representation] [instruction] [arguments] ([mode]; [illegal])
    if opts.mem then
      io.write('XXXXXX ')
    end

    if opts.hex then
      local str, changed = util.rpad(string.format("%02" + (opts.upp and "X" or "x"), opcode) .. " " .. (table.concat(args, " ")), 12, ' ')
      io.write(str)
    end

    io.write((util.rpad(str, 16, ' ')))

    if opts.mod and opts.ill then
      io.write("(" .. mode .. (illegal == "illegal" and (" : " .. illegal) or "") .. ")")
    elseif opts.mod and not opts.ill then
      io.write("(" .. mode .. ")")
    elseif opts.ill and not opts.mod then
      if(illegal == "illegal") then
        io.write("(" .. illegal .. ")")
      end
    end

    io.write("\n")

    offset = offset + length

  end
end

return {
  parse_nes_header = parse_nes_header,
  find_instruction_by_opcode = find_instruction_by_opcode,
  hex_transformer = hex_transformer,
  parse_definition = parse_definition,
  parse = parse
}