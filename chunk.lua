Chunk = {}

function Chunk:new()
  o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.generated = 0
  o.value = {}
  for r = 1, 32 do
    o.value[r] = {}
    o.perlin[r] = {}
    for c = 1, 32 do
      o.value[r][c] = 0
      o.perlin[r][c] = 0
    end
  end
  
  return o
end

function Chunk:getValue(r, c)
  return self.value[r][c]
end

function Chunk:setValue(r, c, value)
  self.value[r][c] = value
end
