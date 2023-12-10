-- local function event_loop(argc, ...)
--   local args = { ... }
--   local callback = args[argc]
--   local total_tasks = (argc - 1)
--   local pending_tasks = {}

--   for i = 1, total_tasks do
--     local task = coroutine.create(args[i])
--     coroutine.resume(task)
--     pending_tasks[i] = task
--   end
-- end

-- Assign the coroutine namespace to `co`
local co = coroutine

--local cont, ret = co.resume(thread, x, y, z)

local function read_fs(file)
  return function(callback)
    fs.read(file, callback)
  end
end

local function pong(thread)
  local nxt = nil
  nxt = function(cont, ...)
    if not cont then
      return ...
    else
      return nxt(co.resume(thread, ...))
    end
  end
  return nxt(co.resume(thread))
end

local thread = co.create(function()
  local x = co.yield(1)
  print(x)
  local y, z = co.yield(2, 3)
  print(y, z)
end)

pong(thread)
