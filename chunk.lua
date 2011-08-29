Chunk = {}

function Chunk:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.generated = false
  o.treesGenerated = false
  o.r = nil
  o.c = nil
  o.terrain = nil
  o.block = {}
  o.perlin = {}
  o.coalNoise = {}
  for r = 1, 32 do
    o.block[r] = {}
    o.perlin[r] = {}
    o.coalNoise[r] = {}
    for c = 1, 32 do
      o.block[r][c] = UNGENERATED
      o.perlin[r][c] = 0
    end
  end
  o.hasDirt = false
  o.changed = true
  
  return o
end

function Chunk:generate(seed, chunkR, chunkC)
  if chunkR < -3 then
    for r = 1, 32 do
      self.block[r] = {}
      self.perlin[r] = {}
      for c = 1, 32 do
        self.block[r][c] = AIR
        self.perlin[r][c] = 0
      end
    end
  
  else

    self.perlin = self:generatePerlin(seed, chunkR, chunkC)
    
    local absR
    local absC
    
    self.block = {}
    for r = 1, 32 do
      absR = chunkR * 32 + r
      self.block[r] = {}
      dirtMargin = (128 - absR) * 0.01
      for c = 1, 32 do
        absC = chunkC * 32 + c
        value = self.perlin[r][c]
        if absR < 0 then
          value = value - absR * 0.02
        end
        
        if value > 0.5 then self.block[r][c] = AIR
        elseif value > 1.4 - dirtMargin or value < -0.6 then
          self.block[r][c] = DIRT
          self.hasDirt = true
        else self.block[r][c] = STONE
        end
        
        if self.block[r][c] == STONE and self.coalNoise[r][c] > 0.08 then self.block[r][c] = COAL_ORE end
      end
    end
  end
  self.generated = true
  self.changed = true
  self.r = chunkR
  self.c = chunkC
end

function Chunk:generatePerlin(seed, chunkR, chunkC)
  local persistence = 0.55
  local N = 6
  local amplitude = 1
  local compInterp
  local compAmplitude
  local comp
  local data = {}
  for r = 1, 32 do
    data[r] = {}
    for c = 1, 32 do
      data[r][c] = 0
    end
  end
  for i = N, 1, -1 do
    compInterp = 2^(i-1)
    compAmplitude = amplitude * persistence^(N-i)
    comp = self:perlinComponent2D(seed+i*571, chunkR, chunkC, compInterp, compAmplitude)
    for r = 1, 32 do
      for c = 1, 32 do
        data[r][c] = data[r][c] + comp[r][c]
      end
    end
    if i == 3 then self.coalNoise = comp end
  end
  return data
end

function Chunk:perlinComponent2D(seed, chunkR, chunkC, N, amplitude)
  
  local topEdge1    = chunkR * 32 + 1
  local bottomEdge1 = (chunkR + 1) * 32 + 1
  local leftEdge1   = chunkC * 32 + 1
  local rightEdge1  = (chunkC + 1) * 32 + 1
  
  local topEdge2    = math.floor((topEdge1    - 1) / N) - 1
  local bottomEdge2 = math.ceil ((bottomEdge1 - 1) / N) + 1
  local leftEdge2   = math.floor((leftEdge1   - 1) / N) - 1
  local rightEdge2  = math.ceil ((rightEdge1  - 1) / N) + 1
  
  local rawData = {}
  local finalData = {}
  for r = topEdge2, bottomEdge2 do
    rawData[r - topEdge2 + 1] = {}
    for c = leftEdge2, rightEdge2 do
      rawData[r - topEdge2 + 1][c - leftEdge2 + 1] = amplitude * rand:get(seed + r, c)
    end
  end
  
  local interpData = self:interpolate2D(rawData, chunkR, chunkC, N)
  for r = 1, 32 do
    finalData[r] = {}
    for c = 1, 32 do
      finalData[r][c] = interpData[r][c]
    end
  end
  return finalData
end

