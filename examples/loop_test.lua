local cqueues    = require("cqueues")
local event_loop = require("aether.runtime.eventLoop")

local loop = event_loop.new()

loop:spawn(function()
  for i = 1, 3 do print("A", i); cqueues.sleep(0.1) end
end)
loop:spawn(function()
  for i = 1, 3 do print("B", i); cqueues.sleep(0.1) end
end)

loop:run()
