---@class LDTK153TilesetRect
---@field h integer Height in pixels
---@field tilesetUid integer UID of the tileset
---@field w integer Width in pixels
---@field x integer X pixels coordinate of the top-left corner in the Tileset image
---@field y integer Y pixels coordinate of the top-left corner in the Tileset image

---@class LDTK153TilesetDef
---@field __cHei integer Grid-based height
---@field __cWid integer Grid-based width
---@field customData {data: string, tileId: integer}[] An array of custom tile metadata
---@field embedAtlas "LdtkIcons" | nil If this value is set, then it means that this atlas uses an internal LDtk atlas image instead of a loaded one.
---@field enumTags {enumValueId: string, tileIds: integer[]}[] Tileset tags using Enum values specified by tagsSourceEnumId. This array contains 1 element per Enum value, which contains an array of all Tile IDs that are tagged with it.
---@field identifier string User defined unique identifier
---@field padding integer Distance in pixels from image borders
---@field pxHei integer Image height in pixels
---@field pxWid integer Image width in pixels
---@field relPath string | nil Path to the source file, relative to the current project JSON file. It can be null if no image was provided, or when using an embed atlas.
---@field spacing integer Space in pixels between all tiles
---@field tags string[] An array of user-defined tags to organize the Tilesets
---@field tagsSourceEnumUid integer | nil Optional Enum definition UID used for this tileset meta-data
---@field tileGridSize integer Side in pixels of each square of the grid
---@field uid integer Unique Intidentifier


---@class LDTK153IntGridValue
---@field color string Hex color "#rrggbb"
---@field groupUid integer Parent group identifier (0 if none)
---@field identifier string | nil User defined unique identifier
---@field tile LDTK153TilesetRect | nil
---@field value integer The IntGrid value itself

---@class LDTK153IntGridValuesGroup
---@field color string | nil User defined color
---@field identifier string | nil User defined string identifier
---@field uid integer Group unique ID

---@class LDTK153LayerDef
---@field __type string Type of the layer (IntGrid, Entities, Tiles or AutoLayer)
---@field autoSourceLayerDefUid integer | nil (Auto-layers only)
---@field displayOpacity number Opacity of the layer (0 to 1.0)
---@field gridSize integer Width and height of the grid in pixels
---@field identifier string User defined unique identifier
---@field intGridValues LDTK153IntGridValue[] (IntGrid layer only) An array that defines extra optional info for each IntGrid value. WARNING: the array order is not related to actual IntGrid values! As user can re-order IntGrid values freely, you may value "2" before value "1" in this array.
---@field intGridValuesGroups LDTK153IntGridValuesGroup[] (IntGrid layer only) Group informations for IntGrid values
---@field parallaxFactorX number Parallax horizontal factor (from -1 to 1, defaults to 0) which affects the scrolling speed of this layer, creating a fake 3D (parallax) effect.
---@field parallaxFactorY number Parallax vertical factor (from -1 to 1, defaults to 0) which affects the scrolling speed of this layer, creating a fake 3D (parallax) effect.
---@field parallaxScaling boolean If true (default), a layer with a parallax factor will also be scaled up/down accordingly.
---@field pxOffsetX integer X offset of the layer, in pixels (IMPORTANT: this should be added to the LayerInstance optional offset)
---@field pxOffsetY integer Y offset of the layer, in pixels (IMPORTANT: this should be added to the LayerInstance optional offset)
---@field tilesetDefUid integer | nil (Tile layers & Auto-layers only) Reference to the default Tileset UID being used by this layer definition. WARNING: some layer instances might use a different tileset. So most of the time, you should probably use the __tilesetDefUid value found in layer instances. Note: since version 1.0.0, the old autoTilesetDefUid was removed and merged into this value.
---@field uid integer Unique Int identifier

--- This section is mostly only intended for the LDtk editor app itself. You can safely ignore it.
---@class LDTK153FieldDef

