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
  o.hotbar = {}
  for i = 1, 9 do
    o.hotbar[i] = {}
  end
  
  return o
end

function Player:give(thing)
  if thing == nil then return false end
  
  for i = 1, 9 do
    if self.hotbar[i].id == thing and self.hotbar[i].count ~= nil and self.hotbar[i].count < 64 then
      self.hotbar[i].count = self.hotbar[i].count + 1
      return true
    end
  end
  for i = 1, 9 do
    if self.hotbar[i].id == nil then
      self.hotbar[i].id = thing
      self.hotbar[i].count = 1
      return true
    end
  end
  return false
end

function Player:takeSlot(slot)
  assert (slot ~= nil)
  assert (slot >= 1)
  assert (slot <= 9)
  if self.hotbar[slot].id == nil or self.hotbar[slot].count == nil or self.hotbar[slot].count <= 0 then return nil
  else
    self.hotbar[slot].count = self.hotbar[slot].count - 1
    local id = self.hotbar[slot].id
    if self.hotbar[slot].count == 0 then self.hotbar[slot].id = nil end
    return id
  end
end

function Player:checkSlot(slot)
  assert (slot ~= nil)
  assert (slot >= 1)
  assert (slot <= 9)
  if self.hotbar[slot].id == nil or self.hotbar[slot].count == nil or self.hotbar[slot].count <= 0 then return nil
  else return self.hotbar[slot].id end
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
    if not first and not self.falling and not self.hook.hooked then
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
