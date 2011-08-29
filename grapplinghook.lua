GrapplingHook = {}

function GrapplingHook:new(player)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.x = 0.5
  o.y = -40
  o.vx = 0
  o.vy = 0
  o.firingSpeed = 60
  o.fired = false
  o.hooked = false
  o.length = 0
  o.angle = 0
  o.dAngleDT = 0
  o.player = player
  o.maxLength = 30
  
  return o
end

function GrapplingHook:fire(x, y, dx, dy)
  local dist = math.sqrt(dx^2 + dy^2)
  self.x = x
  self.y = y
  self.vx = dx * (self.firingSpeed / dist)
  self.vy = dy * (self.firingSpeed / dist)
  self.fired = true
  self.hooked = false
  self.swinging = true
  self.push = 0
end

function GrapplingHook:hook()
  self.hooked = true
  self.vx = 0
  self.vy = 0
  self.length = math.sqrt((self.player.x - self.x)^2 + (self.player.y - player.height/2 - self.y)^2)
  self:setAngle(math.atan2(self.player.y - player.height/2 - self.y, self.player.x - self.x))
  
  if self.player.falling then
    -- Find initial angular velocity:
    local angleDiff = math.atan2(self.player.vy, self.player.vx) - self.angle
    while angleDiff < 0 do
      angleDiff = angleDiff + 2 * math.pi
    end
    while angleDiff >= 2 * math.pi do
      angleDiff = angleDiff - 2 * math.pi
    end
    self.dAngleDT = math.sin(angleDiff) * math.sqrt(player.vx^2 + player.vy^2) / self.length
  else
    self.dAngleDT = 0
    self.swinging = false
  end
end

function GrapplingHook:reset()
  self.fired = false
  self.hooked = false
  self.vx = 0
  self.vy = 0
end

function GrapplingHook:zero()
  if self.hooked then self.dAngleDT = 0 end
end

function GrapplingHook:setAngle(angle)
  self.angle = angle
  while self.angle < 0 do
    self.angle = self.angle + 2 * math.pi
  end
  while self.angle >= 2 * math.pi do
    self.angle = self.angle - 2 * math.pi
  end
end

function GrapplingHook:stop()
  self.dAngleDT = 0
  self.swinging = false
  self:setAngle(math.atan2(self.player.y - player.height/2 - self.y, self.player.x - self.x))
  self.length = math.sqrt((self.player.x - self.x)^2 + (self.player.y - player.height/2 - self.y)^2)
end

function GrapplingHook:start()
  self.swinging = true
end

function GrapplingHook:shorten(dt)
  if not player.falling and self.angle > math.pi then return end
  if (self.player.againstRightWall or self.player.againstLeftWall) and self.angle < math.pi then return end
  local oldLength = self.length
  self.length = self.length - 8 * dt
  if self.length < 2 then self.length = 2 end
  self.dAngleDT = self.dAngleDT * (oldLength / self.length)
  self:start()
end

function GrapplingHook:lengthen(dt)
  if not player.falling and self.angle < math.pi then return end
  if (self.player.againstRightWall or self.player.againstLeftWall) and self.angle > math.pi then return end
  local oldLength = self.length
  self.length = self.length + 8 * dt
  if self.length > self.maxLength then self.length = self.maxLength end
  self.dAngleDT = self.dAngleDT * (oldLength / self.length)
  self:start()
end

function GrapplingHook:endPoint()
  return self.x + self.length * math.cos(self.angle), self.y + self.length * math.sin(self.angle)
end

function GrapplingHook:endVelocity()
  return self.length * self.dAngleDT * math.cos(self.angle + math.pi/2), self.length * self.dAngleDT * math.sin(self.angle + math.pi/2)
end

function GrapplingHook:update(terrain, dt)
  if self.fired then
    if not self.hooked then
      self.oldX = self.x
      self.oldY = self.y
      self.x = self.x + self.vx * dt
      self.y = self.y + self.vy * dt
      self.length = math.sqrt((self.player.x - self.x)^2 + (self.player.y - player.height/2 - self.y)^2)
      if self.length > self.maxLength then
        self:reset()
        return
      end
      
      local frac = 1
      local moveFrac = 1
      
      if self.vx > 0 and terrain:getBlock(math.ceil(self.y), math.ceil(self.x)) ~= AIR then
        -- Check right hit
        frac = 1.01 * (math.ceil(self.oldX) - self.oldX) / (self.x - self.oldX)
        mid = self.oldY + frac * (self.y - self.oldY)
        if mid >= math.ceil(self.y) - 1 and mid <= math.ceil(self.y) and frac < moveFrac then
          self.x = self.oldX + frac * (self.x - self.oldX)
          self.y = self.oldY + frac * (self.y - self.oldY)
          self:hook()
        end
      end
      if self.vx < 0 and terrain:getBlock(math.ceil(self.y), math.ceil(self.x)) ~= AIR then
        -- Check left hit
        frac = 1.01 * (math.ceil(self.oldX) - 1 - self.oldX) / (self.x - self.oldX)
        mid = self.oldY + frac * (self.y - self.oldY)
        if mid >= math.ceil(self.y) - 1 and mid <= math.ceil(self.y) and frac < moveFrac then
          self.x = self.oldX + frac * (self.x - self.oldX)
          self.y = self.oldY + frac * (self.y - self.oldY)
          self:hook()
        end
      end
      if self.vy < 0 and terrain:getBlock(math.ceil(self.y), math.ceil(self.x)) ~= AIR then
        -- Check ceiling hit
        frac = 1.01 * (math.ceil(self.oldY) - 1 - self.oldY) / (self.y - self.oldY)
        mid = self.oldX + frac * (self.x - self.oldX)
        if mid >= math.ceil(self.x) - 1 and mid <= math.ceil(self.x) and frac < moveFrac then
          self.x = self.oldX + frac * (self.x - self.oldX)
          self.y = self.oldY + frac * (self.y - self.oldY)
          self:hook()
        end
      end
      if self.vy > 0 and terrain:getBlock(math.ceil(self.y), math.ceil(self.x)) ~= AIR then
        -- Check ground hit
        frac = 1.01 * (math.ceil(self.oldY) - self.oldY) / (self.y - self.oldY)
        mid = self.oldX + frac * (self.x - self.oldX)
        if mid >= math.ceil(self.x) - 1 and mid <= math.ceil(self.x) and frac < moveFrac then
          self.x = self.oldX + frac * (self.x - self.oldX)
          self.y = self.oldY + frac * (self.y - self.oldY)
          self:hook()
        end
      end
    else
      -- Check the block it's hooked to still exists
      if  terrain:getBlock(math.floor(self.y) + 1, math.floor(self.x) + 1) == AIR then
        self:reset()
      elseif self.swinging then
        -- Calculate angle
        self.dAngleDT = self.dAngleDT + dt * g * math.cos(self.angle) / self.length + dt * math.sin(self.angle) * self.push / self.length
        self:setAngle(self.angle + dt * self.dAngleDT)
      end
    end
  end
end

function GrapplingHook:draw(view, x, y)
  if not self.fired then return end
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.setLine(view.zoom/16, "smooth")
  love.graphics.line((x-view.x)*view.zoom + love.graphics.getWidth()/2, (y-view.y)*view.zoom + love.graphics.getHeight()/2, (self.x-view.x)*view.zoom  + love.graphics.getWidth()/2, (self.y-view.y)*view.zoom  + love.graphics.getHeight()/2)
end
