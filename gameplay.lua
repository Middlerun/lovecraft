function handleGameplayInput(player, terrain, dt)
  cursor.x = (love.mouse.getX() - love.graphics.getWidth()  / 2) / view.zoom + view.x
  cursor.y = (love.mouse.getY() - love.graphics.getHeight() / 2) / view.zoom + view.y
  
  if not player.hook.hooked and love.keyboard.isDown(" ") and not player.falling and not hookRelease then
    player.falling = true
    player.vy = -15
  end
  if player.hook.hooked then
    if love.keyboard.isDown("w") then
      player.hook:shorten(dt)
    elseif love.keyboard.isDown("s") then
      player.hook:lengthen(dt)
    end
    if love.keyboard.isDown("a") then
      player.hook.push = 2
      player.direction = -1
    elseif love.keyboard.isDown("d") then
      player.hook.push = -2
      player.direction = 1
    else
      player.hook.push = 0
    end
  end
  
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
  
  inreach = (pythag(cursor.x, cursor.y, player.x, player.y - player.height/2) < 5)
  if inreach then
    local block = terrain:getBlock(math.ceil(cursor.y), math.ceil(cursor.x))
    if love.mouse.isDown("l") and block ~= AIR and block ~= UNGENERATED then
      tool = player.inventory:checkCurrent().id
      if math.ceil(cursor.x) == mineBlock.c and math.ceil(cursor.y) == mineBlock.r then
        mineProgress = mineProgress + mineSpeedMultiplier(block, tool) * dt / durability[block]
        if mineProgress >= 1 or instamine then
          terrain:setBlock(math.ceil(cursor.y), math.ceil(cursor.x), AIR)
          mineProgress = 0
          mineBlock.r = nil
          mineBlock.c = nil
          terrain:addEntity(breakGive[block], math.ceil(cursor.y), math.ceil(cursor.x) - 0.5 - rand:num())
        end
      else
        mineBlock.r = math.ceil(cursor.y)
        mineBlock.c = math.ceil(cursor.x)
        mineProgress = dt / mineSpeedMultiplier(block, tool) * durability[block]
      end
    elseif love.mouse.isDown("r") and block == AIR and placeTime > 0.2 then
      local x = math.ceil(cursor.x)
      local y = math.ceil(cursor.y)
      if x - 1 >= player.x + player.width / 2 or x <= player.x - player.width / 2
      or y - 1 >= player.y or y <= player.y - player.height then
        if player.inventory:checkCurrent().id < 1000 then
          terrain:setBlock(y, x, player.inventory:takeCurrent().id)
          placeTime = 0
        end
      end
      mineProgress = 0
    else
      mineProgress = 0
    end
  end
end

function handleInventoryInput(player)
  local x = love.mouse.getX()
  local y = love.mouse.getY()
  local offsetY
  player.inventory.selected.r = nil
  player.inventory.selected.c = nil
  for r = 1, 4 do
    if r < 4 then
      offsetY = 216 + 52 * (r - 1)
    else
      offsetY = 396
    end
    for c = 1, 9 do
      if x >= love.graphics.getWidth()/2  - inventoryGraphic:getWidth()/2 + 12 + 54 * (c - 1) and
         x <= love.graphics.getWidth()/2  - inventoryGraphic:getWidth()/2 + 66 + 54 * (c - 1) and
         y >= love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY and
         y <= love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY + 52 then
        player.inventory.selected.r = r
        player.inventory.selected.c = c
      end
    end
  end
end
