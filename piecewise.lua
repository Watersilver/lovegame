local piwi = {}


-- TO DO. CONNECT DOMAIN FUNCTION??


local emptyTable = {}

local function greaterThan(value1, value2, strict)

  if strict then
    return value1 > value2
  else
    return value1 >= value2
  end

end

-- WARNING not optimal at all
local function determineDomain(domains, t)
  for _, domain in ipairs(domains) do
    if greaterThan(t, domain.x1.value, not domain.x1.closed) and greaterThan(domain.x2.value, t, not domain.x2.closed) then
      return domain
    end
  end
end

function piwi.new()
  local newPiwi = {}

  -- init
  newPiwi.domains = {}
  newPiwi.namedDomains = {}

  -- assumed domain input structure:
  -- dom = {x1 = {value = x, closed = bool1}, x2 = {value = y, closed = bool2}}
  -- x1 value is assumend bigger than x2 value
  function newPiwi.newSubfunction(newDomain, subfunction, settings)
    settings = settings or emptyTable

    local nx1 = newDomain.x1
    local nx2 = newDomain.x2

    -- ensure there are no overlapping domains
    for _, prevDomain in ipairs(newPiwi.domains) do
      local px1 = prevDomain.x1
      local px2 = prevDomain.x2
      if not (greaterThan(nx1.value, px2.value, nx1.closed and px2.closed) or
        greaterThan(px1.value, nx2.value, px1.closed and nx2.closed)) then
          return false
      end
    end

    local startVars = settings.startVars
    local endVars = settings.endVars

    newDomain.subfunction = {
      run = subfunction,
      startVars = startVars,
      endVars = endVars
    }

    table.insert(newPiwi.domains, newDomain)

    if settings.name then
      newPiwi.namedDomains[settings.name] = newDomain
    end

    return true
  end

  function newPiwi.run(t)
    local currentDomain = determineDomain(newPiwi.domains, t)
    return currentDomain.subfunction.run(t, currentDomain.subfunction.startVars, currentDomain.subfunction.endVars)
  end

  return newPiwi
end

return piwi
