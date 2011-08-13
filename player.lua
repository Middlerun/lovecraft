Player = {}

function Player:new(seed)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.x = 0.5
  o.y = -40
  o.height = 1.8
  o.width = 0.8
  o.falling = true
  o.vx = 0
  o.vy = 0
  o.image = love.graphics.newImage("gfx/happyman.png")
  o.image:setFilter("linear", "nearest")
  o.inventory = {}
  
  return o
end

function Player:give(blocktype)
  if self.inventory[blocktype] == nil then self.inventory[blocktype] = 1
  else self.inventory[blocktype] = self.inventory[blocktype] + 1
  end
end

function Player:take(blocktype)
  if self.inventory[blocktype] == nil then return false end
  if self.inventory[blocktype] > 0 then
    self.inventory[blocktype] = self.inventory[blocktype] - 1
    return true
  else
    return false
  end
end

function Player:checkInventory(blocktype)
  if self.inventory[blocktype] == nil then return 0
  else return self.inventory[blocktype]
  end
end

