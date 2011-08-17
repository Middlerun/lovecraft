-- Modes
MENU = 1
GENERATING = 2
PLAY = 3

-- Block codes
AIR = 0
STONE = 1
GRASS = 2
DIRT = 3
COBBLESTONE = 4
COAL_ORE = 16
WOOD = 17
LEAVES = 18
UNGENERATED = 255

durability = {}
durability[STONE] = 2
durability[GRASS] = 1
durability[DIRT] = 1
durability[COBBLESTONE] = 2
durability[COAL_ORE] = 3
durability[WOOD] = 1.5
durability[LEAVES] = 0.3

breakGive = {}
breakGive[STONE] = COBBLESTONE
breakGive[GRASS] = DIRT
breakGive[DIRT] = DIRT
breakGive[COBBLESTONE] = COBBLESTONE
breakGive[COAL_ORE] = COAL_ORE
breakGive[WOOD] = WOOD
breakGive[LEAVES] = nil

function joinsTo(blockA, blockB)
  if blockA == nil or blockB == nil then return false
  elseif blockA == blockB then return true
  elseif blockA == LEAVES and blockB == WOOD then return true
  else return false
  end
end

-- Random number engine
rand = {mySeed = 1, lastN = -1}
function rand:get(seed, n)
  if n <= 0 then n = -2 * n
  else n = 2 * n - 1
  end
  
  if seed ~= self.mySeed or self.lastN < 0 or n <= self.lastN then
    self.mySeed = seed
    math.randomseed(seed)
    self.lastN = -1
  end
  while self.lastN < n do
    num = math.random()
    self.lastN = self.lastN + 1
  end
  return num - 0.5
end
