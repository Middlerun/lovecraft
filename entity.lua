Entity = {}

function Entity:new(id, y, x)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.id = id
  o.x = x
  o.y = y
  o.falling = true
  o.vy = -6
  o.remove = false
  o.angle1 = rand:num() * 2 * math.pi
  o.angle2 = rand:num() * 2 * math.pi
  o.createTime = love.timer.getTime()

  return o
end

function Entity:draw(view)
  local base = tileBase(self.id)
  if base ~= nil then love.graphics.draw(images[base][1],
                                         (self.x - view.x)*view.zoom + love.graphics.getWidth()/2,
                                         (self.y - view.y - 0.5 + 0.2 * math.sin(2 * love.timer.getTime() + self.angle1)) * view.zoom + love.graphics.getHeight()/2,
                                         4 * love.timer.getTime() + self.angle2,
                                         view.zoom/32, view.zoom/32, images[base][1]:getWidth()/2, images[base][1]:getHeight()/2) end
  love.graphics.draw(images[self.id][1],
                     (self.x - view.x)*view.zoom + love.graphics.getWidth()/2,
                     (self.y - view.y - 0.5 + 0.2 * math.sin(2 * love.timer.getTime() + self.angle1)) * view.zoom + love.graphics.getHeight()/2,
                     4 * love.timer.getTime() + self.angle2,
                     view.zoom/32, view.zoom/32, images[self.id][1]:getWidth()/2, images[self.id][1]:getHeight()/2)
end
