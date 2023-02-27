local game = require 'game'

---@type table<string, {table?: {r: number[], g: number[], b: number[]}, determine: fun(): {r: number[], g: number[], b: number[]}}>
local paletteTable = {
  normal = {
    table = {
      r = {1, 0, 0, 1},
      g = {0, 1, 0, 1},
      b = {0, 0, 1, 1}
    }
  }
}

---@return { r: number[], g: number[], b: number[] }
local function determinePalette()
  local p = game.room.palette

  if type(p) == 'table' then return p end

  if type(p) == 'function' then return p() end

  local t = paletteTable[p]

  if not t then return paletteTable.normal.table end

  if t.table then return t.table end

  return t.determine()
end

return determinePalette