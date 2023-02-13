---@class Endpoint
---@field value number|nil
---@field open boolean|nil

---@class Interval
---@field left Endpoint
---@field right Endpoint

---@class SubfunctionDef
---@field right Endpoint
---@field subfunction Formula

---@type fun(endpoint?: Endpoint):Endpoint
local function clone(endpoint)
  return endpoint and {
    value = endpoint.value,
    open = endpoint.open
  } or {value = nil, open = nil}
end

---@type fun(interval: Interval, parameter: number):boolean
local function betweenInterval(interval, parameter)
  if parameter == interval.left.value and interval.left.open then return false end
  if parameter == interval.right.value and interval.right.open then return false end
  if interval.left.value and parameter < interval.left.value then return false end
  if interval.right.value and parameter > interval.right.value then return false end
  return true
end

-- Starts definition of continuous piecewise function by defining leftmost endpoint.
---@type fun(leftEndpoint?:Endpoint):Piecewise
local function newPiecewise(leftEndpoint)
  local leftmost = clone(leftEndpoint)
  local rightmost = clone(leftEndpoint)

  ---@type SubfunctionDef[]
  local subfunctions = {}

  ---@class Piecewise
  local piwi = {}

  ---@alias Formula fun(parameter:number):any
  ---@type fun(subfunction:Formula, rightEndpoint?:Endpoint):Piecewise
  function piwi.newSubfunction(subfunction, rightEndpoint)
    local r = clone(rightEndpoint)

    assert(rightmost.value, "Right most endpoint is infinite. Cannot add more subfunctions...")
    assert((r.value > leftmost.value) or (leftmost.open and not r.open), "rightEndpoint provided is not bigger that leftmost endpoint...")
    assert((r.value > rightmost.value) or (rightmost.open and not r.open), "rightEndpoint provided is not bigger that rightmost endpoint...")

    rightmost = clone(r)

    table.insert(subfunctions, {
      right = r,
      subfunction = subfunction
    })

    return piwi
  end

  ---@type fun(parameter:number):any
  function piwi.call(parameter)
    local left = leftmost
    for _, subfunction in ipairs(subfunctions) do
      if betweenInterval({left = left, right = subfunction.right}, parameter) then
        return subfunction.subfunction(parameter)
      end
      left = clone(subfunction.right)
      left.open = not left.open
    end

    error("Piecewise is undefined for the value of the provided parameter: " .. parameter)
  end

  return piwi
end

return newPiecewise