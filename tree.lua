Tree = {}

-- (r, c) indicates the block of dirt below the tree (chunk coordinates)
function Tree:new(r, c, trunklength, leafradius)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.r = r
  o.c = c
  o.trunklength = trunklength
  o.leafradius = leafradius
  o.data = {}
  o.rMin = r - trunklength - leafradius
  o.rMax = r - 1
  o.cMin = c - leafradius
  o.cMax = c + leafradius
  o.planted = false
  
  for r2 = o.rMin, o.rMax do
    for c2 = o.cMin, o.cMax do
      if o.data[r2] == nil then o.data[r2] = {} end
      o.data[r2][c2] = AIR
    end
  end
  
  for i = 1, trunklength do
    o.data[r-i][c] = WOOD
  end
  for r2 = -leafradius, leafradius do
    for c2 = -leafradius, leafradius do
      if math.sqrt(r2^2 + c2^2) <= leafradius + 0.5 and o.data[r-trunklength+r2][c+c2] == AIR then
        o.data[r-trunklength+r2][c+c2] = LEAVES
      end
    end
  end
  
  return o
end

function Tree:getBlock(r, c)
  if self.data[r] == nil then return nil end
  return self.data[r][c]
end
