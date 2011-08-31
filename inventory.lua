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

function Inventory:drawHotbar(selected)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(hotbar, love.graphics.getWidth()/2 - hotbar:getWidth()/2, love.graphics.getHeight() - hotbar:getHeight())
  love.graphics.draw(highlight, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 20 + 54 * (selected - 1), love.graphics.getHeight() - hotbar:getHeight() + 8)
  
  for i = 1, 9 do
    if self.hotbar[i].id ~= nil then
      local base = tileBase(self.hotbar[i].id)
      if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[self.hotbar[i].id][1]:getWidth()/2, images[self.hotbar[i].id][1]:getHeight()/2) end
      love.graphics.draw(images[self.hotbar[i].id][1], love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 39 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 26, 0, 1, 1, images[self.hotbar[i].id][1]:getWidth()/2, images[self.hotbar[i].id][1]:getHeight()/2)
      love.graphics.print(self.hotbar[i].count, love.graphics.getWidth()/2 - hotbar:getWidth()/2 + 50 + 54 * (i - 1), love.graphics.getHeight() - hotbar:getHeight() + 35)
    end
  end
end

function Inventory:draw(selected)
  love.graphics.setColor(0, 0, 0, 128)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(inventoryGraphic, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2, love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2)
  if selected.r == nil or selected.c == nil then
    -- Do nothing
  elseif selected.r >= 1 and selected.r <= 3 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 20 + 54 * (selected.c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + 224 + 52 * (selected.r - 1))
  elseif selected.r == 4 then
    love.graphics.draw(highlight, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 20 + 54 * (selected.c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + 404)
  end
  
  local offsetY
  for r = 1, 4 do
    if r < 4 then offsetY = 242 + 52 * (r - 1)
    else offsetY = 422
    end
    for c = 1, 9 do
      if self.slots[r][c].id ~= nil then
        local base = tileBase(self.slots[r][c].id)
        
        if base ~= nil then love.graphics.draw(images[base][1], love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY, 0, 1, 1, images[self.slots[r][c].id][1]:getWidth()/2, images[self.slots[r][c].id][1]:getHeight()/2) end
        
        love.graphics.draw(images[self.slots[r][c].id][1], love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 39 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY, 0, 1, 1, images[self.slots[r][c].id][1]:getWidth()/2, images[self.slots[r][c].id][1]:getHeight()/2)
        
        love.graphics.print(self.slots[r][c].count, love.graphics.getWidth()/2 - inventoryGraphic:getWidth()/2 + 50 + 54 * (c - 1), love.graphics.getHeight()/2 - inventoryGraphic:getHeight()/2 + offsetY + 9)
      end
    end
  end
end
