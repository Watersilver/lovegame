local oldRequire = require

local require_plus = {}

setmetatable(require_plus, {__call = function(_,path) return oldRequire(path) end})

-- require_plus.tree private functions
--
local lfs   = love.filesystem
local cache = {}

local function toFSPath(requirePath)
  local fsPath = requirePath:gsub("%.", "/")
  return fsPath:gsub("/lua", ".lua")
end
local function toRequirePath(fsPath) return fsPath:gsub('/','.') end
local function noExtension(path)     return path:gsub('%.lua$', '') end
local function noEndDot(str)         return str:gsub('%.$', '') end

function require_plus.tree(requirePath)
  if not cache[requirePath] then
    local result = {}

    local fsPath = toFSPath(requirePath)
    local entries = lfs.getDirectoryItems(fsPath)

    for _,entry in ipairs(entries) do
      fsPath = toFSPath(requirePath .. '.' .. entry)
      local info = lfs.getInfo(fsPath)
      if info.type == 'directory' then
        result[entry] = require_plus.tree(toRequirePath(fsPath))
      else
        entry = noExtension(entry)
        result[entry] = require_plus(toRequirePath(requirePath .. '/' .. entry))
      end
    end

    cache[requirePath] = result
  end

  return cache[requirePath]
end

function require_plus.path(filePath)
  return noEndDot(noExtension(filePath):match("(.-)[^%.]*$"))
end

function require_plus.relative(...)
  local args = {...}
  local first, last = args[1], args[#args]
  local path = require_plus.path(first)
  return require_plus(path .. '.' .. last)
end

return require_plus