---@class LDTK153EntityDef
---@field color string Base entity color (Hex color "#rrggbb")
---@field height integer Pixel height
---@field identifier string User defined unique identifier
---@field nineSliceBorders integer[] An array of 4 dimensions for the up/right/down/left borders (in this order) when using 9-slice mode for tileRenderMode. If the tileRenderMode is not NineSlice, then this array is empty. See: https://en.wikipedia.org/wiki/9-slice_scaling
---@field pivotX number Pivot X coordinate (from 0 to 1.0)
---@field pivotY number Pivot Y coordinate (from 0 to 1.0)
---@field tileRect LDTK153TilesetRect | nil An object representing a rectangle from an existing Tileset
---@field tileRenderMode "Cover" | "FitInside" | "Repeat" | "Stretch" | "FullSizeCropped" | "FullSizeUncropped" | "NineSlice" An enum describing how the the Entity tile is rendered inside the Entity bounds.
---@field tilesetId integer | nil Tileset ID used for optional tile display
---@field uiTileRect LDTK153TilesetRect | nil This tile overrides the one defined in tileRect in the UI
---@field uid integer Unique Int identifier
---@field width integer Pixel width


---@class LDTK153EnumValue
---@field color integer Optional color
---@field id string Enum value
---@field tileRect LDTK153TilesetRect | nil Optional tileset rectangle to represents this value

---@class LDTK153EnumDef
---@field externalRelPath string | nil Relative path to the external file providing this Enum
---@field iconTilesetUid integer | nil Tileset UID if provided
---@field identifier string User defined unique identifier
---@field tags string[] An array of user-defined tags to organize the Enums
---@field uid integer Unique Int identifier
---@field values LDTK153EnumValue[] All possible enum values, with their optional Tile infos.


---@class LDTK153TileInst
---@field a number Alpha/opacity of the tile (0-1, defaults to 1)
--- "Flip bits", a 2-bits integer to represent the mirror transformations of the tile.
--- - Bit 0 = X flip
--- - Bit 1 = Y flip
--- Examples: f=0 (no flip), f=1 (X flip only), f=2 (Y flip only), f=3 (both flips)
---@field f integer
---@field px [integer, integer] Pixel coordinates of the tile in the layer ([x,y] format). Don't forget optional layer offsets, if they exist!
---@field src [integer, integer] Pixel coordinates of the tile in the tileset ([x,y] format)
---@field t integer The Tile ID in the corresponding tileset.


---@class LDTK153GridPoint
---@field cx integer X grid-based coordinate
---@field cy integer Y grid-based coordinate

---@class LDTK153EntInstRef
---@field entityIid string IID of the refered EntityInstance
---@field layerIid string IID of the LayerInstance containing the refered EntityInstance
---@field levelIid string IID of the Level containing the refered EntityInstance
---@field worldIid string IID of the World containing the refered EntityInstance

---@class LDTK153FieldInst
---@field __identifier string Field definition identifier
---@field __tile LDTK153TilesetRect | nil Optional TilesetRect used to display this field (this can be the field own Tile, or some other Tile guessed from the value, like an Enum).
---Type of the field, such as Int, Float, String, Enum(my_enum_name), Bool, etc.
---NOTE: if you enable the advanced option Use Multilines type, you will have "Multilines" instead of "String" when relevant.
---@field __type string
--- Actual value of the field instance. The value type varies, depending on __type:
--- - For classic types (ie. Integer, Float, Boolean, String, Text and FilePath), you just get the actual value with the expected type.
--- - For Color, the value is an hexadecimal string using "#rrggbb" format.
--- - For Enum, the value is a String representing the selected enum value.
--- - For Point, the value is a GridPoint object.
--- - For Tile, the value is a TilesetRect object.
--- - For EntityRef, the value is an EntityReferenceInfos object.
--- 
--- If the field is an array, then this __value will also be a JSON array.
--- 
--- (Note to self: might want to create a union type that is stricter and couples this value to "__type")
---@field __value integer | number | boolean | string | LDTK153GridPoint | LDTK153TilesetRect | LDTK153EntInstRef
---@field defUid integer Reference of the Field definition UID


