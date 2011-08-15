this_thread = love.thread.getThread()
require("love.timer")
require("love.filesystem")
love.filesystem.load("TSerial.lua")()
love.filesystem.load("chunk.lua")()

-- Block codes
AIR = 0
STONE = 1
DIRT = 3
COAL_ORE = 16
UNGENERATED = 255

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

run = true

while run do
  this_thread:send("ready", true)
  commandMsg = this_thread:demand("command")
  if commandMsg == "quit" then run = false
  else
    this_thread:send("ready", false)
    local command = TSerial.unpack(commandMsg)
    chunk = Chunk:new()
    chunk:generate(command.seed, command.r, command.c)
    this_thread:send("chunk", TSerial.pack(chunk))
  end
end
