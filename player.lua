Player = {}

function Player:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.x = 0
  o.y = 0
  o.height = 1.8
  o.width = 0.7
  o.falling = true
  o.againstRightWall = false
  o.againstLeftWall = false
  o.vx = 0
  o.vy = 0
  o.stand = love.graphics.newImage("gfx/rabbitStand.png")
  o.stand:setFilter("linear", "nearest")
  o.jump1 = love.graphics.newImage("gfx/rabbitJump1.png")
  o.jump1:setFilter("linear", "nearest")
  o.jump2 = love.graphics.newImage("gfx/rabbitJump2.png")
  o.jump2:setFilter("linear", "nearest")
  o.land = love.graphics.newImage("gfx/rabbitLand.png")
  o.land:setFilter("linear", "nearest")
  o.walkImg = love.graphics.newImage("gfx/rabbitWalk.png")
  o.walkImg:setFilter("linear", "nearest")
  o.walk = newAnimation(o.walkImg, 64, 128, 0.05, 11)
  o.walk:play()
  o.walking = false
  o.inventory = {}
  o.oldX = o.x
  o.oldY = o.y
  o.direction = 1
  o.hook = GrapplingHook:new(o)
  o.landTime = 0
  o.inventory = {}
  for r = 1, 4 do
    o.inventory[r] = {}
    for c = 1, 9 do
      o.inventory[r][c] = {}
    end
  end
  o.hotbar = o.inventory[4]
  
  return o
end

function Player:give(thing)
  if thing == nil then return false end
  
  for r = 4, 1, -1 do
    for c = 1, 9 do
      if self.inventory[r][c].id == thing and self.inventory[r][c].count ~= nil and self.inventory[r][c].count < 64 then
        self.inventory[r][c].count = self.inventory[r][c].count + 1
        return true
      end
    end
  end
  for r = 4, 1, -1 do
    for c = 1, 9 do
      if self.inventory[r][c].id == nil then
        self.inventory[r][c].id = thing
        self.inventory[r][c].count = 1
        return true
      end
    end
  end
  return false
end

function Player:takeSlot(r, c, count)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  if count == nil then count = 1 end
  if self.inventory[r][c].id == nil or self.inventory[r][c].count == nil or self.inventory[r][c].count - count < 0 then return {id = nil, count = 0}
  else
    self.inventory[r][c].count = self.inventory[r][c].count - count
    local id = self.inventory[r][c].id
    if self.inventory[r][c].count == 0 then self.inventory[r][c].id = nil end
    return {id = id, count = count}
  end
end

function Player:setSlot(r, c, stuff)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  self.inventory[r][c] = stuff
end

function Player:checkSlot(r, c)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  if self.inventory[r][c].id == nil or self.inventory[r][c].count == nil or self.inventory[r][c].count <= 0 then return {id = nil, count = 0}
  else return {id = self.inventory[r][c].id, count = self.inventory[r][c].count} end
end

function Player:update(dt)
  if self.hook.hooked then
    self.x,  self.y  = self.hook:endPoint()
    self.y = self.y + player.height/2
    self.vx, self.vy = self.hook:endVelocity()
    self.walking = false
  else
    if self.falling and not self.hook.hooked then
      self.vy = self.vy + g * dt
      if     love.keyboard.isDown("a") and not self.againstLeftWall  and not showInventory then
        self.vx = math.max(-8, self.vx - 16 * dt)
        self.direction = -1
        self.landTime = 0
      elseif love.keyboard.isDown("d") and not self.againstRightWall and not showInventory then
        self.vx = math.min( 8, self.vx + 16 * dt)
        self.direction = 1
        self.landTime = 0
      end
    end
    if not first and not self.falling and not self.hook.hooked then
      if     love.keyboard.isDown("a") and not self.againstLeftWall  and not showInventory then
        self.vx = math.max(-8, self.vx - 36 * dt)
        self.direction = -1
        self.landTime = 0
      elseif love.keyboard.isDown("d") and not self.againstRightWall and not showInventory then
        self.vx = math.min( 8, self.vx + 36 * dt)
        self.direction = 1
        self.landTime = 0
      elseif self.vx > 0 then self.vx = math.max(0, self.vx - 128 * dt)
      elseif self.vx < 0 then self.vx = math.min(0, self.vx + 128 * dt)
      end
    end
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
    if not self.falling and math.abs(self.vx) > 0.5 and (love.keyboard.isDown("a") or love.keyboard.isDown("d")) and not showInventory then
      if not self.walking then self.walk:seek(5) end
      self.walking = true
    else
      self.walking = false
    end
  end
  
  self.landTime = self.landTime - dt