---@class LDTK153EntityInst
---@field __grid [integer, integer] Grid-based coordinates ([x,y] format)
---@field __identifier string Entity definition identifier
---@field __pivot [number, number] Pivot coordinates ([x,y] format, values are from 0 to 1) of the Entity
---@field __smartColor string The entity "smart" color, guessed from either Entity definition, or one its field instances.
---@field __tags string[] Array of tags defined in this Entity definition
---@field __tile LDTK153TilesetRect | nil Optional TilesetRect used to display this entity (it could either be the default Entity tile, or some tile provided by a field value, like an Enum).
---@field __worldX integer | nil X world coordinate in pixels. Only available in GridVania or Free world layouts.
---@field __worldY integer | nil Y world coordinate in pixels Only available in GridVania or Free world layouts.
---@field defUid integer Reference of the Entity definition UID
---@field fieldInstances LDTK153FieldInst[] An array of all custom fields and their values.
---@field height integer Entity height in pixels. For non-resizable entities, it will be the same as Entity definition.
---@field iid string Unique instance identifier
---@field px [integer, integer] Pixel coordinates ([x,y] format) in current level coordinate space. Don't forget optional layer offsets, if they exist!
---@field width integer Entity width in pixels. For non-resizable entities, it will be the same as Entity definition.


---@class LDTK153LayerInst
---@field __cHei integer Grid-based height
---@field __cWid integer Grid-based width
---@field __gridSize integer Width and height of the grid in pixels
---@field __identifier string Layer definition identifier
---@field __opacity number Layer opacity as Float [0-1]
---@field __pxTotalOffsetX integer Total layer X pixel offset, including both instance and definition offsets.
---@field __pxTotalOffsetY integer Total layer Y pixel offset, including both instance and definition offsets.
---@field __tilesetDefUid integer | nil (Tile layers & Auto-layers only) The definition UID of corresponding Tileset, if any.
---@field __tilesetRelPath string | nil (Tile layers & Auto-layers only) The relative path to corresponding Tileset, if any.
---@field __type string Layer type (possible values: IntGrid, Entities, Tiles or AutoLayer)
--- An array containing all tiles generated by Auto-layer rules. The array is already sorted in display order (ie. 1st tile is beneath 2nd, which is beneath 3rd etc.).
---
--- Note: if multiple tiles are stacked in the same cell as the result of different rules, all tiles behind opaque ones will be discarded.
---@field autoLayerTiles LDTK153TileInst[]
---@field entityInstances LDTK153EntityInst[] (Entity layers only)
---@field gridTiles LDTK153TileInst[] (Tile layers only)
---@field iid string Unique layer instance identifier
--- (IntGrid layers only) A list of all values in the IntGrid layer, stored in CSV format (Comma Separated Values).
--- Order is from left to right, and top to bottom (ie. first row from left to right, followed by second row, etc).
--- 0 means "empty cell" and IntGrid values start at 1.
--- The array size is __cWid x __cHei cells.
---@field intGridCsv integer[]
---@field layerDefUid integer Reference the Layer definition UID
---@field levelId integer Reference to the UID of the level containing this layer instance
---@field overrideTilesetUid integer | nil (Tile layers only) This layer can use another tileset by overriding the tileset UID here.
---@field pxOffsetX integer X offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the LayerDef optional offset, so you should probably prefer using __pxTotalOffsetX which contains the total offset value)
---@field pxOffsetY integer Y offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the LayerDef optional offset, so you should probably prefer using __pxTotalOffsetX which contains the total offset value)
---@field visible boolean Layer instance visibility


