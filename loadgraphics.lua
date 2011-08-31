images = {}

images[STONE] = {}
for i = 1, 16 do
  images[STONE][i] = love.graphics.newImage("gfx/tiles/stone" .. i .. ".png")
  images[STONE][i]:setFilter("linear", "nearest")
end

grassFlat   = love.graphics.newImage("gfx/tiles/grassFlat.png")
grassSingle = love.graphics.newImage("gfx/tiles/grassSingle.png")
grassLeft   = love.graphics.newImage("gfx/tiles/grassLeft.png")
grassRight  = love.graphics.newImage("gfx/tiles/grassRight.png")
images[GRASS] = {}
for i = 1, 16 do
  images[GRASS][i] = grassFlat
  images[GRASS][i]:setFilter("linear", "nearest")
end
images[GRASS][1]  = grassSingle
images[GRASS][3]  = grassLeft
images[GRASS][5]  = grassSingle
images[GRASS][7]  = grassLeft
images[GRASS][9]  = grassRight
images[GRASS][13] = grassRight

images[DIRT] = {}
for i = 1, 16 do
  images[DIRT][i] = love.graphics.newImage("gfx/tiles/dirt" .. i .. ".png")
  images[DIRT][i]:setFilter("linear", "nearest")
end

images[COBBLESTONE] = {}
for i = 1, 16 do
  images[COBBLESTONE][i] = love.graphics.newImage("gfx/tiles/cobblestone" .. i .. ".png")
  images[COBBLESTONE][i]:setFilter("linear", "nearest")
end

images[COAL_ORE] = {}
images[COAL_ORE][1] = love.graphics.newImage("gfx/tiles/coalOre.png")
for i = 2, 16 do
  images[COAL_ORE][i] = images[COAL_ORE][1]
  images[COAL_ORE][i]:setFilter("linear", "nearest")
end

images[WOOD] = {}
for i = 1, 16 do
  images[WOOD][i] = love.graphics.newImage("gfx/tiles/wood" .. i .. ".png")
  images[WOOD][i]:setFilter("linear", "nearest")
end

images[LEAVES] = {}
for i = 1, 16 do
  images[LEAVES][i] = love.graphics.newImage("gfx/tiles/leaves" .. i .. ".png")
  images[LEAVES][i]:setFilter("linear", "nearest")
end

breakImage = {}
for i = 1, 8 do
  breakImage[i] = love.graphics.newImage("gfx/tiles/break" .. i .. ".png")
  breakImage[i]:setFilter("linear", "nearest")
end

genChunk = love.graphics.newImage("gfx/genChunk.png")
genChunk:setFilter("linear", "nearest")

sky = love.graphics.newImage("gfx/sky.png")

hotbar = love.graphics.newImage("gfx/hotbar.png")
inventoryGraphic = love.graphics.newImage("gfx/inventory.png")
highlight = love.graphics.newImage("gfx/highlight.png")
