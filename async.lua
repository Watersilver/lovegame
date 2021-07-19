local llMethods = {
  pushBack = function (self, value)
    local node = {value = value}
    if not first then
      self.first = node
      self.last = node
    else
      node.previous = self.last
      self.last.next = node
      self.last = node
    end
  end,

  pushFront = function (self, value)
    local node = {value = value}
    if not first then
      self.first = node
      self.last = node
    else
      node.next = self.first
      self.first.previous = node
      self.first = node
    end
  end,

  findNode = function (self, value)
    local node = self.first

    while node do
      if node.value == value then return node end
      node = node.next
    end
    return {}
  end,

  delete = function (self, node)
    if self.last == node then
      self.last = node.previous
    end
    if self.first == node then
      self.first = node.next
    end

    if node.next then
      node.next.previous = node.previous
    end
    if node.previous then
      node.previous.next = previous.next
    end
  end,

  isEmpty = function (self)
    return not self.first
  end,

  count = function (self)
    local node = self.first
    local c = 0

    while node do
      c = c + 1
      node = node.next
    end

    return c
  end
}

local function newLinkedList()
  local ll = {
    first = nil,
    last = nil
  }

  for methodname, method in pairs(llMethods) do
    ll[methodname] = method
  end

  return ll
end

local callbacks = {
  realTime = newLinkedList(),
  gameTime = newLinkedList()
}

local update = function (timeFlowType, dt)
  local node = callbacks[timeFlowType].first

  while node do
    local v = node.value

    if v.cancel and v.cancel() then
      if v.cancelCallback then
        v.cancelCallback()
      end
      if v.finally then v.finally() end
      callbacks[timeFlowType]:delete(node)
    else
      local run = false
      if (type(v.runCondition) == "number") then
        if v.runCondition <= 0 then run = true end
        v.runCondition = v.runCondition - dt
      else
        if v.runCondition(dt) then run = true end
      end
      if run then
        v.callback()
        if v.finally then v.finally() end
        callbacks[timeFlowType]:delete(node)
      end
    end

    node = node.next
  end
end

local function parseAsyncTable(table)
  return (table.callback or table[1]),
  (table.runCondition or table[2] or 0),
  (table.cancel or table[3]),
  (table.cancelCallback or table[4]),
  (table.finally or table[5])
end

local function convertToAsyncTable(...)
    if type(select(1, ...)) == "table" then return select(1, ...) end
    return {...}
end

async = {
  realTimeUpdate = function (dt)
    update("realTime", dt)
  end,

  gameTimeUpdate = function (dt)
    update("gameTime", dt)
  end,

  realTime = function (...)
    local asyncTable = convertToAsyncTable(...)
    local callback, runCondition, cancel, cancelCallback, finally = parseAsyncTable(asyncTable)

    callbacks.realTime:pushBack{
      callback = callback,
      runCondition = runCondition,
      cancel = cancel,
      cancelCallback = cancelCallback,
      finally = finally
    }
  end,

  gameTime = function (...)
    local asyncTable = convertToAsyncTable(...)
    local callback, runCondition, cancel, cancelCallback, finally = parseAsyncTable(asyncTable)

    callbacks.gameTime:pushBack{
      callback = callback,
      runCondition = runCondition,
      cancel = cancel,
      cancelCallback = cancelCallback,
      finally = finally
    }
  end,
}

-- Chain functions
local function iterateBackwards (asyncList, value, property)
  value = value or true
  for i = #asyncList, 1, -1 do
    if asyncList[i][property] then return end
    asyncList[i][property] = value
  end
end

local function afterwards (asyncList, ...)
  local asyncTable = convertToAsyncTable(...)
  table.insert(asyncList, asyncTable)
end

local function unless (asyncList, condition)
  iterateBackwards(asyncList, condition, "cancel")
end

local function onCancel (asyncList, callback)
  iterateBackwards(asyncList, callback, "cancelCallback")
end

local function finally (asyncList, callback)
  iterateBackwards(asyncList, callback, "finally")
end

local function cleanAsyncTable(asyncTable)
  -- If these values are true, they were here to block
  -- iterateBackwards. Nilify them because they do nothing else
  if asyncTable.cancel == true then asyncTable.cancel = nil end
  if asyncTable.cancelCallback == true then asyncTable.cancelCallback = nil end
  if asyncTable.finally == true then asyncTable.finally = nil end
end

local function start (asyncList)
  -- Create async table
  local alLength = #asyncList

  cleanAsyncTable(asyncList[#asyncList])

  for i = #asyncList - 1, 1, -1 do
    local container = asyncList[i]
    local content = asyncList[i + 1]

    cleanAsyncTable(container)

    local prevFinally = container.finally

    container.finally = function()
      if prevFinally then prevFinally() end
      -- Chain async
      async[asyncList.kind](content)
    end
  end

  -- Start async
  if asyncList[1] then async[asyncList.kind](asyncList[1]) end
end

local function newChainTable(asyncList)
  return {
    afterwards = function (...)
      afterwards(asyncList, ...)
      return newChainTable(asyncList)
    end,
    unless = function (condition)
      unless(asyncList, condition)
      return newChainTable(asyncList)
    end,
    onCancel = function (callback)
      onCancel(asyncList, callback)
      return newChainTable(asyncList)
    end,
    always = function (callback)
      finally(asyncList, callback)
      return newChainTable(asyncList)
    end,
    finally = function (callback)
      local prevFin = asyncList[#asyncList].finally
      if not prevFin then
        asyncList[#asyncList].finally = callback
      else
        asyncList[#asyncList].finally = function()
          prevFin()
          callback()
        end
      end
      return {
        start = function () start(asyncList) end
      }
    end,
    start = function () start(asyncList) end,
  }
end

async.realTimeChain = function (...)
  local asyncList = {kind="realTime"}

  afterwards(asyncList, ...)

  return newChainTable(asyncList)
end

async.gameTimeChain = function (...)
  local asyncList = {kind="gameTime"}

  afterwards(asyncList, ...)

  return newChainTable(asyncList)
end

-- new(asyncTable).
-- afterwards(asyncTable).
-- unless(condition). -- can be nil to protect from later conditions
-- onCancel(callback). -- can be nil to protect from later callbacks
-- finally(callback) -- can be nil to protect from later callbacks

-- asyncTable is table with 1, 2, 3, 4, 5
-- callback, runCondition, cancel, cancelCallback, finally
-- respectivelly
-- But it can have named variables

-- unless, onCancel and finally only apply to previous asyncTables
-- for which they aren't already set
