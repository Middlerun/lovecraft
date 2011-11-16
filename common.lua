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

-- Item codes
WOOD_SHOVEL = 1011
WOOD_PICKAXE = 1012
WOOD_AXE = 1013
WOOD_SWORD = 1014
STONE_SHOVEL = 1021
STONE_PICKAXE = 1022
STONE_AXE = 1023
STONE_SWORD = 1024

-- Tool type codes
SHOVEL = 1
PICKAXE = 2
AXE = 3
SWORD = 4
NO_TOOL = 9

-- Tool material codes
WOOD_TOOL = 1
STONE_TOOL = 2
COPPER_TOOL = 3
IRON_TOOL = 4

function toolInfo(item)
  if item == nil or item <= 1000 or item >= 2000 then return 9, nil end
  item = item - 1000
  toolType = item % 10
  toolMaterial = (item - toolType) / 10
  return toolType, toolMaterial
end

durability = {}
durability[STONE] = 2
durability[GRASS] = 1
durability[DIRT] = 1
durability[COBBLESTONE] = 2
durability[COAL_ORE] = 3
durability[WOOD] = 1.5
durability[LEAVES] = 0.3

function mineSpeedMultiplier(block, tool)
  toolType, toolMaterial = toolInfo(tool)
  if (block == STONE or block == COBBLESTONE or block == COAL_ORE) and toolType == PICKAXE then
    multiplier = 1.5
  elseif (block == GRASS or block == DIRT) and toolType == SHOVEL then
    multiplier = 2
  elseif (block == WOOD or block == LEAVES) and toolType == AXE then
    multiplier = 1.5
  else
    return 1
  end
  if toolMaterial == STONE_TOOL then multiplier = multiplier * 1.3 end
  if toolMaterial == COPPER_TOOL then multiplier = multiplier * 1.5 end
  if toolMaterial == IRON_TOOL then multiplier = multiplier * 1.6 end
  return multiplier
end

breakGive = {}
breakGive[STONE] = COBBLESTONE
breakGive[GRASS] = DIRT
breakGive[DIRT] = DIRT
breakGive[COBBLESTONE] = COBBLESTONE
breakGive[COAL_ORE] = COAL_ORE
breakGive[WOOD] = WOOD
breakGive[LEAVES] = nil

UP = 1
RIGHT = 2
DOWN = 3
LEFT = 4

function joinsTo(blockA, blockB, direction)
  if blockA == nil or blockB == nil then return false
  elseif blockA == blockB then return true
  elseif blockA == LEAVES and blockB == WOOD then return true
  elseif blockA == STONE and (blockB == DIRT or blockB == COAL_ORE or blockB == GRASS) then return true
  elseif blockA == DIRT and (blockB == STONE or blockB == COAL_ORE or blockB == GRASS) then return true
  elseif blockA == COAL_ORE and (blockB == STONE or blockB == DIRT or blockB == GRASS) then return true
  elseif blockA == GRASS and (blockB == STONE or blockB == DIRT or blockB == COAL_ORE) then return true
  elseif blockA == WOOD and blockB == DIRT and direction == DOWN then return true
  else return false
  end
end

function tileBase(block)
  if block == COAL_ORE then return STONE
  elseif block == GRASS then return DIRT
  else return nil
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

function rand:num()
  rand.lastN = -1
  return math.random() - 0.5
end
