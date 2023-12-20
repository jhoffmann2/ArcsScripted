-- offset from player board
local ShipSupplyOffset = Vector(20.04, 1.45, -16.34) - Vector(27.35, 1.45, -15.18)
-- offset from player board
local AgentSupplyOffset = Vector(21.14, 1.45, -14.62) - Vector(27.35, 1.45, -15.18)

function onLoad()
  local PlayerShipTiles = getObjectsWithTag("PlayerShipSupply")
  if not PlayerShipTiles or #PlayerShipTiles == 0 then
    for _, board in ipairs(getObjectsWithTag('PlayerBoard')) do
      local PlayerShipSupply = SpawnPlayerShipSupply(board)
    end
  end

  local PlayerAgentTiles = getObjectsWithTag("PlayerAgentSupply")
  if not PlayerAgentTiles or #PlayerAgentTiles == 0 then
    for _, board in ipairs(getObjectsWithTag('PlayerBoard')) do
      local PlayerAgentSupply = SpawnPlayerAgentSupply(board)
    end
  end

  ---@param piece tts__Object
  for _, piece in ipairs(getObjectsWithAnyTags({ 'Agent', 'Ship' })) do
    piece.addContextMenuItem('Return to Supply', OnReturnPieceToSupply)
  end
end

---@param object tts__Object
function onObjectSpawn(object)
  if object.HasTag('Agent') or object.HasTag('Ship') then
    object.addContextMenuItem('Return to Supply', OnReturnPieceToSupply)
  end
end

---@param player_color tts__PlayerColor
---@param position tts__Vector
---@param piece tts__Object
function OnReturnPieceToSupply(player_color, position)
  for i, piece in ipairs(Player[player_color].getSelectedObjects()) do
    if piece.getStateId() ~= 1 and piece.hasTag('Ship') then
      piece = piece.setState(1) -- un-damage ships
    end
    Wait.frames(
      function()
        local supply = getObjectsWithAllTags({ "Player" .. piece.getName() .. "Supply", getPieceColor(piece) })
        if supply and supply[1] then
          InvokeMethod("MoveObjectToTile", supply[1], player_color, piece)
        end
      end, i - 1)
  end
end

function getPieceColor(piece)
  for _, color in ipairs(Player.getColors()) do
    if piece.hasTag(color) then
      return color
    end
  end
  return nil
end

local function OnSnapTileSpawn(snapTags)
  return function(snapTile) 
    Wait.frames(function() InvokeMethod("SetSnapTags", snapTile, snapTags) end, 1) 
  end
end


function Callback.OnPublish()
  print("destroying player supply tiles")
  for _, object in ipairs(getObjectsWithAnyTags({ 'PlayerShipSupply', 'PlayerAgentSupply' })) do
    destroyObject(object)
  end
end

---@param board tts__Object
---@return tts__Object
function SpawnPlayerShipSupply(board)
  local snapTags = { "Ship" }
  local result = spawnObjectData({
    position = board.getPosition() + ShipSupplyOffset,
    data = {
      GUID = "cfbefa",
      Name = "BlockSquare",
      Transform = { posX = 20.0449867, posY = 1.45282972, posZ = -16.34428,
                    rotX = 0.0, rotY = 0.0, rotZ = 0.0,
                    scaleX = 3.42264748, scaleY = 0.01, scaleZ = 1.5291481 },
      Nickname = "",
      Description = "",
      GMNotes = "",
      ColorDiffuse = Color(0.0, 0.0, 0.0, 0.392156869),
      Tags = { "PlayerShipSupply", getPieceColor(board), "SnapTile" },
      LayoutGroupSortIndex = 0,
      Value = 0,
      Locked = true,
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
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
      AttachedSnapPoints = {
        {
          Position = Vector(-0.298727274, 0.427601218, 0.3522923),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.298706383, 0.4769581, 0.174085334),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.298686266, 0.478284866, -0.004120367),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.298665076, 0.473878533, -0.18232356),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.2986467, 0.475478321, -0.360531747),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.0201828852, 0.510011733, 0.352469921),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.0202035271, 0.510170639, 0.174264207),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.0202225074, 0.5087906, -0.00393898739),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.0202415735, 0.493177027, -0.182144687),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.0202633645, 0.487877, -0.36035037),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.339090765, 0.5130986, 0.3526488),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.339112043, 0.499930322, 0.174444348),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.3391298, 0.51804024, -0.00375885027),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.339150459, 0.512214839, -0.181967035),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.3391711, 0.510967135, -0.360170215),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }
      }
    },
    callback_function = OnSnapTileSpawn(snapTags)
  })
  --Wait.frames(function() InvokeMethod("SetSnapTags", result, snapTags) end, 5)
  return result
end

---@param board tts__Object
---@return tts__Object
function SpawnPlayerAgentSupply(board)
  local snapTags = { "Agent" }
  local result = spawnObjectData({
    position = board.getPosition() + AgentSupplyOffset,
    data = {
      GUID = "cfbefa",
      Name = "BlockSquare",
      Transform = { posX = 21.1396084, posY = 1.45207882, posZ = -14.62194,
                    rotX = 0.0, rotY = 0.0, rotZ = 0.0,
                    scaleX = 1.22460175, scaleY = 0.009999929, scaleZ = 1.66302967 },
      Nickname = "",
      Description = "",
      GMNotes = "",
      ColorDiffuse = Color(0.0, 0.0, 0.0, 0.392156869),
      Tags = { "PlayerAgentSupply", getPieceColor(board), "SnapTile" },
      LayoutGroupSortIndex = 0,
      Value = 0,
      Locked = true,
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
      LuaScript = "",
      LuaScriptState = "",
      XmlUI = "",
      AttachedSnapPoints = {
        {
          Position = Vector(-0.210734665, 0.490173221, 0.37460348),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.241075024, 0.495698869, 0.3746286),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.210716724, 0.53364867, 0.192706719),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.241094053, 0.479295284, 0.192731753),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.210697383, 0.499673516, 0.0108110365),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.2411112, 0.479664, 0.0108361179),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.21067825, 0.477738559, -0.17108576),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.24112992, 0.480343133, -0.171060681),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(-0.210657954, 0.476749182, -0.352981418),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        }, {
          Position = Vector(0.241148636, 0.481642127, -0.3529563),
          Rotation = Vector(0, 180, 0),
          Tags = snapTags
        } }
    },
    callback_function = OnSnapTileSpawn(snapTags)
  })
  --Wait.frames(function() InvokeMethod("SetSnapTags", result, snapTags) end, 5)
  return result
end
