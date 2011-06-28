love.filesystem.load("perlin.lua")()
love.filesystem.load("chunk.lua")()
love.filesystem.load("terrain.lua")()
love.filesystem.setIdentity("lovecraft")

air = 0
stone = 1
dirt = 3
rand = {mySeed = 1, lastN = -1}

function love.load()
  showPerlin = false
  
  terrain = Terrain:new(1)
  chunk1 = Chunk:new()
  chunk1:generate(1, 0, 0)
  terrain:addChunk(chunk1, 0, 0)
  chunk2 = Chunk:new()
  chunk2:generate(1, 0, 1)
  terrain:addChunk(chunk2, 0, 1)
  chunk3 = Chunk:new()
  chunk3:generate(1, 1, 0)
  terrain:addChunk(chunk3, 1, 0)
  chunk4 = Chunk:new()
  chunk4:generate(1, 1, 1)
  terrain:addChunk(chunk4, 1, 1)
  
end

function love.update(dt)
end

function love.draw()
  if showPerlin then drawTerrainPerlin(terrain, 4, 0, 0)
  else
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
    drawTerrain(terrain, 4, 0, 0)
  end
end

function love.keypressed(k, u)
  if k == "r" then
    terrain = makeTerrain()
  elseif k == "p" then
    showPerlin = not showPerlin
  elseif k == "escape" then
    love.event.push("q")
  end
end

function love.keyreleased(k)

end

function rand:get(seed, n)
  if n <= 0 then n = -2 * n
  else n = 2 * n - 1
  end
  
  if seed ~= self.mySeed or self.lastN < 0 or n <= self.lastN then
    self.mySeed = seed
    math.randomseed(seed)
    self.lastN = -1
  end
  while self.lastN < n do
    num = math.random()
    self.lastN = self.lastN + 1
  end
  return num - 0.5
end

function makeTerrain(seed)
  terrain = {}
  if seed == nil then seed = os.time() end
  terrain.seed = seed
  terrain.perlin = perlin2D(seed, 341, 256, 0.55, 6, 1)
  terrain.value = {}
  for r = 1, #terrain.perlin do
    terrain.value[r] = {}
    dirtMargin = (256-r) * 0.01
    for c = 1, #(terrain.perlin[r]) do
      value = terrain.perlin[r][c]
      if r < 128 then
        value = value + (128 - r) * 0.02
      end
      if value > 0.5 then terrain.value[r][c] = air
      elseif value > 1.4 - dirtMargin or value < -0.6 then terrain.value[r][c] = dirt
      else terrain.value[r][c] = stone
      end
    end
  end
  return terrain
end

function drawTerrainOld(terrain)
  for r = 1, #terrain.value do
    for c = 1, #(terrain.value[1]) do
      if terrain.value[r][c] ~= air then
        if terrain.value[r][c] == stone then love.graphics.setColor(163, 163, 163, 255) end
        if terrain.value[r][c] == dirt then love.graphics.setColor(130, 97, 21, 255) end
        love.graphics.rectangle("fill", (c-1)/(#(terrain.value[1]))*love.graphics.getWidth(), (r-1)/(#terrain.value)*love.graphics.getHeight(), love.graphics.getWidth()/#(terrain.value[1]), love.graphics.getHeight()/#terrain.value)
      end
    end
  end
end

function drawTerrain(terrain, zoom, x, y)
  for r = 0, 1 do
    for c = 0, 1 do
      drawChunk(terrain:getChunk(r, c), zoom, x-32*c, y-32*r)
    end
  end
end

function drawChunk(chunk, zoom, x, y)
  for r = 1, 32 do
    for c = 1, 32 do
      if chunk.value[r][c] ~= air then
        if chunk.value[r][c] == stone then love.graphics.setColor(163, 163, 163, 255) end
        if chunk.value[r][c] == dirt then love.graphics.setColor(130, 97, 21, 255) end
        love.graphics.rectangle("fill", (c-1-x)*zoom + love.graphics.getWidth()/2, (r-1-y)*zoom+love.graphics.getHeight()/2, zoom, zoom)
      end
    end
  end
end

function drawTerrainPerlin(terrain, zoom, x, y)
  for r = 0, 1 do
    for c = 0, 1 do
      drawChunkPerlin(terrain:getChunk(r, c), zoom, x-32*c, y-32*r)
    end
  end
end

function drawChunkPerlin(chunk, zoom, x, y)
  for r = 1, 32 do
    for c = 1, 32 do
      love.graphics.setColor(128 + 80 * chunk.perlin[r][c], 128 + 80 * chunk.perlin[r][c], 128 + 80 * chunk.perlin[r][c], 255)
      love.graphics.rectangle("fill", (c-1-x)*zoom + love.graphics.getWidth()/2, (r-1-y)*zoom+love.graphics.getHeight()/2, zoom, zoom)
    end
  end
end



