this_thread = love.thread.getThread()
require("love.timer")
require("love.filesystem")
love.filesystem.load("TSerial.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("terrain.lua")()
love.filesystem.load("chunk.lua")()

run = true
cuntnuggets = true

while run do
  this_thread:send("ready", true)
  commandMsg = this_thread:demand("command")
  if commandMsg == "quit" then run = false
  else
    this_thread:send("ready", false)
    local command = TSerial.unpack(commandMsg)
    terrain = Terrain:new()
    for r = -1, 0 do
      for c = -1, 1 do
        chunk = Chunk:new()
        chunk.block = command[r][c]
        chunk.generated = true
        terrain:addChunk(chunk, command.r + r, command.c + c)
      end
    end
    
    terrain:getChunk(command.r, command.c):generateTrees()
    assert(terrain:getChunk(command.r, command.c).treesGenerated)
    
    data = {}
    data[-1] = {}
    data[0] = {}
    for r = -1, 0 do
      for c = -1, 1 do
        data[r][c] = terrain:getChunk(command.r + r, command.c + c).block
      end
    end
    
    this_thread:send("data", TSerial.pack({blockdata = data, r = command.r, c = command.c}))
  end
end
