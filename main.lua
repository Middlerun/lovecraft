love.filesystem.load("perlin.lua")()
love.filesystem.load("chunk.lua")()
love.filesystem.load("terrain.lua")()
love.filesystem.load("player.lua")()
love.filesystem.setIdentity("lovecraft")

air = 0
stone = 1
dirt = 3
coalOre = 16
rand = {mySeed = 1, lastN = -1}
view = {zoom = 32, x = 0, y = 0}
images = {}
images[stone] = love.graphics.newImage("gfx/stone.png")
images[dirt] = love.graphics.newImage("gfx/dirt.png")
images[coalOre] = love.graphics.newImage("gfx/coalOre.png")
cursor = {x = 0, y = 0}

function love.load()
  showPerlin = false
  
  player = Player:new()
  
  terrain = Terrain:new()
  for r = -2, 1 do
    for c = -2, 1 do
      chunk = Chunk:new()
      chunk:generate(terrain:getSeed(), r, c)
      terrain:addChunk(chunk, r, c)
    end
  end
  
  first = true
  
end

function love.update(dt)
  if not first and player.falling then
    player.vy = player.vy + 40 * dt
    if     love.keyboard.isDown("a")  then player.vx = math.max(-8, player.vx - 8 * dt)
    elseif love.keyboard.isDown("d") then player.vx = math.min(8, player.vx + 8 * dt)
    end
  end
  if not first and not player.falling then
    if     love.keyboard.isDown("a")  then player.vx = math.max(-8, player.vx - 64 * dt)
    elseif love.keyboard.isDown("d") then player.vx = math.min(8, player.vx + 64 * dt)
    elseif player.vx > 0 then player.vx = math.max(0, player.vx - 128 * dt)
    elseif player.vx < 0 then player.vx = math.min(0, player.vx + 128 * dt)
    end
  end
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt
  
  if terrain:getValue(math.ceil(player.y - player.height), math.ceil(player.x)) ~= air then
    player.vy = 0
    player.y = math.ceil(player.y - player.height) + player.height
  end
  
  if player.x % 1 < player.width / 2 then
    if   terrain:getValue(math.floor(player.y) - 1, math.floor(player.x)) ~= air
    or   terrain:getValue(math.floor(player.y) + 0, math.floor(player.x)) ~= air then
      player.vx = 0
      player.x = math.floor(player.x) + 1.1 * player.width / 2
    end
  elseif player.x % 1 > 1 - player.width / 2 then
    if   terrain:getValue(math.floor(player.y) - 1, math.floor(player.x) + 2) ~= air
    or   terrain:getValue(math.floor(player.y) + 0, math.floor(player.x) + 2) ~= air then
      player.vx = 0
      player.x = math.floor(player.x) + 1 - 1.1 * player.width / 2
    end
  end
  
  if terrain:getValue(math.floor(player.y) + 1, math.floor(player.x - player.width / 2) + 1) == air
   and terrain:getValue(math.floor(player.y) + 1, math.floor(player.x + player.width / 2) + 1) == air then
    player.falling = true
  else
    player.falling = false
    player.vy = 0
    player.y = math.floor(player.y)
  end
  
  --view.x = view.x + (player.x - view.x) * 0.2
  --view.y = view.y + (player.y - view.y) * 0.2
  view.x = player.x
  view.y = player.y + player.height / 2
  first = false
  
  cursor.x = (love.mouse.getX() - love.graphics.getWidth()  / 2) / view.zoom + view.x
  cursor.y = (love.mouse.getY() - love.graphics.getHeight() / 2) / view.zoom + view.y
  
end

function love.draw()
  if showPerlin then drawTerrainPerlin(terrain, view.zoom, view.x, view.y)
  else
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
    drawTerrain(terrain, view.zoom, view.x, view.y)
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(player.image, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/64, view.zoom/64, player.image:getWidth()/2, player.image:getHeight())
  --love.graphics.line((player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y-1.5)*view.zoom+love.graphics.getHeight()/2, (cursor.x-view.x)*view.zoom + love.graphics.getWidth()/2, (cursor.y-view.y)*view.zoom+love.graphics.getHeight()/2)
end

function love.keypressed(k, u)
  --if k == "r" then
    --terrain = makeTerrain()
  if k == "w" and not player.falling then
    player.falling = true
    player.vy = -16
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

function drawTerrain(terrain, zoom, x, y)
  for r = -2, 1 do
    for c = -2, 1 do
      drawChunk(terrain:getChunk(r, c), zoom, x-32*c, y-32*r)
    end
  end
end

function drawChunkPlain(chunk, zoom, x, y)
  for r = 1, 32 do
    for c = 1, 32 do
      if chunk.value[r][c] ~= air then
        if chunk.value[r][c] == stone then love.graphics.setColor(163, 163, 163, 255) end
        if chunk.value[r][c] == dirt then love.graphics.setColor(130, 97, 21, 255) end
        if chunk.value[r][c] == coalOre then love.graphics.setColor(50, 50, 50, 255) end
        love.graphics.rectangle("fill", (c-1-x)*zoom + love.graphics.getWidth()/2, (r-1-y)*zoom+love.graphics.getHeight()/2, zoom, zoom)
      end
    end
  end
end

function drawChunk(chunk, zoom, x, y)
  for r = 1, 32 do
    for c = 1, 32 do
      if chunk.value[r][c] ~= air then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(images[chunk.value[r][c]], (c-1-x)*zoom + love.graphics.getWidth()/2, (r-1-y)*zoom+love.graphics.getHeight()/2, 0, zoom/16, zoom/16)
      end
    end
  end
end

function drawTerrainPerlin(terrain, zoom, x, y)
  for r = -2, 1 do
    for c = -2, 1 do
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



