Terrain = {}

function Terrain:new(seed)
  o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.seed = seed or os.time()
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

function Terrain:hasChunk(r, c)
  return self.chunk[r] ~= nil and self.chunk[r][c] ~= nil
end

function Terrain:setBlock(r, c, block)
  relR = (r - 1) % 32 + 1
  relC = (c - 1) % 32 + 1
  chunkR = (r - relR) / 32
  chunkC = (c - relC) / 32
  if self:hasChunk(chunkR, chunkC) then
    self:getChunk(chunkR, chunkC):setBlock(relR, relC, block)
  end
end

function Terrain:getBlock(r, c)
  relR = (r - 1) % 32 + 1
  relC = (c - 1) % 32 + 1
  chunkR = (r - relR) / 32
  chunkC = (c - relC) / 32
  if self:hasChunk(chunkR, chunkC) then
    return self:getChunk(chunkR, chunkC):getBlock(relR, relC)
  else
    return 0
  end
end

function Terrain:getSeed()
  return self.seed
end