end

function Player:draw(view)
  self.hook:draw(view, self.x, self.y - self.height/2)
  love.graphics.setColor(255, 255, 255, 255)
  if self.walking then
    self.walk:draw((self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.falling and self.vy < 0 and not self.hook.hooked then
    love.graphics.draw(self.jump1, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.falling then
    love.graphics.draw(self.jump2, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.landTime > 0 then
    love.graphics.draw(self.land,  (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  else
    love.graphics.draw(self.stand, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  end
end

function Player:drawHotbar(selected)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(hotbar, love.graphics.getWidth()/2 - hotbar:getWidth()/2, love.graphics.getHeight() - hotbar:getHeight())
  love.graphics.draw(highlight, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 20 + 54 * (selected - 1), love.graphics.getHeight() - hotbar:getHeight() + 8)
  
  for i = 1, 9 do
    if player.hotbar[i].id ~= nil then
      local base = tileBase(player.hotbar[i].id)
      if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[player.hotbar[i].id][1]:getWidth()/2, images[player.hotbar[i].id][1]:getHeight()/2) end
      love.graphics.draw(images[player.hotbar[i].id][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[player.hotbar[i].id][1]:getWidth()/2, images[player.hotbar[i].id][1]:getHeight()/2)
      love.graphics.print(player.hotbar[i].count, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 50 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 35)
    end
  end
end

function Player:drawInventory(selected)
  love.graphics.setColor(0, 0, 0, 128)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(inventory, love.graphics.getWidth()/2 - inventory:getWidth()/2, love.graphics.getHeight()/2 - inventory:getHeight()/2)
  if selected.r == nil or selected.c == nil then
    -- Do nothing
  elseif selected.r >= 1 and selected.r <= 3 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventory:getWidth()/2 + 20 + 54 * (selected.c - 1), love.graphics.getHeight()/2 - inventory:getHeight()/2 + 224 + 52 * (selected.r - 1))
  elseif selected.r == 4 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventory:getWidth()/2 + 20 + 54 * (selected.c - 1), love.graphics.getHeight()/2 - inventory:getHeight()/2 + 404)
  end
  
  local offsetY
  for r = 1, 4 do
    if r < 4 then offsetY = 242 + 52 * (r - 1)
    else offsetY = 422
    end
    for c = 1, 9 do
      if player.inventory[r][c].id ~= nil then
        local base = tileBase(player.inventory[r][c].id)
        
        if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - inventory:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventory:getHeight()/2 + offsetY, 0, 1, 1, images[player.inventory[r][c].id][1]:getWidth()/2, images[player.inventory[r][c].id][1]:getHeight()/2) end
        
        love.graphics.draw(images[player.inventory[r][c].id][1], love.graphics.getWidth()/2 - inventory:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventory:getHeight()/2 + offsetY, 0, 1, 1, images[player.inventory[r][c].id][1]:getWidth()/2, images[player.inventory[r][c].id][1]:getHeight()/2)
        
        love.graphics.print(player.inventory[r][c].count, love.graphics.getWidth()/2 - inventory:getWidth()/2 + 50 + 54 * (c - 1), love.graphics.getHeight()/2 - inventory:getHeight()/2 + offsetY + 9)
      end
    end
  end
end
