local FirstMarketSlotPos = Vector(36.89, 1.43, -4.76)
local MarketSlotPosDistance = Vector(36.89, 1.43, -2.04) - FirstMarketSlotPos

function getMarketSlotPosition(Index)
  return FirstMarketSlotPos + (MarketSlotPosDistance * (Index - 1))
end

function onLoad()
  MarketSlots = getObjectsWithTag("MarketSlot")
  if not MarketSlots or #MarketSlots == 0 then
    for Index = 1, 4 do
      SpawnMarketSlot(Index)
    end
  end
end

function Callback.OnPublish()
  print("destroying market tiles")
  for _, object in ipairs(getObjectsWithAnyTags({ 'MarketSlot', 'InfluenceRow' })) do
    destroyObject(object)
  end
end

function SpawnMarketSlot(Index)
  local marketSlot = spawnObjectData({
    position = getMarketSlotPosition(Index),
    data = {
      GUID = "d78d9a",
      Name = "BlockSquare",
      Transform = {
        posX = 36.8900146,
        posY = 1.43354714,
        posZ = -4.759996,
        rotX = 359.9208,
        rotY = 269.985016,
        rotZ = 0.008630602,
        scaleX = 2.35933733,
        scaleY = 0.01,
        scaleZ = 6.55704737
      },
      Nickname = "",
      Description = "",
      GMNotes = "",
      AltLookAngle = {
        ["x"] = 0.0,
        ["y"] = 0.0,
        ["z"] = 0.0
      },
      ColorDiffuse = {
        ["r"] = 0.0,
        ["g"] = 0.0,
        ["b"] = 0.0,
        ["a"] = 0.392156869
      },
      Tags = { "MarketSlot" },
      LayoutGroupSortIndex = 0,
      Value = 0,
      Locked = true,
      Grid = true,
      Snap = false,
      IgnoreFoW = false,
      MeasureMovement = false,
      DragSelectable = true,
      Autoraise = true,
      Sticky = true,
      Tooltip = true,
      GridProjection = false,
      HideWhenFaceDown = false,
      Hands = false,
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
      AttachedSnapPoints = {
        {
          Position = Vector(0.0010210803, 0.454844683, 0.263533324),
          Rotation = Vector(-0.00151778606, 0.0152794952, 359.9727),
          Tags = { }
        } }
    }
  })

  local colors = Player.getAvailableColors()
  for i, color in ipairs(colors) do
    local position = marketSlot.getPosition()               
    position.x = position.x + 40.59 - 39.08
    position.y = position.y + 0.01
    position.z = position.z + ((marketSlot.getScale().z / (2.25 * (#colors + 1))) * (i - 2.5))

    local row = SpawnInfluenceRow(position, color, marketSlot)
  end
  
  return marketSlot
end

local function OnSnapTileSpawn(snapTags, marketSlot)
  return function(snapTile)
    Wait.frames(function() 
      InvokeMethod("SetSnapTags", snapTile, snapTags)
      local zoneScale = marketSlot.getScale()
      zoneScale.y = 6
      local zonePosition = marketSlot.getPosition()
      zonePosition.y = zonePosition.y + (0.5 * zoneScale.y)
      
      InvokeMethod("OverrideZoneTransform", snapTile, zonePosition, zoneScale)
    end, 1)
  end
end

function SpawnInfluenceRow(position, color, marketSlot)
  local snapTags = { color .. "Agent" }

  local rgbColor = Color.fromString(color)
  rgbColor.a = 0.117647059

  local result = spawnObjectData({
    position = position,
    data = {
      GUID = "d16a18",
      Name = "BlockSquare",
      Transform = {
        posX = 40.59358,
        posY = 1.43729651,
        posZ = -9.163855,
        rotX = 0.0798812,
        rotY = -90.0,
        rotZ = 359.9809,
        scaleX = 0.2,
        scaleY = 0.0100000072,
        scaleZ = 3.068466
      },
      Nickname = "",
      Description = "",
      GMNotes = "",
      AltLookAngle = {
        ["x"] = 0.0,
        ["y"] = 0.0,
        ["z"] = 0.0
      },
      ColorDiffuse = rgbColor,
      Tags = { "SnapTile", "InfluenceRow" },
      LayoutGroupSortIndex = 0,
      Value = 0,
      Locked = true,
      Grid = false,
      Snap = false,
      IgnoreFoW = false,
      MeasureMovement = false,
      DragSelectable = true,
      Autoraise = true,
      Sticky = true,
      Tooltip = true,
      GridProjection = false,
      HideWhenFaceDown = false,
      Hands = false,
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
      AttachedSnapPoints = {
        {
          Position = Vector(0.0397550352, 0.4867813, 0.441748232),
          Rotation = Vector(-4.507693E-4, 179.978836, 8.117119E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0399634168, 0.4711872, 0.343157977),
          Rotation = Vector(-4.5189503E-4, 179.978455, 8.23629845E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.04010979, 0.506526947, 0.244577438),
          Rotation = Vector(-4.493741E-4, 179.979324, 8.19063454E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0403937176, 0.505714834, 0.1459896),
          Rotation = Vector(-4.494504E-4, 179.9793, 8.205477E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0406864733, 0.500717461, 0.04742291),
          Rotation = Vector(-4.4992147E-4, 179.979141, 8.09519435E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0407690629, 0.497884572, -0.0511674136),
          Rotation = Vector(-4.504594E-4, 179.978943, 8.33085855E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.04111286, 0.5025317, -0.149749056),
          Rotation = Vector(-4.5062913E-4, 179.978882, 8.14723258E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0412593521, 0.48488, -0.248335585),
          Rotation = Vector(-4.51394677E-4, 179.978622, 8.125467E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.04134963, 0.5100847, -0.346406341),
          Rotation = Vector(-4.53058E-4, 179.978043, 8.131461E-4),
          Tags = snapTags
        }, {
          Position = Vector(0.0407322757, 0.5119962, -0.444174975),
          Rotation = Vector(-4.485896E-4, 179.9796, 8.160341E-4),
          Tags = snapTags
        } }
    },
    callback_function = OnSnapTileSpawn(snapTags, marketSlot)
  })
  result.interactable = false
  
  return result
end