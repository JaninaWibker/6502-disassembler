function lpad(s, l, c)
  local res = string.rep(c or ' ', l - #s) .. s
  return res, res ~= s
end

-- pad the right side
function rpad(s, l, c)
  local res = s .. string.rep(c or ' ', l - #s)
  return res, res ~= s
end

-- turn signed integer encoded using twos_complement into signed integer
function decode_twos_complement(bits) -- 8 bits is assumed
  local mask = 128
  return -(bits & mask) + (bits & ~mask)
end

function id(tbl)
  return tbl
end

function map(tbl, functor)
  for k,v in pairs(tbl) do
    tbl[k] = functor(k, v)
  end
  return tbl
end

function foreach(tbl, functor)
  for k,v in pairs(tbl) do
    functor(k, v)
  end
  return tbl
end

function reverse(tbl)
  local t={table.unpack(tbl)}
  for i=1, math.floor(#tbl / 2) do
    local tmp = tbl[i]
    t[i] = tbl[#tbl - i + 1]
    t[#tbl - i + 1] = tmp
  end
  return t
end

function string_meta()

  local meta = getmetatable('')

  meta.__add = function(a, b)
    return a..b
  end

  meta.__sub = function(a, b)
    return a:gsub(b, "")
  end

  meta.__call = function(str, ...)
    local rest = {...}

    if type(rest[1]) ~= 'table' then
      local t={}
      for k,v in ipairs(rest) do
        t[k] = string.sub(str, v, v)
      end
      return table.concat(t)
    else
      local start = rest[1][1]
      local stop = rest[1][2]
      if(stop == nil and start > 0) then        -- "abcd"{3} => "abc"
        return string.sub(str, 1, start)
      elseif (stop == nil and start < 0) then  -- "abcd"{-2} => "b"
        return string.sub(str, -start, -start)
      elseif stop == 0 then                    -- "abcd"{2, 0} => "bcd"
        return string.sub(str, start, #str)
      elseif stop > 0 and start > 0 then       -- "abcd"{2,3} => "bc"
        return string.sub(str, start, stop)
      else
        return ""
      end
    end
  end

  function string:bin(str)
    if #self == 1 then
      return string.byte(self)
    else
      local t={}
      for i=1,#self,1 do
        t[i] = string.byte(self, i)
      end
      return t
    end
  end

  function string:bytes(str)
    local t={}
    for i=1,#self,1 do
      t[i] = string.byte(self, i)
    end
    return t
  end

end

function load(filename)
  return assert(io.open(filename), "rb")
end

function serializeTable(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep(" ", depth)

  if name then tmp = tmp .. name .. " = " end

  if type(val) == "table" then
      tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

      for k, v in pairs(val) do
          tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
      end

      tmp = tmp .. string.rep(" ", depth) .. "}"
  elseif type(val) == "number" then
      tmp = tmp .. tostring(val)
  elseif type(val) == "string" then
      tmp = tmp .. string.format("%q", val)
  elseif type(val) == "boolean" then
      tmp = tmp .. (val and "true" or "false")
  else
      tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
  end

  return tmp
end

-- this allows removing key-value pairs from tables by keys
function table.removekey(table, key)
  local element = table[key]
  table[key] = nil
  return element
end

return {
  id = id,
  map = map,
  foreach = foreach,
  reverse = reverse,
  rpad = rpad,
  lpad = lpad,
  decode_twos_complement = decode_twos_complement,
  string_meta = string_meta,
  load = load,
  serializeTable = serializeTable
}