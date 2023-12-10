-- Constants/Configuration:
local ACTIVE_LOG_LEVEL = "ERROR"
local ACTIVE_LOG_FILE = "log.txt"
local ACTIVE_TIME_FORMAT = "%H:%M:%S"
local ACTIVE_UNIT_OF_MEASUREMENT = "ms"

-- Constants/Defaults:
local DEFAULT_MESSAGE_FORMAT = "%8s | %-5s: %-32s - %-60s" -- [TIME] [SEVERITY] [PARENT / FILE] - MESSAGE
local DEFAULT_INIT_MESSAGE = "%8s | %-5s: %-32s %s (%s)" -- TIME | SEVERITY .. (LOGLEVEL)
local DEFAULT_TIMER_MESSAGE = "%8s | %-5s: %-32s took %f %s to complete" -- TIME | SEVERITY FILE ELAPSED UNIT
local DEFAULT_FUNCTION_TIMER_MESSAGE = "%8s | %-5s: %-32s took %f %s to complete (func)" -- [TIME] [SEVERITY] [FILE] [FUN] .. [ELAPSED] [UNIT]
local DEFAULT_TIMER_TAIL = ACTIVE_UNIT_OF_MEASUREMENT
-- ..
local DEFAULT_INIT_BODY = {
  first = "Logging initialized",
  second = "Current Log level",
}
local MESSAGE_FORMATS = {
  ["DEFAULT"] = DEFAULT_MESSAGE_FORMAT,
  ["INIT"] = DEFAULT_INIT_MESSAGE,
  ["TIMER"] = DEFAULT_TIMER_MESSAGE,
  ["FUN"] = DEFAULT_FUNCTION_TIMER_MESSAGE,
}
--
local SEVERITY_LEVELS = { "ERROR", "WARN", "INFO", "DEBUG" }
local DEFAULT_SEVERITY = { printing = "DEBUG", benchmarking = "INFO", init = "INFO" }
local MEASUREMENT_DENOMINATORS = { ["ms"] = 1000000, ["ns"] = 1 }
local LOG_LEVELS = { "ERROR", "WARN", "INFO", "DEBUG" }
local NUMERIC_LOG_LEVELS = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
local NUMERIC_SEVERITY_LEVELS = NUMERIC_LOG_LEVELS
local LOGGING_THRESHOLDS = { printing = 4, benchmarking = 3 }

-- Constants/States:
local DID_INITIALIZE = false
local ACTIVE_NUMERIC_LOGGING_LEVEL = NUMERIC_LOG_LEVELS[ACTIVE_LOG_LEVEL]
local IS_PRINTING_ENABLED = ACTIVE_NUMERIC_LOGGING_LEVEL >= LOGGING_THRESHOLDS["printing"]
local IS_BENCHMARKING_ENABLED = ACTIVE_NUMERIC_LOGGING_LEVEL >= LOGGING_THRESHOLDS["benchmarking"]

local Class = {}
Class.__index = Class

local active_logs = {}

local function process_stack(traceback)
  local parent = vim.fn.fnamemodify(traceback.source, ":h:t")
  local filename = vim.fn.fnamemodify(traceback.source, ":t:r")

  --return join_items("/", parent, filename)
  return filename, parent
end

-- Constructor
function Class:new()
  local stack = debug.getinfo(2, "S")
  local file, parent = process_stack(stack)

  local obj = setmetatable({}, self)
  obj.logs = {}
  obj.timers = {}
  obj.source = { file = file, root = parent .. "/" .. file }
  obj.identifier = file
  return obj
end

local function should_be_logged(severity, always)
  return ACTIVE_NUMERIC_LOGGING_LEVEL >= NUMERIC_SEVERITY_LEVELS[severity] or always
end

local function prepare_args(...)
  local dt = {}
  local args = { ... }
  local argc = #{ ... }
  for i = 1, argc do
    if args[i] then
      table.insert(dt, args[i])
    end
  end

  return dt
