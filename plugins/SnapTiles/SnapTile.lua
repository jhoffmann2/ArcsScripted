
local objectsInZone = {}
local wasObjectInZoneOnPickup = {}
local zoneHeight = 6

function onLoad(save_string)
  local save_data = {}
  if (save_string ~= "") then
    save_data = JSON.decode(save_string)
  end

  owner.clearContextMenu()
  owner.addContextMenuItem("Organize", Method.Organize)

  shared.zone = nil
  if save_data.zone then
    shared.zone = getObjectFromGUID(save_data.zone)
  else
    shared.zone = SpawnZone()
  end
  
  shared.snapTags = save_data.snapTags
  
  RefreshObjectsInZone()
end

function onSave()
  local save_data = {
    zone = shared.zone.guid,
    snapTags = shared.snapTags
  }
  return JSON.encode(save_data)
end

-- used by scripts to simulate a player picking up an object
function Callback.SimulateObjectPickup(player_color, object)
  onObjectPickUp(player_color, object)
end
-- used by scripts to simulate a player dropping an object
function Callback.SimulateObjectDrop(player_color, object)
  onObjectDrop(player_color, object)
end

function Method.MoveObjectToTile(player_color, object)
  InvokeEvent("SimulateObjectPickup", player_color, object)
  local destination = shared.zone.getPosition()
  object.setPositionSmooth(destination, false, true)
  Wait.condition(
    function()
      InvokeEvent("SimulateObjectDrop", player_color, object)
    end,
    function()
      return object.getPositionSmooth() == nil
    end
  )
end

function onObjectPickUp(player_color, object)
  wasObjectInZoneOnPickup[object.guid] = (objectsInZone[object.guid] == true)
end

function Callback.OnPublish()
  destroyObject(shared.zone)
  shared.zone = nil
end

function onObjectDrop(player_color, object)
  if object.guid == owner.guid then
    Method.UpdateZoneTransforms()
  end

  Wait.frames( -- wait a few frames so that snaps can take place
    function()
      if (wasObjectInZoneOnPickup[object.guid] or objectsInZone[object.guid]) then
        Method.Organize()
      end
      wasObjectInZoneOnPickup[object.guid] = nil
    end, 1)
end

function onObjectEnterZone(zone, object)
  if shared.zone and zone.guid == shared.zone.guid then
    objectsInZone[object.guid] = true
  end
end

function onObjectLeaveZone(zone, object)
  if shared.zone and zone.guid == shared.zone.guid then
    objectsInZone[object.guid] = nil
  end
end

function RefreshObjectsInZone()
  objectsInZone = {}
  for _, object in ipairs(shared.zone.getObjects()) do
    objectsInZone[object.guid] = true
  end
end

-- used ot ignore redundant calls to Method.Organize
local bOrganizedThisFrame = false

function Method.Organize()
  if bOrganizedThisFrame then
    return
  end
  
  local snapPoints = GetWorldSpaceSnapPoints()
  for i, object in ipairs(shared.zone.getObjects()) do
    if i > #snapPoints then
      printToAll("Too many objects on snap tile")
      break
    end
    if object.GetStateId() ~= 1 then
      object = object.setState(1)
    end
    object.setPosition(snapPoints[i].position)
    if snapPoints[i].rotation_snap then
      object.setRotation(snapPoints[i].rotation)
    end
    object.setVelocity(Vector(0,0,0))
    object.setAngularVelocity(Vector(0,0,0))
  end
  
  bOrganizedThisFrame = true
end

function onUpdate()
  bOrganizedThisFrame = false
end

-- move scripting zone on top of the market slot. this is called if the market slot is moved by the player
function Method.UpdateZoneTransforms()
  local position = owner.getPosition()
  position.y = position.y + (0.5 * shared.zone.getScale().y) + (0.6 * owner.getScale().y)
  shared.zone.setPosition(position)
  RefreshObjectsInZone()
end

function Method.SetSnapTags(snapTags)
  shared.snapTags = snapTags
  shared.zone.setTags(snapTags);
end
function Method.OverrideZoneTransform(zonePosition, zoneScale)
  shared.zone.setPosition(zonePosition)
  shared.zone.setScale(zoneScale)
end

function shallowCompare(t1, t2)
  if (t1 == nil) or (t2 == nil) then
    return (t1 == nil) and (t2 == nil)
  end
  
  if #t1 ~= #t2 then
    return false
  end
  for i, e1 in ipairs(t1) do
    if e1 ~= t2[i] then
      return false
    end
  end
  return true
end

---@return tts__Object_SnapPoint[]
function GetWorldSpaceSnapPoints()
  local result = {}
  ---@param snapPoint tts__Object_SnapPoint
  for _, snapPoint in ipairs(owner.getSnapPoints()) do
    if shallowCompare(snapPoint.tags, shared.snapTags) then
      rotation = snapPoint.rotation + owner.getRotation()

      position = snapPoint.position * owner.getScale()
      position = position:rotateOver('x', owner.getRotation().x)
      position = position:rotateOver('y', owner.getRotation().y)
      position = position:rotateOver('z', owner.getRotation().z)
      position = position + owner.getPosition()

      table.insert(result, {
        position = position,
        rotation = rotation,
        rotation_snap = snapPoint.rotation_snap,
        tags = snapPoint.tags
      })
    end
  end
  return result
end

function SpawnZone()
  local scale = owner.getScale()
  scale.y = zoneHeight
  local position = owner.getPosition()
  position.y = position.y + (0.5 * scale.y) + (0.6 * owner.getScale().y)

  local zone = spawnObjectData({
    position = position,
    rotation = owner.getRotation(),
    scale = scale,
    data = {
      GUID = "cfbefa",
      Name = "ScriptingTrigger",
      Transform = { posX = 0.0, posY = 0.0, posZ = 0.0,
                    rotX = 0.0, rotY = 0.0, rotZ = 0.0,
                    scaleX = 1.0, scaleY = 1.0, scaleZ = 1.0 },
      Nickname = "",
      Description = "",
      GMNotes = "",
      ColorDiffuse = Color(0.0, 0.0, 0.0, 0.392156869),
      LayoutGroupSortIndex = 0,
      Tags = shared.snapTags,
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
      XmlUI = ""
    }
  })
  
  return zone
end

