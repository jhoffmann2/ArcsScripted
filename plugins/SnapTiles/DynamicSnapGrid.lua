
-- when a SnapTile also has the "DynamicSnapGrid" tag, it will dynamically adjust it's snap points to fit any number of objects.
-- objects placed in the grid will be auto-resized to fit in exactly one grid space and objects removed from the grid
-- will be reset back to their original size.
-- if the object being added is stackable, it will stack with other stackable objects of the same name.
-- if every grid space is filled up and a unique item is being added, the grid will resize to fit it shrinking all other objects.
-- the inverse is true if there's room to shrink the grid and grow the items.

local GridInfo = {
  MinColumnCount = 0,
  MinRowCount = 0,
  CurColumnCount = 0,
  CurRowCount = 0,
  WorldSpaceGridSize = 0,
  ContainedObjects = {}
}

function onLoad(save_string)
  local save_data
  if save_string then
    save_data = JSON.decode(save_string)
  end
  if not save_data then
    save_data = {}
  end
  if save_data.GridInfo then
    GridInfo = save_data.GridInfo
  else
    Method.SetMinColumnCount(4)
  end
  UpdateGrid()
end

function onSave()
  local save_data = {
    GridInfo = GridInfo,
  }
  return JSON.encode(save_data)
end

function getPieceColor(piece)
  for _, color in ipairs(Player.getAvailableColors()) do
    if piece.hasTag(color) then
      return color
    end
  end
  return nil
end

---@param object tts__Object
---@return string
function GetProxyTileAsset(object)
  if object.hasTag('Agent') then
    if object.hasTag('Red') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903235477/470B67FC7BAC80B32D563AE01B86D75C33AE74D0/'
    end
    if object.hasTag('Blue') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903250494/AFBAF4C005A428B39AA0324FEFE2A3C33F2A7ED0/'
    end
    if object.hasTag('White') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903253487/07BD8493DAE15F5FE929DA143A34E77C57BB70B3/'
    end
    if object.hasTag('Yellow') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903240710/0CED8944D5968E90FCD15CF8691629A42E88E4DA/'
    end
  end
  if object.hasTag('Ship') then
    if object.hasTag('Imperial') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903256026/48B40CF9BBF657DA0E739779FAE7F2765705033C/'
    end
    if object.hasTag('Red') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903237368/DD2186FEE7F679EDE557F009B0EB654ADBAA1A81/'
    end
    if object.hasTag('Blue') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903251432/094AE8F03B4D50F154E17F1154100DC1B46E1833/'
    end
    if object.hasTag('White') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903253962/98CD23C0CCD545ABEC2F6BBE4E5D75722C35B03C/'
    end
    if object.hasTag('Yellow') then
      return 'http://cloud-3.steamusercontent.com/ugc/2283952543903241259/2A5CE8552B947AEB24EC568E41879C0C5098C7A8/'
    end
  end
  if object.hasTag('Building') then
    local data = object.getData()
    return data.AttachedDecals[1].CustomDecal.ImageURL
  end
end

---@param object tts__Object
---@return tts__Object
function ReplaceWithProxyTile(object)
  local asset = GetProxyTileAsset(object)
  if not asset then
    print('Asset not found for this object')
    return nil
  end
  local result = spawnObjectData({
    position = object.getPosition(),
    rotation = object.getRotation(),
    scale = object.getScale(),
    data = {
      GUID = object.getGUID(),
      Name = "Custom_Tile",
      Transform = {
        posX = -13.7190962,
        posY = 1.49607444,
        posZ = -15.487751,
        rotX = 0.01687256,
        rotY = 179.999924,
        rotZ = 0.0798879862,
        scaleX = 0.432334363,
        scaleY = 1.0,
        scaleZ = 0.432334363
      },
      Nickname = object.getName(),
      Description = object.getDescription(),
      GMNotes = object.getGMNotes(),
      ColorDiffuse = Color(1.0, 1.0, 1.0),
      LayoutGroupSortIndex = 0,
      Value = 0,
      Locked = false,
      Grid = true,
      Snap = true,
      IgnoreFoW = false,
      MeasureMovement = false,
      DragSelectable = true,
      Autoraise = true,
      Sticky = true,
      Tooltip = true,
      GridProjection = false,
      HideWhenFaceDown = false,
      Hands = false,
      Tags = object.getTags(),
      CustomImage = {
        ImageURL = asset,
        ImageSecondaryURL = asset,
        ImageScalar = 1.0,
        WidthScale = 0.0,
        CustomTile = {
          Type = 2,
          Thickness = 0.1,
          Stackable = false,
          Stretch = false
        }
      },
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = ""
    }
  })
  
  if not GridInfo.ContainedObjects[result.guid] then
    GridInfo.ContainedObjects[result.guid] = {}
  end
  GridInfo.ContainedObjects[result.guid].PrevData = object.getData()
  GridInfo.ContainedObjects[result.guid].PrevScale = object.getScale()
  destroyObject(object)

  return result
end

