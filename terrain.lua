love.filesystem.load("TSerial.lua")()

Terrain = {}

function Terrain:new(seed)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.seed = seed or os.time()
  o.chunk = {}
  o.generationQueue = {}
  o.rMin = -3
  o.rMax = 0
  o.cMin = -2
  o.cMax = 1
  o.entities = {}

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

function Terrain:addEntity(id, y, x)
  if id == nil then return end
  local entity = Entity:new(id, y, x)
  table.insert(self.entities, entity)
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

function Terrain:calculateSunLight()
  for c = self.cMin, self.cMax do
    local topFound = false
    local top
    for r = self.rMin, self.rMax do
      if not topFound and self:hasChunk(r, c) then
        topFound = true
        top = r
      end
    end
    if top >= 0 then break end

    for c2 = 1, 32 do
      local carry = false
      if self:getChunk(r, c):getBlock(1, c2) == AIR then carry = true end
      for r = top, self.rMax do
        if carry and not self:hasChunk(r, c) and r >= 0 then break
        elseif carry then self:getChunk(r, c):setSunLight(1, c2, 16)
        else break end
        if self:hasChunk(r, c) then
          for r2 = 1, 31 do
            if self:getChunk(r, c).sunLight[r2][c2] == 16 and self:getChunk(r, c):getBlock(1, c2) == AIR then
              self:getChunk(r, c):setSunLight(r2+1, c2, 16)
            else
              break
            end
          end
          if self:getChunk(r, c).sunLight[32][c2] == 16 and self:getChunk(r, c):getBlock(32, c2) == AIR then carry = true
          else carry = false end
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
  local chunk_channel = love.thread.getChannel('generator_chunk')
  local command_channel = love.thread.getChannel('generator_command')

  local chunk = chunk_channel:pop()
  if chunk ~= nil then
    chunkNew = TSerial.unpack(chunk)
    chunk = self:getChunk(chunkNew.r, chunkNew.c)
    chunk.block = chunkNew.block
    chunk.generated = true
    chunk.hasDirt = chunkNew.hasDirt
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
          self:getChunk(chunk.r + r, chunk.c + c).changed = true
        end
      end
    end
  end

  local chunkRC = table.remove(self.generationQueue, 1)
  if chunkRC ~= nil then
    local command = {seed = self:getSeed(), r = chunkRC.r, c = chunkRC.c}
    command_channel:push(TSerial.pack(command))
  end
  --end
end

function Terrain:draw(view)
  local skyPos = love.graphics.getHeight()/2 - (view.y - 16) * view.zoom / 2
  if skyPos > 0 then
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, skyPos)
  end
  if skyPos < love.graphics.getHeight() then
    love.graphics.setColor(0, 26, 34, 255)
    love.graphics.rectangle("fill", -1, skyPos, love.graphics.getWidth()+2, love.graphics.getHeight() - skyPos)
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(sky, -1, skyPos, 0, (love.graphics.getWidth()+2)/sky:getWidth(), view.zoom/8, 0, 256)

  local minR = math.max(terrain.rMin, math.floor((view.y - view.zoom * (love.graphics.getHeight() / 2)) / 32))
  local maxR = math.min(terrain.rMax, math.floor((view.y + view.zoom * (love.graphics.getHeight() / 2)) / 32))
  local minC = math.max(terrain.cMin, math.floor((view.x - view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  local maxC = math.min(terrain.cMax, math.floor((view.x + view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  love.graphics.setColor(255, 255, 255, 255)
  for r = minR, maxR do
    for c = minC, maxC do
      if terrain:hasChunk(r, c) then
        terrain:getChunk(r, c):draw(view)
      end
    end
  end
  for i = 1, #self.entities do
    self.entities[i]:draw(view)
  end
end

function Terrain:drawPerlin(view)
  local minR = math.max(terrain.rMin, math.floor((view.y - view.zoom * (love.graphics.getHeight() / 2)) / 32))
  local maxR = math.min(terrain.rMax, math.floor((view.y + view.zoom * (love.graphics.getHeight() / 2)) / 32))
  local minC = math.max(terrain.cMin, math.floor((view.x - view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  local maxC = math.min(terrain.cMax, math.floor((view.x + view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  love.graphics.setColor(255, 255, 255, 255)
  for r = minR, maxR do
    for c = minC, maxC do
      if terrain:hasChunk(r, c) then
        if terrain:getChunk(r, c).framebufferPerlin == nil then terrain:getChunk(r, c):renderPerlin() end
        love.graphics.draw(terrain:getChunk(r, c).framebufferPerlin, (32*c-view.x)*view.zoom + love.graphics.getWidth()/2, (32*r-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
      end
    end
  end
end
