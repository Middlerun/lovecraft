love.filesystem.load("perlin.lua")()
love.filesystem.load("chunk.lua")()
love.filesystem.load("terrain.lua")()
love.filesystem.load("grapplinghook.lua")()
love.filesystem.load("player.lua")()
love.filesystem.load("collision.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("loadgraphics.lua")()
love.filesystem.load("entity.lua")()
love.filesystem.load("gameplay.lua")()
love.filesystem.load("AnAL.lua")()
love.filesystem.setIdentity("lovecraft")

view = {zoom = 32, x = 0, y = 0}
showPerlin = false
oldMouse = {x = 0, y = 0}
cursor = {x = 0, y = 0}
cursorFade = false
cursorAlpha = 255
inreach = true
selected = {}
selected.hotbar = 1
selected.r = 1
selected.c = 1
mineBlock = {r = nil, c = nil}
mineProgress = 0
placeTime = 0
instamine = false
debug = false
hookRelease = false
showInventory = false
g = 40
pickedItem = {id = nil, count = 0}



function love.load()
  generator = love.thread.newThread("generator", "generator.lua")
  generator:start()
  
  player = Player:new()
  terrain = Terrain:new()
  terrain:generateInitial()
  player.x = 0.5
  player.y = -60
  while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) == AIR do
    player.y = player.y + 1
  end
  while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) ~= AIR do
    player.y = player.y - 1
  end
  
  view.x = player.x
  view.y = player.y - player.height / 2
  first = true
end



function love.update(dt)
  if dt > 0.1 then dt = 0.1 end
  local oldx = player.x
  local oldy = player.y
  if not first then
    player:update(dt)
  end
  
  for i = 1, #terrain.entities do
    local entity = terrain.entities[i]
    if entity.falling then
      entity.vy = entity.vy + g * dt
      entity.y = entity.y + entity.vy * dt
    end
  end
  
  checkCollisions(terrain, player)
  
  if showInventory then handleInventoryInput(player)
  else handleGameplayInput(player, terrain, dt)
  end
  
  view.x = view.x + (player.x - view.x) * 0.2
  view.y = view.y + (player.y - player.height / 2 - view.y) * 0.2
  local viewDist = pythag(view.x, view.y, player.x, player.y)
  local maxViewDist = 0.35 * math.min(love.graphics.getWidth(), love.graphics.getHeight()) / view.zoom
  if viewDist > maxViewDist then
    view.x = player.x - (player.x - view.x) * (maxViewDist / viewDist)
    view.y = player.y - (player.y - view.y) * (maxViewDist / viewDist)
  end
  first = false
  
  placeTime = placeTime + dt
  player.walk:update(dt)
  player.hook:update(terrain, dt)
  
  -- Generate new chunks
  for r = math.floor((player.y - 80) / 32), math.floor((player.y + 80) / 32) do
    for c = math.floor((player.x - 80) / 32), math.floor((player.x + 80) / 32) do
      terrain:generate(r, c)
    end
  end
  terrain:checkGenerator()
end



function love.draw()
  local x, y = love.mouse.getPosition()
  if showPerlin then terrain:drawPerlin(view)
  else
    terrain:draw(view)
  end
  love.graphics.setColor(255, 255, 255, 255)
  player:draw(view)
  
  love.graphics.setColor(0, 0, 0, cursorAlpha)
  if inreach and not showInventory then
    love.graphics.setLine(view.zoom/32, "rough")
    love.graphics.rectangle("line", (math.ceil(cursor.x)-1-view.x)*view.zoom + love.graphics.getWidth()/2, (math.ceil(cursor.y)-1-view.y)*view.zoom+love.graphics.getHeight()/2, view.zoom, view.zoom)
  end
  
  if mineProgress > 0 and mineProgress <= 1 then
    love.graphics.draw(breakImage[math.ceil(mineProgress * 8)], (mineBlock.c-1-view.x)*view.zoom + love.graphics.getWidth()/2, (mineBlock.r-1-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
  end
  
  if showInventory then
    player:drawInventory(selected)
    if pickedItem.id ~= nil then
      love.mouse.setVisible(false)
      local x = love.mouse.getX()
      local y = love.mouse.getY()
      love.graphics.setColor(255, 255, 255, 255)
      local base = tileBase(pickedItem.id)
      if base ~= nil then love.graphics.draw(images[base][1], x, y, 0, 1, 1, images[pickedItem.id][1]:getWidth()/2, images[pickedItem.id][1]:getHeight()/2) end
      love.graphics.draw(images[pickedItem.id][1], x, y, 0, 1, 1, images[pickedItem.id][1]:getWidth()/2, images[pickedItem.id][1]:getHeight()/2)
      love.graphics.print(pickedItem.count, x + 11, y + 9)
    else
      love.mouse.setVisible(true)
    end
  else
    player:drawHotbar(selected.hotbar)
  end
  
  if debug then
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth() - 150, 50)
  end
end



function love.keypressed(k, u)
  if showInventory then
    if k == "escape" and pickedItem.id == nil then
      showInventory = false
    end
  else
    if k == "escape" then
      generator:send("command", "quit")
      generator:wait()
      love.event.push("q")
    elseif k == " " then
      if player.hook.fired then
        player.hook:reset()
        hookRelease = true
      end
    end
  end
  
  if k == "p" then
    --showPerlin = not showPerlin
  elseif k == "f3" then
    debug = not debug
    instamine = debug
  elseif k == "e" and pickedItem.id == nil then
    showInventory = not showInventory
  elseif k == "[" then
    if view.zoom > 1 then view.zoom = view.zoom / 2 end
  elseif k == "]" then
    if view.zoom < 256 then view.zoom = view.zoom * 2 end
  end
  
end



function love.keyreleased(k)
  if k == " " then
    hookRelease = false
  end
end



function love.mousepressed(x, y, button)
  if showInventory then
    if selected.r ~= nil and selected.c ~= nil then
      if button == "l" then
        local tempItem = player:takeSlot(selected.r, selected.c, player:checkSlot(selected.r, selected.c).count)
        player:setSlot(selected.r, selected.c, pickedItem)
        pickedItem = tempItem
      end
    end
  else
    if button == "m" then
      player.hook:fire(player.x, player.y - player.height/2, cursor.x - player.x, cursor.y - (player.y - player.height/2))
    elseif button == "wd" then
      selected.hotbar = selected.hotbar + 1
      if selected.hotbar == 10 then selected.hotbar = 1 end
    elseif button == "wu" then
      selected.hotbar = selected.hotbar - 1
      if selected.hotbar == 0  then selected.hotbar = 9 end
    end
  end
end



function pythag(x1, y1, x2, y2)
  if x2 == nil and y2 == nil then
    x2 = 0
    y2 = 0
  end
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

