love.filesystem.load("perlin.lua")()
love.filesystem.setIdentity("lovecraft")

air = 0
stone = 1
dirt = 3
rand = {mySeed = 1, lastN = -1}

function love.load()
  showPerlin = 0
  
  terrain = makeTerrain()
  
end

function love.update(dt)
end

function love.draw()
  if showPerlin == 1 then plot2D(terrain.perlin)
  else
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
    drawTerrain(terrain)
  end
end

function love.keypressed(k, u)
  if k == "r" then
    terrain = makeTerrain()
  elseif k == "p" then
    showPerlin = 1 - showPerlin
  elseif k == "escape" then
    love.event.push("q")
  end
end

function love.keyreleased(k)

end

function rand:get(seed, n)
  if n <= 0 then return nil end
  if seed ~= self.mySeed or self.lastN < 0 or n <= self.lastN then
    self.mySeed = seed
    math.randomseed(seed)
    self.lastN = 0
  end
  while self.lastN < n do
    num = math.random()
    self.lastN = self.lastN + 1
  end
  return num - 0.5
end

function plot1D(values)
  love.graphics.line(0, love.graphics.getHeight()/2 - 200, love.graphics.getWidth(), love.graphics.getHeight()/2 - 200)
  love.graphics.line(0, love.graphics.getHeight()/2 + 200, love.graphics.getWidth(), love.graphics.getHeight()/2 + 200)
  for i = 1, #values - 1 do
    love.graphics.line((i-1)/(#values-1)*love.graphics.getWidth(), love.graphics.getHeight()/2 - values[i] * 400, (i)/(#values-1)*love.graphics.getWidth(), love.graphics.getHeight()/2 - values[i+1] * 400)
  end
end

function plot2D(values)
  for r = 1, #values do
    for c = 1, #(values[1]) do
      love.graphics.setColor(128 + 40 * values[r][c], 128 + 40 * values[r][c], 128 + 40 * values[r][c], 255)
      love.graphics.rectangle("fill", (c-1)/(#(values[1]))*love.graphics.getWidth(), (r-1)/(#values)*love.graphics.getHeight(), love.graphics.getWidth()/#(values[1]), love.graphics.getHeight()/#values)
    end
  end
end

function makeTerrain(seed)
  terrain = {}
  if seed == nil then seed = os.time() end
  terrain.seed = seed
  terrain.perlin = perlin2D(seed, 341, 256, 0.9, 20, 1)
  terrain.value = {}
  for r = 1, #terrain.perlin do
    terrain.value[r] = {}
    dirtMargin = (256-r) * 0.01
    for c = 1, #(terrain.perlin[r]) do
      value = terrain.perlin[r][c]
      if r < 128 then
        value = value + (128 - r) * 0.05
      end
      if value > 0.9 then terrain.value[r][c] = air
      elseif value > 1.6 - dirtMargin or value < -1.4 then terrain.value[r][c] = dirt
      else terrain.value[r][c] = stone
      end
    end
  end
  return terrain
end

function drawTerrain(terrain)
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



