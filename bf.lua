local bf = {}

function bf:new(code)
  local obj = { code }
  
  obj.code = code
  
  self.__index = self
  return setmetatable(obj, self)
end
-- validate brainfuck code
-- return 0 if code is valid
-- return > 0 if opening bracket(s) missing
-- return < 0 if closing bracket(s) missing
function bf:validate()
  local len, brackets = string.len(self.code), 0
  for i = 1, len do
    local char = string.byte(self.code, i)
    if char == 91 then brackets = brackets + 1 -- 91 equ [
    elseif char == 93 then brackets = brackets - 1 end -- 93 equ ]
  end
  
  return brackets
end

function bf:getError(errorCode)
  if errorCode == 0 then
    return "Code is valid"
  elseif errorCode > 0 then
    return "Error: Opening bracket(s) missing"
  elseif errorCode < 0 then
    return "Error: Closing bracket(s) missing"
  else
    return "Error: Unknown error"
  end
end

function bf:run()
  errorCode = self:validate()
  if errorCode ~= 0 then
    return self:getError(errorCode)
  end
  
  local memSize, range = 30000, 256
  -- lvl is loop depth level
  local mem, ptr, lvl = {}, 0, 0
  
  -- clear memory
  for i = 0, memSize do mem[i] = 0 end
  
  -- run program
  local i, len = 0, string.len(self.code)
  while i <= len do
    i = i + 1
    
    local char = string.byte(self.code, i)
    -- 43 equ +
    if char == 43 then mem[ptr] = (mem[ptr] + 1) % range
    -- 45 equ -
    elseif char == 45 then
      if mem[ptr] > 0 then mem[ptr] = mem[ptr] - 1
      else mem[ptr] = range - 1 end
    -- 44 equ ,
    elseif char == 44 then mem[ptr] = string.byte(io.stdin:read("*L"), 1)
    -- 46 equ .
    elseif char == 46 then io.stdout:write(string.char(mem[ptr]))
    -- 60 equ <
    elseif char == 60 then
      ptr = ptr - 1
      if ptr < 0 then ptr = memSize end
    -- 62 equ >
    elseif char == 62 then
      ptr = ptr + 1
      if ptr > memSize then ptr = 0 end
    -- 91 equ [
    elseif char == 91 then 
      if mem[ptr] == 0 then
        while string.byte(self.code, i) ~= 93 or lvl > 0 do
          i = i + 1
          if string.byte(self.code, i) == 91 then lvl = lvl + 1 end
          if string.byte(self.code, i) == 93 then lvl = lvl - 1 end
        end
      end
    -- 93 equ [
    elseif char == 93 then
      if mem[ptr] ~= 0 then
        while (string.byte(self.code, i) ~= 91) or (lvl > 0) do
            i = i - 1
            if string.byte(self.code, i) == 91 then lvl = lvl - 1 end
            if string.byte(self.code, i) == 93 then lvl = lvl + 1 end
        end
      end
    end
  end
end

return bf