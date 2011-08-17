love.filesystem.load("TSerial.lua")()

Terrain = {}

function Terrain:new(seed)
  o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.seed = seed or os.time()
  o.chunk = {}
  o.generationQueue = {}
  o.rMin = -2
  o.rMax = 1
  o.cMin = -2
  o.cMax = 1
  
  return o
end

function Terrain:addChunk(chunk, r, c)
  if r < self.rMin then self.rMin = r end
  if r > self.rMax then self.rMax = r end
  if c < self.cMin then self.cMin = c end
  if c > self.cMax then self.cMax = c end
  if self.chunk[r] == nil then self.chunk[r] = {} end
  self.chunk[r][c] = chunk
  self.chunk[r][c].terrain = self
  self.chunk[r][c].r = r
  self.chunk[r][c].c = c
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
  local relR = (r - 1) % 32 + 1
  local relC = (c - 1) % 32 + 1
  local chunkR = (r - relR) / 32
  local chunkC = (c - relC) / 32
  if self:hasChunk(chunkR, chunkC) then
    self:getChunk(chunkR, chunkC):setBlock(relR, relC, block)
  end
end

function Terrain:getBlock(r, c)
  local relR = (r - 1) % 32 + 1
  local relC = (c - 1) % 32 + 1
  local chunkR = (r - relR) / 32
  local chunkC = (c - relC) / 32
  if self:hasChunk(chunkR, chunkC) then
    return self:getChunk(chunkR, chunkC):getBlock(relR, relC)
  else
    return UNGENERATED
  end
end

function Terrain:getSeed()
  return self.seed
end

function Terrain:generateInitial()
  for r = self.rMin, self.rMax do
    for c = self.cMin, self.cMax do
      chunk = Chunk:new()
      chunk:generate(self:getSeed(), r, c)
      terrain:addChunk(chunk, r, c)
      for r = 0, 1 do
        for c = -1, 1 do
          if self:hasChunk(chunk.r + r, chunk.c + c) then
            self:getChunk(chunk.r + r, chunk.c + c):generateTrees()
         end
        end
      end
      for r = -1, 1 do
        for c = -1, 1 do
          if self:hasChunk(chunk.r + r, chunk.c + c) then
            self:getChunk(chunk.r + r, chunk.c + c):render()
          end
        end
      end
    end
  end
end

function Terrain:generate(r, c)
  if self:hasChunk(r, c) then return
  else
    table.insert(self.generationQueue, {r = r, c = c})
    terrain:addChunk(Chunk:new(), r, c)
  end
end

function Terrain:checkGenerator()
  local chunk = generator:receive("chunk")
  if chunk ~= nil then
    chunkNew = TSerial.unpack(chunk)
    chunk = self:getChunk(chunkNew.r, chunkNew.c)
    for r = 1, 32 do
      for c = 1, 32 do
        chunk.block[r][c] = chunkNew.block[r][c]
        chunk.perlin[r][c] = chunkNew.perlin[r][c]
        chunk.coalNoise[r][c] = chunkNew.coalNoise[r][c]
      end
    end
    chunk.generated = true
    chunk:renderPerlin()
    for r = 0, 1 do
      for c = -1, 1 do
        if self:hasChunk(chunk.r + r, chunk.c + c) then
          self:getChunk(chunk.r + r, chunk.c + c):generateTrees()
        end
      end
    end
    for r = -1, 1 do
      for c = -1, 1 do
        if self:hasChunk(chunk.r + r, chunk.c + c) then
          self:getChunk(chunk.r + r, chunk.c + c):render()
        end
      end
    end
  end
  if generator:peek("ready") then
    local chunkRC = table.remove(self.generationQueue, 1)
    if chunkRC ~= nil then
      local command = {seed = self:getSeed(), r = chunkRC.r, c = chunkRC.c}
      generator:send("command", TSerial.pack(command))
    end
  end
end
