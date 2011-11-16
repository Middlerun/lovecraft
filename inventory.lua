Inventory = {}

function Inventory:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.slots = {}
  for r = 1, 4 do
    o.slots[r] = {}
    for c = 1, 9 do
      o.slots[r][c] = {}
    end
  end
  o.hotbar = o.slots[4]
  o.selected = {}
  o.selected.hotbar = 1
  o.selected.r = 1
  o.selected.c = 1
  o.pickedItem = {id = nil, count = 0}
  
  return o
end

function Inventory:give(thing)
  if thing == nil then return false end
  
  for r = 4, 1, -1 do
    for c = 1, 9 do
      if self.slots[r][c].id == thing and self.slots[r][c].count ~= nil and self.slots[r][c].count < 64 then
        self.slots[r][c].count = self.slots[r][c].count + 1
        return true
      end
    end
  end
  for r = 4, 1, -1 do
    for c = 1, 9 do
      if self.slots[r][c].id == nil then
        self.slots[r][c].id = thing
        self.slots[r][c].count = 1
        return true
      end
    end
  end
  return false
end

function Inventory:takeSlot(r, c, count)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  if count == nil then count = 1 end
  if self.slots[r][c].id == nil or self.slots[r][c].count == nil or self.slots[r][c].count - count < 0 then return {id = nil, count = 0}
  else
    self.slots[r][c].count = self.slots[r][c].count - count
    local id = self.slots[r][c].id
    if self.slots[r][c].count == 0 then self.slots[r][c].id = nil end
    return {id = id, count = count}
  end
end

function Inventory:takeCurrent(count)
  return self:takeSlot(4, self.selected.hotbar, count)
end

function Inventory:setSlot(r, c, stuff)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  self.slots[r][c] = stuff
end

function Inventory:checkSlot(r, c)
  assert (r ~= nil and c ~= nil)
  assert (r >= 1 and r <= 4)
  assert (c >= 1 and c <= 9)
  if self.slots[r][c].id == nil or self.slots[r][c].count == nil or self.slots[r][c].count <= 0 then return {id = nil, count = 0}
  else return {id = self.slots[r][c].id, count = self.slots[r][c].count} end
end

function Inventory:checkCurrent()
  return self:checkSlot(4, self.selected.hotbar)
end

function Inventory:selectNext()
  self.selected.hotbar = self.selected.hotbar + 1
  if self.selected.hotbar == 10 then self.selected.hotbar = 1 end
end

function Inventory:selectPrev()
  self.selected.hotbar = self.selected.hotbar - 1
  if self.selected.hotbar == 0  then self.selected.hotbar = 9 end
end

