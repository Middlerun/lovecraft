
Chunk = {}

function Chunk:new()
  o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.generated = false
  o.block = {}
  o.perlin = {}
  o.coalNoise = {}
  for r = 1, 32 do
    o.block[r] = {}
    o.perlin[r] = {}
    o.coalNoise[r] = {}
    for c = 1, 32 do
      o.block[r][c] = 0
      o.perlin[r][c] = 0
    end
  end
  o.framebuffer = love.graphics.newFramebuffer(512, 512)
  o.framebuffer:setFilter("linear", "nearest")
  o.framebufferPerlin = love.graphics.newFramebuffer(512, 512)
  o.framebufferPerlin:setFilter("linear", "nearest")
  
  return o
end

function Chunk:generate(seed, chunkR, chunkC)
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
      
      if value > 0.5 then self.block[r][c] = air
      elseif value > 1.4 - dirtMargin or value < -0.6 then self.block[r][c] = dirt
      else self.block[r][c] = stone
      end
      
      if self.block[r][c] == stone and self.coalNoise[r][c] > 0.08 then self.block[r][c] = coalOre end
    end
  end
  self.generated = true
  self:render()
  self:renderPerlin()
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
  return self.block[r][c]
end

function Chunk:setBlock(r, c, block)
  self.block[r][c] = block
  self:render()
end

function Chunk:isGenerated()
  return self.generated
end

function Chunk:render()
  love.graphics.setRenderTarget(self.framebuffer)
  love.graphics.setColor(255, 255, 255, 255)
  for r = 1, 32 do
    for c = 1, 32 do
      if self.block[r][c] ~= air then
        love.graphics.draw(images[self.block[r][c]], (c-1)*16, (r-1)*16)
      end
    end
  end
  love.graphics.setRenderTarget()
end

function Chunk:renderPerlin()
  love.graphics.setRenderTarget(self.framebufferPerlin)
  love.graphics.setColor(255, 255, 255, 255)
  for r = 1, 32 do
    for c = 1, 32 do
      if self.block[r][c] ~= air then
        love.graphics.setColor(128 + 80 * self.perlin[r][c], 128 + 80 * self.perlin[r][c], 128 + 80 * self.perlin[r][c], 255)
        love.graphics.rectangle("fill", (c-1)*16, (r-1)*16, 16, 16)
      end
    end
  end
  love.graphics.setRenderTarget()
end