---@param zone tts__ScriptingTrigger
---@param object tts__Object
function Callback.OnObjectDroppedInSnapTile(player_color, snap_tile, object)
  if snap_tile.guid ~= owner.guid then
    return
  end
  local objectType = object.getData().Name
  --if objectType ~= 'Custom_Tile' and objectType ~= 'Custom_Token' then
  if objectType ~= 'Custom_Tile' then
    local proxyObject = ReplaceWithProxyTile(object)
    if proxyObject then
      object = proxyObject
      InvokeEvent('SimulateObjectDrop', player_color, object)
    end
  end

  -- save the previous scale
  local scale = Vector(object.getScale())
  if not GridInfo.ContainedObjects[object.guid] then
    GridInfo.ContainedObjects[object.guid] = {}
  end
  if GridInfo.ContainedObjects[object.guid].PrevScale == nil then
    GridInfo.ContainedObjects[object.guid].PrevScale = scale
  end
  
  UpdateItemScale(object)
  
  -- update grid size
  local numObjects = #shared.zone.getObjects()
  if numObjects > GridInfo.CurRowCount * GridInfo.CurColumnCount then
    Method.SetColumnCount(GridInfo.CurColumnCount + 1)
  end
end

function UpdateItemScale(object)
  if (not GridInfo.ContainedObjects[object.guid]) then
    -- don't update an item's scale if it hasn't been recorded yet
    return
  end
  local scale = Vector(object.getScale())
  local desiredSize = 0.45 * GridInfo.WorldSpaceGridSize;
  if object.getData().Name == 'Custom_Token' then
    desiredSize = desiredSize * 0.5 -- tokens should be scaled down twice as much as tiles
  end

  if scale.x > scale.z then
    scale = scale * (desiredSize / scale.x)
  else
    scale = scale * (desiredSize / scale.z)
  end
  object.setScale(scale)
end

function Callback.OnObjectDroppedOutsideSnapTile(player_color, snap_tile, object)
  if snap_tile.guid ~= owner.guid then
    return
  end
  local prevObject = GridInfo.ContainedObjects[object.guid]
  if prevObject.PrevData ~= nil then
    local renewedObject = spawnObjectData({
      position = object.getPosition(),
      rotation = object.getRotation(),
      scale = prevObject.PrevScale,
      data = prevObject.PrevData
    })
    destroyObject(object)
    InvokeEvent('SimulateObjectDrop', player_color, renewedObject)
  elseif prevObject.PrevScale then
    object.setScale(prevObject.PrevScale)
  end

  -- update grid size
  local numObjects = #shared.zone.getObjects()
  local shrinkColumnCount = GridInfo.CurColumnCount - 1
  local shrinkRowCount = GetRowCountForColumnCount(shrinkColumnCount)
  if shrinkColumnCount >= GridInfo.MinColumnCount and shrinkRowCount > GridInfo.MinRowCount then
    if numObjects <= shrinkColumnCount * shrinkRowCount then -- if objects fit in smaller grid, shrink it
      Method.SetColumnCount(shrinkColumnCount)
    end
  end
  
end

function UpdateGrid()
  local stretchedLocalGridWidth = owner.getScale().x / GridInfo.CurColumnCount
  local stretchedLocalGridDepth = owner.getScale().z / GridInfo.CurRowCount
  
  GridInfo.WorldSpaceGridSize = math.min(stretchedLocalGridWidth, stretchedLocalGridDepth)

  local newSnapPoints = {}
  for row = 0, GridInfo.CurRowCount - 1 do
    for column = GridInfo.CurColumnCount - 1, 0, -1 do
      local position = Vector(
        (((column + 0.5) / GridInfo.CurColumnCount) - 0.5) * (GridInfo.WorldSpaceGridSize / stretchedLocalGridWidth),
        1,
        (((row + 0.5) / GridInfo.CurRowCount) - 0.5) * (GridInfo.WorldSpaceGridSize / stretchedLocalGridDepth)
      )
      
      table.insert(newSnapPoints, {
        position = position,
        rotation = Vector(0,0,0),
        rotation_snap = true,
        tags = shared.snapTags, -- set in ./SnapTile.lua
      })
    end
  end
  owner.setSnapPoints(newSnapPoints)
  for _, object in ipairs(shared.zone.getObjects()) do
    UpdateItemScale(object)
  end
end

function GetRowCountForColumnCount(ColumnCount)
  return math.floor(ColumnCount * owner.getScale().z / owner.getScale().x)
end

function GetColumnCountForRowCount(RowCount)
  return math.floor(RowCount * owner.getScale().x / owner.getScale().z)
end

function Method.SetRowCount(count)
  if count == GridInfo.CurRowCount then
    return
  end
  GridInfo.CurRowCount = count
  GridInfo.CurColumnCount = GetColumnCountForRowCount(count)
  if GridInfo.CurColumnCount < GridInfo.MinColumnCount then
    Method.SetColumnCount(GridInfo.MinColumnCount)
  else
    UpdateGrid()
  end
end


function Method.SetColumnCount(count)
  if count == GridInfo.CurColumnCount then
    return
  end
  GridInfo.CurColumnCount = count
  GridInfo.CurRowCount = GetRowCountForColumnCount(count)
  if GridInfo.CurRowCount < GridInfo.MinRowCount then
    Method.SetRowCount(GridInfo.MinRowCount)
  else
    UpdateGrid()
  end
end

function Method.SetMinColumnCount(min)
  GridInfo.MinColumnCount = min
  if GridInfo.CurColumnCount < GridInfo.MinColumnCount then
    Method.SetColumnCount(GridInfo.MinColumnCount)
  end
end

function Method.SetMinRowCount(min)
  GridInfo.MinRowCount = min
  if GridInfo.CurRowCount < GridInfo.MinRowCount then
    Method.SetRowCount(GridInfo.MinRowCount)
  end
end

