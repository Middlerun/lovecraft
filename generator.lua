print("generator started")
require("love.timer")
require("love.filesystem")
love.filesystem.load("TSerial.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("chunk.lua")()
chunk_channel = love.thread.getChannel('generator_chunk')
command_channel = love.thread.getChannel('generator_command')

run = true

while run do
  commandMsg = command_channel:demand()
  if commandMsg == "quit" then run = false
  else
    local command = TSerial.unpack(commandMsg)
    chunk = Chunk:new()
    chunk:generate(command.seed, command.r, command.c)
    chunk_channel:push(TSerial.pack(chunk))
    print("generated chunk at " .. command.r .. ", " .. command.c)
  end
end
