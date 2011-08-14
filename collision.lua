function checkCollisions(terrain, player)
  local rightWall = 1
  local leftWall = 2
  local ceiling = 3
  local ground = 4
  local hit = 0
  local frac = 1
  local moveFrac = 1
  local mid
  local againstRightWall = false
  local againstLeftWall = false
  
  -- Check right hit
  for y = 0, player.height, player.height/2 do
    if player.againstRightWall and terrain:getBlock(math.ceil(player.y - y), math.ceil(player.x + player.width/2 + 0.01)) ~= air then
      againstRightWall = true
    elseif not player.againstRightWall and player.x > player.oldX and terrain:getBlock(math.ceil(player.y - y), math.ceil(player.x + player.width/2)) ~= air then
      frac = (math.ceil(player.oldX + player.width/2) - (player.oldX + player.width/2)) / (player.x - player.oldX)
      mid = player.oldY - y + frac * (player.y - player.oldY)
      if mid >= math.ceil(player.y - y) - 1 and mid <= math.ceil(player.y - y) and frac < moveFrac then
        hit = rightWall
        moveFrac = frac
      end
    end
  end--]]
  -- Check left hit
  for y = 0, player.height, player.height/2 do
    if player.againstLeftWall and terrain:getBlock(math.ceil(player.y - y), math.ceil(player.x - player.width/2 - 0.01)) ~= air then
      againstLeftWall = true
    elseif not player.againstLeftWall and player.x < player.oldX and terrain:getBlock(math.ceil(player.y - y), math.ceil(player.x - player.width/2)) ~= air then
      frac = (math.ceil(player.oldX - player.width/2) - 1 - (player.oldX - player.width/2)) / (player.x - player.oldX)
      mid = player.oldY - y + frac * (player.y - player.oldY)
      if mid >= math.ceil(player.y - y) - 1 and mid <= math.ceil(player.y - y) and frac < moveFrac then
        hit = leftWall
        moveFrac = frac
      end
    end
  end--]]
  if player.falling then
    -- Check ceiling hit
    for x = -player.width/2, player.width, player.width do
      if player.y < player.oldY and terrain:getBlock(math.ceil(player.y - player.height), math.ceil(player.x + x)) ~= air then
        frac = (math.ceil(player.oldY - player.height) - 1 - (player.oldY - player.height)) / (player.y - player.oldY)
        mid = player.oldX + x + frac * (player.x - player.oldX)
        if mid >= math.ceil(player.x + x) - 1 and mid <= math.ceil(player.x + x) and frac < moveFrac then
          hit = ceiling
          moveFrac = frac
        end
      end
    end--]]
    -- Check ground hit
    for x = -player.width/2, player.width, player.width do
      if player.y > player.oldY and terrain:getBlock(math.ceil(player.y), math.ceil(player.x + x)) ~= air then
        frac = (math.ceil(player.oldY) - (player.oldY)) / (player.y - player.oldY)
        mid = player.oldX + x + frac * (player.x - player.oldX)
        if mid >= math.ceil(player.x + x) - 1 and mid <= math.ceil(player.x + x) and frac < moveFrac then
          hit = ground
          moveFrac = frac
        end
      end
    end--]]
  else
    -- Check player has ground to stand on
    if  terrain:getBlock(math.floor(player.y) + 1, math.floor(player.x - player.width / 2) + 1) == air
    and terrain:getBlock(math.floor(player.y) + 1, math.floor(player.x + player.width / 2) + 1) == air then
      player.falling = true
    end
  end
  
  if not againstRightWall then player.againstRightWall = false end
  if not againstLeftWall  then player.againstLeftWall  = false end
  if hit ~= 0 then
    player.x = player.oldX + 0.99 * moveFrac * (player.x - player.oldX)
    player.y = player.oldY + 0.99 * moveFrac * (player.y - player.oldY)
  end
  if hit == leftWall then
    player.vx = 0
    player.againstLeftWall = true
  elseif hit == rightWall then
    player.vx = 0
    player.againstRightWall = true
  elseif hit == ceiling then
    player.vy = 0
  elseif hit == ground then
    player.vy = 0
    player.y = math.ceil(player.y - 0.5)
    player.falling = false
  end
  
  player.oldX = player.x
  player.oldY = player.y
end
