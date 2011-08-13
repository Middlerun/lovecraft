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
images[stone]:setFilter("linear", "nearest")
images[dirt] = love.graphics.newImage("gfx/dirt.png")
images[dirt]:setFilter("linear", "nearest")
images[coalOre] = love.graphics.newImage("gfx/coalOre.png")
images[coalOre]:setFilter("linear", "nearest")

genChunk = love.graphics.newImage("gfx/genChunk.png")
genChunk:setFilter("linear", "nearest")
oldMouse = {x = 0, y = 0}
cursor = {x = 0, y = 0}
cursorFade = false
cursorAlpha = 255
inreach = true
selected = 1

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
  player.x = 0.5
  player.y = -60
  while terrain:getValue(math.floor(player.y), math.floor(player.x) + 1) == air do
    player.y = player.y + 1
  end
  while terrain:getValue(math.floor(player.y), math.floor(player.x) + 1) ~= air do
    player.y = player.y - 1
  end
  
  first = true
  
end

function love.update(dt)
  local oldx = player.x
  local oldy = player.y
  if not first and player.falling then
    player.vy = player.vy + 40 * dt
    if     love.keyboard.isDown("a") then player.vx = math.max(-8, player.vx - 8 * dt)
    elseif love.keyboard.isDown("d") then player.vx = math.min( 8, player.vx + 8 * dt)
    end
  end
  if not first and not player.falling then
    if     love.keyboard.isDown("a") then player.vx = math.max(-8, player.vx - 48 * dt)
    elseif love.keyboard.isDown("d") then player.vx = math.min( 8, player.vx + 48 * dt)
    elseif player.vx > 0 then player.vx = math.max(0, player.vx - 128 * dt)
    elseif player.vx < 0 then player.vx = math.min(0, player.vx + 128 * dt)
    end
  end
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt
  
  -- This stuff doesn't really work very well, try to fix at some point:
  if player.y - oldy > math.abs(player.x - oldx) then
    hg = checkHitGround()
    hw = checkHitWall()
    hc = checkHitCeiling()
    --print ("1")
  elseif player.y - oldy < -math.abs(player.x - oldx) then
    hc = checkHitCeiling()
    hw = checkHitWall()
    hg = checkHitGround()
    --print ("2")
  elseif player.y - oldy > 0 then
    hw = checkHitWall()
    hg = checkHitGround()
    hc = checkHitCeiling()
    --print ("3")
  else
    hw = checkHitWall()
    hc = checkHitCeiling()
    hg = checkHitGround()
    --print ("4")
  end
  
  if love.keyboard.isDown("w") and not player.falling then
    player.falling = true
    player.vy = -16
  end
  
  view.x = view.x + (player.x - view.x) * 0.2
  view.y = view.y + (player.y - player.height / 2 - view.y) * 0.2
  local viewDist = pythag(view.x, view.y, player.x, player.y)
  local maxViewDist = 0.35 * math.min(love.graphics.getWidth(), love.graphics.getHeight()) / view.zoom
  if viewDist > maxViewDist then
    view.x = player.x - (player.x - view.x) * (maxViewDist / viewDist)
    view.y = player.y - (player.y - view.y) * (maxViewDist / viewDist)
  end
  --view.x = player.x
  --view.y = player.y + player.height / 2
  first = false
  
  cursor.x = (love.mouse.getX() - love.graphics.getWidth()  / 2) / view.zoom + view.x
  cursor.y = (love.mouse.getY() - love.graphics.getHeight() / 2) / view.zoom + view.y
  if love.keyboard.isDown("w") or love.keyboard.isDown("a") or love.keyboard.isDown("s") or love.keyboard.isDown("d") then
    cursorFade = true
  end
  if love.mouse.getX() ~= oldMouse.x or love.mouse.getY() ~= oldMouse.y or love.mouse.isDown("l") or love.mouse.isDown("r") then
    cursorFade = false
    cursorAlpha = 255
  end
  if cursorFade then cursorAlpha = math.max(0, cursorAlpha - dt * 255 / 5) end
  oldMouse.x = love.mouse.getX()
  oldMouse.y = love.mouse.getY()
  
  inreach = (pythag(cursor.x, cursor.y, player.x, player.y + player.height/2) < 5)
  if inreach then
    local block = terrain:getValue(math.ceil(cursor.y), math.ceil(cursor.x))
    if love.mouse.isDown("l") and block ~= air then
      player:give(block)
      terrain:setValue(math.ceil(cursor.y), math.ceil(cursor.x), air)
    elseif love.mouse.isDown("r") and block == air then
    
      -- This block is a temporary hack, change later
      if selected == 1 then block = dirt
      elseif selected == 2 then block = stone
      elseif selected == 3 then block = coalOre
      end
      -- end hack
      
      if player:take(block) then terrain:setValue(math.ceil(cursor.y), math.ceil(cursor.x), block) end
    end
  end
  
