Player = {}

function Player:new()
  local o = {}
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
  
  return o
end

function Player:give(block)
  if block == nil then return end
  if self.inventory[block] == nil then self.inventory[block] = 1
  else self.inventory[block] = self.inventory[block] + 1
  end
end

function Player:take(block)
  if block == nil then return false end
  if self.inventory[block] == nil then return false end
  if self.inventory[block] > 0 then
    self.inventory[block] = self.inventory[block] - 1
    return true
  else
    return false
  end
end

function Player:checkInventory(block)
  if block == nil then return 0 end
  if self.inventory[block] == nil then return 0
  else return self.inventory[block]
  end
end

function Player:update(dt)
  if self.hook.hooked then
    self.x,  self.y  = self.hook:endPoint()
    self.vx, self.vy = self.hook:endVelocity()
    self.walking = false
  else
    if self.falling then
      self.vy = self.vy + 40 * dt
      if     love.keyboard.isDown("a") and not self.againstLeftWall  then
        self.vx = math.max(-8, self.vx - 16 * dt)
        self.direction = -1
        self.landTime = 0
      elseif love.keyboard.isDown("d") and not self.againstRightWall then
        self.vx = math.min( 8, self.vx + 16 * dt)
        self.direction = 1
        self.landTime = 0
      end
    end
    if not first and not self.falling then
      if     love.keyboard.isDown("a") and not self.againstLeftWall  then
        self.vx = math.max(-8, self.vx - 36 * dt)
        self.direction = -1
        self.landTime = 0
      elseif love.keyboard.isDown("d") and not self.againstRightWall then
        self.vx = math.min( 8, self.vx + 36 * dt)
        self.direction = 1
        self.landTime = 0
      elseif self.vx > 0 then self.vx = math.max(0, self.vx - 128 * dt)
      elseif self.vx < 0 then self.vx = math.min(0, self.vx + 128 * dt)
      end
    end
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
    if not self.falling and math.abs(self.vx) > 0.5 and (love.keyboard.isDown("a") or love.keyboard.isDown("d")) then
      if not self.walking then self.walk:seek(5) end
      self.walking = true
    else
      self.walking = false
    end
  end
  
  self.landTime = self.landTime - dt
end

function Player:draw(view)
  if self.hook.hooked then
    love.graphics.draw(self.jump2, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.walking then
    self.walk:draw((self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.falling and self.vy < 0 then
    love.graphics.draw(self.jump1, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.falling then
    love.graphics.draw(self.jump2, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif self.landTime > 0 then
    love.graphics.draw(self.land,  (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  else
    love.graphics.draw(self.stand, (self.x-view.x)*view.zoom + love.graphics.getWidth()/2, (self.y-view.y+0.1)*view.zoom + love.graphics.getHeight()/2, 0, self.direction * view.zoom/32, view.zoom/32, 34, 103)
  end
  self.hook:draw(view, self.x, self.y - self.height/2)
end