end

local function generate_message(mtype, ...)
  local format = MESSAGE_FORMATS[mtype] or "DEFAULT"
  local final_args = prepare_args(...)
  local msg = string.format(format, unpack(final_args))
  return msg
end

-- TIME | SEVERITY .. (LOGLEVEL)
function Class:init()
  if DID_INITIALIZE then
    return
  end

  local body1, body2 = DEFAULT_INIT_BODY["first"], DEFAULT_INIT_BODY["second"]
  local time = os.date(ACTIVE_TIME_FORMAT)
  local severity = DEFAULT_SEVERITY["init"]
  local msg = self:create_message("INIT", time, severity, body1, body2, ACTIVE_LOG_LEVEL)
  self:log(msg, severity, "yes")
end

-- [TIME] ~> [SEVERITY] [FILETYPE] | [FILE]: message
function Class:create_message(mtype, ...)
  mtype = mtype or "DEFAULT"
  local msg = generate_message(mtype, ...)
  return msg
end

-- Logging function
function Class:log(message, severity, always)
  severity = severity or "INFO"
  if not should_be_logged(severity, always) then
    return
  end

  vim.schedule(function()
    local entry = message
    table.insert(self.logs, entry)
    table.insert(active_logs, entry)
    self:write_to_file(entry)

    if IS_PRINTING_ENABLED or always then
      print(entry)
    end
  end)
end

-- Write logs to a file
function Class:write_to_file(message)
  local file = io.open(ACTIVE_LOG_FILE, "a")
  if file then
    file:write(message .. "\n")
    file:close()
  end
end

-- Start timer
function Class:start_timer(name)
  if not IS_BENCHMARKING_ENABLED then
    return
  end

  local identifier = name or self.identifier
  self.timers[identifier] = vim.loop.hrtime()
end

-- [TIME] [SEVERITY] [FILE] [FUN] ..
function Class:time_func(name)
  if not IS_BENCHMARKING_ENABLED then
    return
  end

  local identifier = name or self.identifier
  self.timers[identifier] = vim.loop.hrtime()
end

function Class:stop_time_func(name)
  local identifier = name or self.identifier
  local elapsed = vim.loop.hrtime() - self.timers[identifier]

  local time = os.date(ACTIVE_TIME_FORMAT)
  local file = self.source.root

  local conversion_denominator = MEASUREMENT_DENOMINATORS[ACTIVE_UNIT_OF_MEASUREMENT]
  local tail = DEFAULT_TIMER_TAIL
  local severity = DEFAULT_SEVERITY["benchmarking"]
  local converted_time = elapsed / conversion_denominator
  local identity = file .. ":" .. identifier .. "()"
  local msg = self:create_message("FUN", time, severity, identity, converted_time, tail)
  self:log(msg, severity, nil)
end

-- Stop timer and log
-- TIME | SEVERITY FILE ELAPSED UNIT
function Class:stop_timer(name)
  if not IS_BENCHMARKING_ENABLED then
    return
  end

  local time = os.date(ACTIVE_TIME_FORMAT)
  local file = self.source.root
  local identifier = name or self.identifier
  local elapsed = vim.loop.hrtime() - self.timers[identifier]

  local conversion_denominator = MEASUREMENT_DENOMINATORS[ACTIVE_UNIT_OF_MEASUREMENT]
  local tail = DEFAULT_TIMER_TAIL
  local severity = DEFAULT_SEVERITY["benchmarking"]
  local converted_time = elapsed / conversion_denominator

  local msg = self:create_message("TIMER", time, severity, file, converted_time, tail)
  self:log(msg, severity, nil)
end

-- Non-blocking benchmarking
function Class:benchmark_fn(name, fn)
  self:start_timer(name)
  vim.defer_fn(function()
    fn()
    self:stop_timer(name)
  end, 0)
end

return Class
