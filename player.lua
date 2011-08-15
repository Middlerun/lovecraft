Player = {}

function Player:new(seed)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.x = 0.5
  o.y = -40
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
  o.walk = newAnimation(love.graphics.newImage("gfx/rabbitWalk.png"), 64, 128, 0.05, 11)
  o.walk:play()
  o.walking = false
  o.inventory = {}
  o.oldX = o.x
  o.oldY = o.y
  o.direction = 1
  
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