---@class LDTK153BgPos
---@field cropRect [number, number, number, number] An array of 4 float values describing the cropped sub-rectangle of the displayed background image. This cropping happens when original is larger than the level bounds. Array format: [ cropX, cropY, cropWidth, cropHeight ]
---@field scale [number, number] An array containing the [scaleX,scaleY] values of the cropped background image, depending on bgPos option.
---@field topLeftPx [integer, integer] An array containing the [x,y] pixel coordinates of the top-left corner of the cropped background image, depending on bgPos option.

---@class LDTK153Neighbour
---@field dir "n" | "s" | "w" | "e" | "<" | ">" | "o" | "nw" | "ne" | "sw" | "se" A lowercase string tipping on the level location (north, south, west, east). Since 1.4.0, this value can also be < (neighbour depth is lower), > (neighbour depth is greater) or o (levels overlap and share the same world depth). Since 1.5.3, this value can also be nw,ne,sw or se for levels only touching corners.
---@field levelIid string Neighbour Instance Identifier

--- This section contains all the level data. It can be found in 2 distinct forms, depending on Project current settings:
---
--- A ldtkl file is just a JSON file containing exactly what is described below.
---@class LDTK153Level
---@field __bgColor string Background color of the level (same as bgColor, except the default value is automatically used here if its value is null) (Hex color "#rrggbb")
---@field __bgPos LDTK153BgPos | nil Position informations of the background image, if there is one.
--- An array listing all other levels touching this one on the world map. Since 1.4.0, this includes levels that overlap in the same world layer, or in nearby world layers.
--- Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, this array is always empty.
---@field __neighbours LDTK153Neighbour[]
---@field bgRelPath string | nil The optional relative path to the level background image.
---@field externalRelPath string | nil This value is not null if the project option "Save levels separately" is enabled. In this case, this relative path points to the level Json file.
---@field fieldInstances LDTK153FieldInst[] An array containing this level custom field values.
---@field identifier string User defined unique identifier
---@field iid string Unique instance identifier
--- An array containing all Layer instances. IMPORTANT: if the project option "Save levels separately" is enabled, this field will be null.
--- This array is sorted in display order: the 1st layer is the top-most and the last is behind.
---@field layerInstances LDTK153LayerInst[] | nil
---@field pxHei integer Height of the level in pixels
---@field pxWid integer Width of the level in pixels
---@field uid integer Unique Int identifier
--- Index that represents the "depth" of the level in the world. Default is 0, greater means "above", lower means "below".
--- This value is mostly used for display only and is intended to make stacking of levels easier to manage.
---@field worldDepth integer
--- World X coordinate in pixels.
--- Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the value is always -1 here.
---@field worldX integer
--- World Y coordinate in pixels.
--- Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the value is always -1 here.
---@field worldY integer


---@class LDTK153World
---@field identifier string User defined unique identifier
---@field iid string Unique instance identifer
---@field levels LDTK153Level[] All levels from this world. The order of this array is only relevant in LinearHorizontal and linearVertical world layouts (see worldLayout value). Otherwise, you should refer to the worldX,worldY coordinates of each Level.
---@field worldGridHeight integer ('GridVania' layouts only) Height of the world grid in pixels.
---@field worldGridWidth integer ('GridVania' layouts only) Width of the world grid in pixels.
---@field worldLayout "Free" | "GridVania" | "LinearHorizontal" | "LinearVertical" An enum that describes how levels are organized in this project (ie. linearly or in a 2D space).


--- If you're writing your own LDtk importer, you should probably just ignore most stuff in the defs section, as it contains data that are mostly important to the editor. To keep you away from the defs section and avoid some unnecessary JSON parsing, important data from definitions is often duplicated in fields prefixed with a double underscore (eg. __identifier or __type).
--- 
--- The 2 only definition types you might need here are Tilesets and Enums.
---@class LDTK153Definitions
---@field entities LDTK153EntityDef[] All entities definitions, including their custom fields
---@field enums LDTK153EnumDef[] All internal enums
---@field externalEnums LDTK153EnumDef[] Note: external enums are exactly the same as enums, except they have a relPath to point to an external source file.
---@field layers LDTK153LayerDef[] All layer definitions
---@field levelFields LDTK153FieldDef[] All custom fields available to all levels.
---@field tilesets LDTK153TilesetDef[] All tilesets

