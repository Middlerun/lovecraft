Terrain = {}

function Terrain:new(seed)
  o = {}
  setmetatable(o, self)
  self.__index = self
  
  assert(seed ~= nil)
  o.seed = seed
  o.chunk = {}
  
  return o
end

function Terrain:addChunk(chunk, r, c)
  if self.chunk[r] == nil then self.chunk[r] = {} end
  self.chunk[r][c] = chunk
end

function Terrain:getChunk(r, c)
  assert(self.chunk[r] ~= nil)
  assert(self.chunk[r][c] ~= nil)
  return self.chunk[r][c]
end

function Terrain:setValue(r, c, value)
  relR = r % 32
  relC = r % 32
  chunkR = (r - relR) / 32
  chunkC = (c - relC) / 32
  self:getChunk(chunkR, chunkC):setValue(relR, relC, value)
end

function Terrain:getValue(r, c)
  relR = r % 32
  relC = r % 32
  chunkR = (r - relR) / 32
  chunkC = (c - relC) / 32
  return self:getChunk(chunkR, chunkC):getValue(relR, relC)
end
