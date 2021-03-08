local tilesets_to_symbols = {}
tilesets_to_symbols['Tiles/Floor'] = {
  [0] = 'g', 'f', 'g', 'f', 'g', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',
  -- Snow area 1
  'f', 'f', 'f', 'f', 'g', 'f', 'g', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'aF2', 'n', 'n', 'n',

  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'ga', 'f', 'f', 'f', 'ga', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  -- Snow area 2
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'ga', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',

  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'shW', 'n', 'n',
  'f', 'f', 'f', 'f', 'f', 'shW', 'n', 'n',
  'f', 'f', 'f', 'f', 'f', 'shW', 'n', 'n',
  'wa2', 'n', 'n', 'n', 'wa2', 'n', 'n', 'n',
  'wa2', 'n', 'n', 'n', 'wa2', 'n', 'n', 'n',
  'ld', 'st', 'ld', 'ld', 'f', 'f', 'f', 'f',
  'ld', 'f', 'ld', 'ld', 'f', 'f', 'f', 'f',
  'ld', 'f', 'f', 'ld', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'ga', 'ga', 'ga', 'ga', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'iF',
  'f', 'f', 'f', 'f', 'f', 'ga', 'f', 'f',
}
tilesets_to_symbols['Tiles/Floor'].initFields = {}
tilesets_to_symbols['Tiles/Walls'] = {
  [0] = 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  -- bush and snow
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',

  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  -- waterfall
  'w1234', 'n', 'n', 'n', 'deD', 'w', 'w',
  'w1234', 'n', 'n', 'n', 'deU', 'deR', 'deL',
  'w', 'w', 'deD', 'w', 'w', 'w', 'w',
  'deR', 'deL', 'deU', 'w', 'w', 'b', 'b',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  -- torch
  'deR', 'deL', 'torch', 'n', 'n', 'n', 'w',
  'w', 'w', 'torch', 'n', 'n', 'n', 'w',
  'w', 'w', 'torch', 'n', 'n', 'n', 'w',
  'deR', 'deL', 'torch', 'n', 'n', 'n', 'w',
  'w', 'w', 'deD', 'w', 'w', 'w', 'w',
  'w', 'w', 'deU', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'twu', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w',
}
tilesets_to_symbols['Tiles/Walls'].initFields = {}
tilesets_to_symbols['Tiles/Portals'] = {
  [0] = 'ptlToOutside', 'ptl', 'ptl', 'ptl', 'ptl',
  'ptl', 'ptl', 'ptl', 'ptl', 'ptl',
  'ptl', 'ptl', 'ptl', 'ptl', 'ptl',
}
tilesets_to_symbols['Tiles/Portals'].initFields = {}
tilesets_to_symbols['Tiles/Edges'] = {
  [0] = 'eD', 'eD',
  'eR', 'eL',
}
tilesets_to_symbols['Tiles/Edges'].initFields = {}
tilesets_to_symbols['Tiles/Clutter'] = {
  [0] = 'rT', 'sL', 'sL', 'sL', 'sL', 'sL', 'rW', 'rW',
  'rW', 'rW', 'w', 'rW', 'rW', 'rW', 'rW', 'rW',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'twu', 'twu', 'twu', 'twu', 'twu', 'twu',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'rW',
  'b', 'b', 'b', 'b', 'w', 'w', 'b', 'rT',
  'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b',
  'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b',
  'rW', 'rW', 'rW2', 'rW', 'rW2', 'ptl', 'rW', 'w',
  'sL', 'sL', 'sL', 'sL', 'b', 'b', 'b', 'b',
  'db', 'db2', 'b', 'b', 'b', 'b', 'b', 'b',
}
tilesets_to_symbols['Tiles/Clutter'].initFields = {
  [1] = {lift_info = "shrub"} -- shrub
}
return tilesets_to_symbols
