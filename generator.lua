this_thread = love.thread.getThread()
require("love.timer")
require("love.filesystem")
love.filesystem.load("TSerial.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("chunk.lua")()

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