---@class LDTK153TocInstDatum
---@field fields any An object containing the values of all entity fields with the exportToToc option enabled. This object typing depends on actual field value types.
---@field heiPx integer
---@field iids LDTK153EntInstRef
---@field widPx integer
---@field worldX integer
---@field worldY integer

--- Entity exported to table of contents
---@class LDTK153TocObj
---@field instancesData LDTK153TocInstDatum[]

---@class LDTK153Root
---@field bgColor string Project background color (Hex color "#rrggbb")
---@field defs LDTK153Definitions A structure containing all the definitions of this project
---@field externalLevels boolean If TRUE, one file will be saved for the project (incl. all its definitions) and one file in a sub-folder for each level.
---@field iid string Unique project identifier
---@field jsonVersion string File format version
---@field levels LDTK153Level[] All levels. The order of this array is only relevant in LinearHorizontal and linearVertical world layouts (see worldLayout value). Otherwise, you should refer to the worldX,worldY coordinates of each Level. (My Note: Seems this is empty on multiworld projects)
---@field toc LDTK153TocObj[] All instances of entities that have their exportToToc flag enabled are listed in this array.
--- WARNING: this field will move to the worlds array after the "multi-worlds" update. It will then be null. You can enable the Multi-worlds advanced project option to enable the change immediately.
---
--- Height of the world grid in pixels.
---@field worldGridHeight integer | nil
--- WARNING: this field will move to the worlds array after the "multi-worlds" update. It will then be null. You can enable the Multi-worlds advanced project option to enable the change immediately.
--- 
--- Width of the world grid in pixels.
---@field worldGridWidth integer | nil
--- WARNING: this field will move to the worlds array after the "multi-worlds" update. It will then be null. You can enable the Multi-worlds advanced project option to enable the change immediately.
--- 
--- An enum that describes how levels are organized in this project (ie. linearly or in a 2D space).
---@field worldLayout "Free" | "GridVania" | "LinearHorizontal" | "LinearVertical" | nil
--- This array will be empty, unless you enable the Multi-Worlds in the project advanced settings.
---
--- - in current version, a LDtk project file can only contain a single world with multiple levels in it. In this case, levels and world layout related settings are stored in the root of the JSON.
--- - with "Multi-worlds" enabled, there will be a worlds array in root, each world containing levels and layout settings. Basically, it's pretty much only about moving the levels array to the worlds array, along with world layout related values (eg. worldGridWidth etc).
---
--- If you want to start supporting this future update easily, please refer to this documentation: https://github.com/deepnight/ldtk/issues/231
---@field worlds LDTK153World[]


local u = require "utilities"


---Convert to string for room name (and replace - with _ like ldtk)
local function numToRoomCoord(num)
  if num < 0 then
    num = -num
    return "_"..tostring(num)
  else
    return tostring(num)
  end
end


---@param lb LDtKBuilder
---@param worldName string
---@param x number
---@param y number
---@param z number
---@return LDTK153Level|nil
local function findRoom(lb, worldName, x, y, z)
  ---@type LDTK153World
  local world
  for _, w in ipairs(lb.universe.worlds) do
    if w.identifier == worldName then
      world = w
      break
    end
  end
  if not world then return end -- TODO? Add default world

  ---@type LDTK153Level
  local level
  for _, lvl in ipairs(world.levels) do
    if lvl.identifier == worldName.."_at_"..numToRoomCoord(x).."x"..numToRoomCoord(y).."x"..numToRoomCoord(z) then
      level = lvl
      break
    end
  end
  if not level then return end -- TODO? Add default level

  return level
end