function Inventory:drawHotbar()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(hotbar, love.graphics.getWidth()/2 - hotbar:getWidth()/2, love.graphics.getHeight() - hotbar:getHeight())
  love.graphics.draw(highlight, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 20 + 54 * (self.selected.hotbar - 1), love.graphics.getHeight() - hotbar:getHeight() + 8)
  
  for i = 1, 9 do
    if self.hotbar[i].id ~= nil then
      if self.hotbar[i].id < 1000 then
        local base = tileBase(self.hotbar[i].id)
        if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[self.hotbar[i].id][1]:getWidth()/2, images[self.hotbar[i].id][1]:getHeight()/2) end
        love.graphics.draw(images[self.hotbar[i].id][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[self.hotbar[i].id][1]:getWidth()/2, images[self.hotbar[i].id][1]:getHeight()/2)
      else
        love.graphics.draw(images[self.hotbar[i].id], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[self.hotbar[i].id]:getWidth()/2, images[self.hotbar[i].id]:getHeight()/2)
      end
      if self.hotbar[i].count > 1 then
        love.graphics.print(self.hotbar[i].count, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 50 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 35)
      end
    end
  end
end

function Inventory:draw()
  love.graphics.setColor(0, 0, 0, 128)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(inventoryGraphic, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2, love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2)
  if self.selected.r == nil or self.selected.c == nil then
    -- Do nothing
  elseif self.selected.r >= 1 and self.selected.r <= 3 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 20 + 54 * (self.selected.c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + 224 + 52 * (self.selected.r - 1))
  elseif self.selected.r == 4 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 20 + 54 * (self.selected.c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + 404)
  end
  
  local offsetY
  for r = 1, 4 do
    if r < 4 then offsetY = 242 + 52 * (r - 1)
    else offsetY = 422
    end
    for c = 1, 9 do
      if self.slots[r][c].id ~= nil then
        local base = tileBase(self.slots[r][c].id)
        
        if self.slots[r][c].id < 1000 then
          if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY, 0, 1, 1, images[self.slots[r][c].id][1]:getWidth()/2, images[self.slots[r][c].id][1]:getHeight()/2) end
          love.graphics.draw(images[self.slots[r][c].id][1], love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY, 0, 1, 1, images[self.slots[r][c].id][1]:getWidth()/2, images[self.slots[r][c].id][1]:getHeight()/2)
        
        else
          love.graphics.draw(images[self.slots[r][c].id], love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY, 0, 1, 1, images[self.slots[r][c].id]:getWidth()/2, images[self.slots[r][c].id]:getHeight()/2)
        end
        
        if self.slots[r][c].count > 1 then
          love.graphics.print(self.slots[r][c].count, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 50 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY + 9)
        end
      end
    end
  end
  
  if self.pickedItem.id ~= nil then
    love.mouse.setVisible(false)
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    love.graphics.setColor(255, 255, 255, 255)
    local base = tileBase(self.pickedItem.id)
    if self.pickedItem.id < 1000 then
      if base ~= nil then love.graphics.draw(images[base][1], x, y, 0, 1, 1, images[self.pickedItem.id][1]:getWidth()/2, images[self.pickedItem.id][1]:getHeight()/2) end
      love.graphics.draw(images[self.pickedItem.id][1], x, y, 0, 1, 1, images[self.pickedItem.id][1]:getWidth()/2, images[self.pickedItem.id][1]:getHeight()/2)
    else
      love.graphics.draw(images[self.pickedItem.id], x, y, 0, 1, 1, images[self.pickedItem.id]:getWidth()/2, images[self.pickedItem.id]:getHeight()/2)
    end
    if self.pickedItem.count > 1 then
      love.graphics.print(self.pickedItem.count, x + 11, y + 9)
    end
  else
    love.mouse.setVisible(true)
  end
end

function Inventory:handleInput(button)
  if self.selected.r ~= nil and self.selected.c ~= nil then
    if button == "l" and player.inventory:checkSlot(self.selected.r, self.selected.c).id == self.pickedItem.id then
      if player.inventory:checkSlot(self.selected.r, self.selected.c).count + self.pickedItem.count <= 64 then
        player.inventory:setSlot(self.selected.r, self.selected.c, {id = self.pickedItem.id, count = player.inventory:checkSlot(self.selected.r, self.selected.c).count + self.pickedItem.count})
        self.pickedItem = {id = nil, count = 0}
      else
        self.pickedItem.count = player.inventory:checkSlot(self.selected.r, self.selected.c).count + self.pickedItem.count - 64
        player.inventory:setSlot(self.selected.r, self.selected.c, {id = self.pickedItem.id, count = 64})
      end
    elseif button == "l" then
      local tempItem = player.inventory:takeSlot(self.selected.r, self.selected.c, player.inventory:checkSlot(self.selected.r, self.selected.c).count)
      player.inventory:setSlot(self.selected.r, self.selected.c, self.pickedItem)
      self.pickedItem = tempItem
    elseif button == "r" and self.pickedItem.id == nil then
      self.pickedItem = player.inventory:takeSlot(self.selected.r, self.selected.c, math.ceil(player.inventory:checkSlot(self.selected.r, self.selected.c).count/2))
    elseif button == "r" then
      if player.inventory:checkSlot(self.selected.r, self.selected.c).id == nil then
        player.inventory:setSlot(self.selected.r, self.selected.c, {id = self.pickedItem.id, count = 1})
        self.pickedItem.count = self.pickedItem.count - 1
        if self.pickedItem.count == 0 then self.pickedItem.id = nil end
      elseif player.inventory:checkSlot(self.selected.r, self.selected.c).id == self.pickedItem.id then
        if player.inventory:checkSlot(self.selected.r, self.selected.c).count < 64 then
          player.inventory:setSlot(self.selected.r, self.selected.c, {id = self.pickedItem.id, count = player.inventory:checkSlot(self.selected.r, self.selected.c).count + 1})
          self.pickedItem.count = self.pickedItem.count - 1
          if self.pickedItem.count == 0 then self.pickedItem.id = nil end
        end
      else
        local tempItem = player.inventory:takeSlot(self.selected.r, self.selected.c, player.inventory:checkSlot(self.selected.r, self.selected.c).count)
        player.inventory:setSlot(self.selected.r, self.selected.c, self.pickedItem)
        self.pickedItem = tempItem
      end
    end
  end
end