function Chunk:interpolate2D(values, chunkR, chunkC, N)
  
  local topEdge1    = chunkR * 32 + 1
  local bottomEdge1 = (chunkR + 1) * 32 + 1
  local leftEdge1   = chunkC * 32 + 1
  local rightEdge1  = (chunkC + 1) * 32 + 1
  
  local topEdge2    = math.floor((topEdge1    - 1) / N) - 1
  local bottomEdge2 = math.ceil ((bottomEdge1 - 1) / N) + 1
  local leftEdge2   = math.floor((leftEdge1   - 1) / N) - 1
  local rightEdge2  = math.ceil ((rightEdge1  - 1) / N) + 1
  
  local newData1 = {}
  local min
  local max
  for r = 1, #values do
    newData1[r] = {}
    for c = 1, #values[r] - 3 do
      P = (values[r][c+3] - values[r][c+2]) - (values[r][c] - values[r][c+1])
      Q = (values[r][c]   - values[r][c+1]) - P
      R = (values[r][c+2] - values[r][c])
      S = values[r][c+1]
      min = math.max(leftEdge1  - 1, (leftEdge2 + c)     * N) % N + 1
      max = math.min(rightEdge1 - 1, (leftEdge2 + c + 1) * N) % N + N + 1
      for j = min, max-1 do
        x = j/N
        table.insert(newData1[r], P*x^3 + Q*x^2 + R*x + S)
      end
    end
  end
  assert(#newData1[1] == 32, "wrong length. chunkR="..chunkR.." chunkC="..chunkC.." N="..N)
  
  local newData2 = {}
  for r = 1, 32 do
    newData2[r] = {}
  end
  for c = 1, 32 do
    rowCount = 0
    for r = 1, #newData1 - 3 do
      P = (newData1[r+3][c] - newData1[r+2][c]) - (newData1[r][c] - newData1[r+1][c])
      Q = (newData1[r][c]   - newData1[r+1][c]) - P
      R = (newData1[r+2][c] - newData1[r][c])
      S = newData1[r+1][c]
      min = math.max(topEdge1    - 1, (topEdge2 + r)        * N) % N + 1
      max = math.min(bottomEdge1 - 1, (bottomEdge2 + r + 1) * N) % N + N + 1
      for j = min, max-1 do
        x = j/N
        rowCount = rowCount + 1
        newData2[rowCount][c] = P*x^3 + Q*x^2 + R*x + S
      end
    end
  end
  
  for r = 1, 32 do
    for c = 1, 32 do
      assert(newData2[r][c] ~= nil, "nil value, r="..r.." c="..c.." N="..N)
    end
  end
  
  return newData2
end

function Chunk:getBlock(r, c)
  if not self.generated then return UNGENERATED end
  if r < 1 or r > 32 or c < 1 or c > 32 then
    return self.terrain:getBlock(self.r * 32 + r, self.c * 32 + c)
  end
  return self.block[r][c]
end

function Chunk:setBlock(r, c, block)
  if not self.generated then return end
  if r < 1 or r > 32 or c < 1 or c > 32 then
    self.terrain:setBlock(self.r * 32 + r, self.c * 32 + c, block)
    return
  elseif block ~= AIR and block ~= LEAVES and self:getBlock(r+1, c) == GRASS then self:setBlock(r+1, c, DIRT)
  end
  self.block[r][c] = block
  self.changed = true
  if r == 1  and self.terrain:hasChunk(self.r-1, self.c) then self.terrain:getChunk(self.r-1, self.c).changed = true end
  if r == 32 and self.terrain:hasChunk(self.r+1, self.c) then self.terrain:getChunk(self.r+1, self.c).changed = true end
  if c == 1  and self.terrain:hasChunk(self.r, self.c-1) then self.terrain:getChunk(self.r, self.c-1).changed = true end
  if c == 32 and self.terrain:hasChunk(self.r, self.c+1) then self.terrain:getChunk(self.r, self.c+1).changed = true end
end

function Chunk:isGenerated()
  return self.generated
end

function Chunk:render()
  if self.framebuffer == nil then
    self.framebuffer = love.graphics.newFramebuffer(512, 512)
    self.framebuffer:setFilter("linear", "nearest")
  end
  if not self.generated then return end
  love.graphics.setRenderTarget(self.framebuffer)
  love.graphics.setColor(255, 255, 255, 255)
  local num, base
  for r = 1, 32 do
    for c = 1, 32 do
      if self.block[r][c] ~= AIR and self.block[r][c] ~= UNGENERATED then
        num = 1
        if joinsTo(self.block[r][c], self:getBlock(r-1, c), UP)    then num = num + 1 end
        if joinsTo(self.block[r][c], self:getBlock(r, c+1), RIGHT) then num = num + 2 end
        if joinsTo(self.block[r][c], self:getBlock(r+1, c), DOWN)  then num = num + 4 end
        if joinsTo(self.block[r][c], self:getBlock(r, c-1), LEFT)  then num = num + 8 end
        base = tileBase(self.block[r][c])
        if base ~= nil then love.graphics.draw(images[base][num], (c-1)*16, (r-1)*16) end
        love.graphics.draw(images[self.block[r][c]][num], (c-1)*16, (r-1)*16)
      end
    end
  end
  love.graphics.setRenderTarget()
  self.changed = false
end

function Chunk:renderPerlin()
  if self.framebufferPerlin == nil then
    self.framebufferPerlin = love.graphics.newFramebuffer(512, 512)
    self.framebufferPerlin:setFilter("linear", "nearest")
  end
  if not self.generated then return end
  love.graphics.setRenderTarget(self.framebufferPerlin)
  love.graphics.setColor(255, 255, 255, 255)
  for r = 1, 32 do
    for c = 1, 32 do
      if self.block[r][c] ~= AIR then
        love.graphics.setColor(128 + 80 * self.perlin[r][c], 128 + 80 * self.perlin[r][c], 128 + 80 * self.perlin[r][c], 255)
        love.graphics.rectangle("fill", (c-1)*16, (r-1)*16, 16, 16)
      end
    end
  end
  love.graphics.setRenderTarget()
end

function Chunk:generateTrees()
  if self.treesGenerated or not self.hasDirt or self.r > 1 then return end
  local canGenerate = true
  for r = -1, 0 do
    for c = -1, 1 do
      if not self.terrain:hasChunk(self.r + r, self.c + c) or not self.terrain:getChunk(self.r + r, self.c + c).generated then
        canGenerate = false
      end
    end
  end
  if canGenerate then
    local canPlantTree
    local height, maxHeight
    local radius
    math.randomseed(self.terrain:getSeed() + 13669 * self.r + self.c)
    for r = 1, 32 do
      for c = 1, 32 do
        if self:getBlock(r, c) == DIRT then
          if self:getBlock(r-1, c) == AIR or self:getBlock(r-1, c) == LEAVES then
            if self.r * 32 + r < math.random() * 32 then self:setBlock(r, c, GRASS) end
          end
          if math.random() < 0.1 then
            canPlantTree = true
            for i = 1, 5 do
              if self:getBlock(r-i, c) ~= AIR and self:getBlock(r-i, c) ~= LEAVES then canPlantTree = false end
            end
            if canPlantTree then
              -- Plant tree
              maxHeight = 5 + math.floor(6 * math.random())
              for i = 1, maxHeight do
                if self:getBlock(r-i-1, c) ~= AIR and self:getBlock(r-i-1, c) ~= LEAVES then break end
                self:setBlock(r-i, c, WOOD)
                height = i
              end
              radius = math.floor(height/3) + 1
              for r2 = -radius, radius do
                for c2 = -radius, radius do
                  if pythag(r2, c2) <= radius + 0.5 and self:getBlock(r-height+r2, c+c2) == AIR then self:setBlock(r-height+r2, c+c2, LEAVES) end
                end
              end
            end
          end
        end
      end
    end
    self.treesGenerated = true
  end
end

function Chunk:draw(view)
  if self.framebuffer == nil or self.changed then self:render() end
  love.graphics.draw(self.framebuffer, (32*self.c-view.x)*view.zoom + love.graphics.getWidth()/2, (32*self.r-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
end