---@param iid string instance identifier
---@return LDTK153Level|nil
local function findLevelByIid(lb, worldName, iid)
  ---@type LDTK153World
  local world
  for _, w in ipairs(lb.universe.worlds) do
    if w.identifier == worldName then
      world = w
      break
    end
  end
  if not world then return end

  ---@type LDTK153Level
  local level
  for _, lvl in ipairs(world.levels) do
    if lvl.iid == iid then
      level = lvl
      break
    end
  end
  if not level then return end

  return level
end


---@param lb LDtKBuilder
---@param worldName string
---@param x number
---@param y number
---@param z number
local function buildRoom(lb, worldName, x, y, z)

  local sto = require "RoomBuilding.symbols_to_objects"
  local tts = require "RoomBuilding.tilesets_to_symbols"
  local tilesets = require "RoomBuilding.tilesets"

  local level = findRoom(lb, worldName, x, y, z)
  if not level then return end -- Add default level

  for i, layer in ipairs(level.layerInstances) do
    local unmerged = {layer.gridTiles, layer.autoLayerTiles}
    local merged = u.concatArrays(unmerged)
    for _, tile in ipairs(merged) do

      ---@type LDTK153TilesetDef
      local t
      local tilesetIndex = 0
      for _, ts in ipairs(lb.universe.defs.tilesets) do
        if ts.identifier == "Floor" and (layer.__identifier == "Floor" or layer.__identifier == "AutoFloor") then
          t = ts
          tilesetIndex = 1
          break
        elseif ts.identifier == "Walls" and (layer.__identifier == "Walls" or layer.__identifier == "AutoWalls") then
          t = ts
          tilesetIndex = 2
          break
        elseif ts.identifier == "Portals" and layer.__identifier == "Portals" then
          t = ts
          tilesetIndex = 3
          break
        elseif ts.identifier == "Edges" and layer.__identifier == "Edges" then
          t = ts
          tilesetIndex = 4
          break
        elseif ts.identifier == "Clutter" and layer.__identifier == "Clutter" then
          t = ts
          tilesetIndex = 5
          break
        end
      end
      local invSquareSize = 1 / (t.tileGridSize + t.spacing)
      local gridWidth = t.pxWid * invSquareSize
      local tileIndex = (tile.src[1] - t.padding) * invSquareSize + (tile.src[2] - t.padding) * invSquareSize * gridWidth

      local element
      local tileset = tilesets[tilesetIndex]
      local tilesetName = tileset[1]
      local symbol = tts[tilesetName][tileIndex]
      -- Replace this with custom tile data and entity that exists on the same tile
      -- local initFields = tts[tilesetName].initFields[objInfo.i]
      -- if initFields then
      --   for k,v in pairs(initFields) do objInfo.n[k] = v end
      -- end
      if not (symbol == 'n' or not symbol) then
        local objInfo = {
          x = tile.px[1] + 8,
          y = tile.px[2] + 8,
          i = tileIndex,
          t = tilesetIndex,
          n = {}
        }
        objInfo.n.layer = #level.layerInstances - i
        element = sto[symbol]:new(objInfo.n)
        -- Determine sprite
        element.sprite_info = {tileset}
        element.image_index = objInfo.i

        -- Create tiles
        if element.physical_properties and element.physical_properties.tile then
          element.physical_properties.tile = {"u", "d", "l", "r"}
        end

        element.xstart = objInfo.x
        element.ystart = objInfo.y
        element.x = objInfo.x
        element.y = objInfo.y
        local o = require "GameObjects.objects"
        o.addToWorld(element)
      end
    end
  end
end


local json = require "jsonlua.json"

local worldsStr = love.filesystem.read("LDtk/test.ldtk")

---@type LDTK153Root
local universe = json.decode(worldsStr)

---@class LDtKBuilder
local ldtk = {
  universe = universe,
  worldNames = (function()
    ---@type table<string,boolean|nil>
    local wn = {}
    for _, w in ipairs(universe.worlds) do
      wn[w.identifier] = true
    end
    return wn
  end)(),
  buildRoom = buildRoom,
  findRoom = findRoom,
  findLevelByIid = findLevelByIid
}

return ldtk