end

function checkHitCeiling()
  if terrain:getValue(math.ceil(player.y - player.height), math.ceil(player.x)) ~= air then
    player.vy = 0
    player.y = math.ceil(player.y - player.height) + player.height
    return true
  end
  return false
end

function checkHitWall()
  if player.x % 1 < player.width / 2 then
    if   terrain:getValue(math.ceil(player.y),     math.floor(player.x)) ~= air
    or   terrain:getValue(math.ceil(player.y) - 1, math.floor(player.x)) ~= air then
      player.vx = 0
      player.x = math.floor(player.x) + 1.1 * player.width / 2
      return true
    end
  elseif player.x % 1 > 1 - player.width / 2 then
    if   terrain:getValue(math.ceil(player.y),     math.floor(player.x) + 2) ~= air
    or   terrain:getValue(math.ceil(player.y) - 1, math.floor(player.x) + 2) ~= air then
      player.vx = 0
      player.x = math.floor(player.x) + 1 - 1.1 * player.width / 2
      return true
    end
  end
  return false
end

function checkHitGround()
  if terrain:getValue(math.floor(player.y) + 1, math.floor(player.x - player.width / 2) + 1) == air
   and terrain:getValue(math.floor(player.y) + 1, math.floor(player.x + player.width / 2) + 1) == air then
    player.falling = true
    return false
  else
    player.falling = false
    player.vy = 0
    player.y = math.floor(player.y)
    return true
  end
end

function love.draw()
  local x, y = love.mouse.getPosition()
  if showPerlin then drawTerrainPerlin(terrain, view.zoom, view.x, view.y)
  else
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
    drawTerrain(terrain, view.zoom, view.x, view.y)
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(player.image, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/64, view.zoom/64, player.image:getWidth()/2, player.image:getHeight())
  
  -- Can't remember what this was for:
  --love.graphics.line((player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y-1.5)*view.zoom+love.graphics.getHeight()/2, (cursor.x-view.x)*view.zoom + love.graphics.getWidth()/2, (cursor.y-view.y)*view.zoom+love.graphics.getHeight()/2)
  
  love.graphics.setColor(0, 0, 0, cursorAlpha)
  if inreach then
    love.graphics.rectangle("line", (math.ceil(cursor.x)-1-view.x)*view.zoom + love.graphics.getWidth()/2, (math.ceil(cursor.y)-1-view.y)*view.zoom+love.graphics.getHeight()/2, view.zoom, view.zoom)
  end
  
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 1 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Dirt: " .. player:checkInventory(dirt), 50, 50)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 2 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Stone: " .. player:checkInventory(stone), 50, 80)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 3 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Coal ore: " .. player:checkInventory(coalOre), 50, 110)
  
end

function love.keypressed(k, u)
  --if k == "r" then
    --terrain = makeTerrain()
  if k == "p" then
    showPerlin = not showPerlin
  elseif k == "escape" then
    love.event.push("q")
  elseif k == "[" then
    if view.zoom > 1 then view.zoom = view.zoom / 2 end
  elseif k == "]" then
    if view.zoom < 256 then view.zoom = view.zoom * 2 end
  end
end

function love.keyreleased(k)

end

function love.mousepressed(x, y, button)
  if button == "wd" then
    selected = selected + 1
    if selected == 4 then selected = 1 end
  elseif button == "wu" then
    selected = selected - 1
    if selected == 0 then selected = 3 end
  end
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
  local minR = math.max(-2, math.floor((y - zoom * (love.graphics.getHeight() / 2)) / 32))
  local maxR = math.min(1,  math.floor((y + zoom * (love.graphics.getHeight() / 2)) / 32))
  local minC = math.max(-2, math.floor((x - zoom * (love.graphics.getWidth()  / 2)) / 32))
  local maxC = math.min(1,  math.floor((x + zoom * (love.graphics.getWidth()  / 2)) / 32))
  love.graphics.setColor(255, 255, 255, 255)
  for r = minR, maxR do
    for c = minC, maxC do
      if terrain:hasChunk(r, c) then
        love.graphics.draw(terrain:getChunk(r, c).framebuffer, (32*c-x)*zoom + love.graphics.getWidth()/2, (32*r-y)*zoom+love.graphics.getHeight()/2, 0, zoom/16, zoom/16)
      else
        love.graphics.draw(genChunk, (x-32*c)*zoom + love.graphics.getWidth()/2, (y-32*r)*zoom+love.graphics.getHeight()/2, 0, zoom/8, zoom/8)
      end
    end
  end
end

function drawTerrainPerlin(terrain, zoom, x, y)
  for r = -2, 1 do
    for c = -2, 1 do
      if terrain:hasChunk(r, c) then
        drawChunkPerlin(terrain:getChunk(r, c), zoom, x-32*c, y-32*r)
      end
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

function pythag(x1, y1, x2, y2)
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

