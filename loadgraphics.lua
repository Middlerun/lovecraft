images = {}

images[STONE] = {}
images[STONE][1] = love.graphics.newImage("gfx/stone.png")
for i = 2, 16 do
  images[STONE][i] = images[STONE][1]
  images[STONE][i]:setFilter("linear", "nearest")
end

images[GRASS] = {}
images[GRASS][1] = love.graphics.newImage("gfx/grass.png")
for i = 2, 16 do
  images[GRASS][i] = images[GRASS][1]
  images[GRASS][i]:setFilter("linear", "nearest")
end

images[DIRT] = {}
images[DIRT][1] = love.graphics.newImage("gfx/dirt.png")
for i = 2, 16 do
  images[DIRT][i] = images[DIRT][1]
  images[DIRT][i]:setFilter("linear", "nearest")
end

images[COBBLESTONE] = {}
for i = 1, 16 do
  images[COBBLESTONE][i] = love.graphics.newImage("gfx/cobblestone" .. i .. ".png")
  images[COBBLESTONE][i]:setFilter("linear", "nearest")
end

images[COAL_ORE] = {}
images[COAL_ORE][1] = love.graphics.newImage("gfx/coalOre.png")
for i = 2, 16 do
  images[COAL_ORE][i] = images[COAL_ORE][1]
  images[COAL_ORE][i]:setFilter("linear", "nearest")
end

images[WOOD] = {}
images[WOOD][1] = love.graphics.newImage("gfx/wood.png")
for i = 2, 16 do
  images[WOOD][i] = images[WOOD][1]
  images[WOOD][i]:setFilter("linear", "nearest")
end

images[LEAVES] = {}
for i = 1, 16 do
  images[LEAVES][i] = love.graphics.newImage("gfx/leaves" .. i .. ".png")
  images[LEAVES][i]:setFilter("linear", "nearest")
end

breakImage = {}
for i = 1, 8 do
  breakImage[i] = love.graphics.newImage("gfx/break" .. i .. ".png")
  breakImage[i]:setFilter("linear", "nearest")
end
genChunk = love.graphics.newImage("gfx/genChunk.png")
genChunk:setFilter("linear", "nearest")

sky = love.graphics.newImage("gfx/sky.png")
