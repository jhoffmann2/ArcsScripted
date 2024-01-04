
local cardOffset = Vector(35.16, 1.45, -4.76) - Vector(36.89, 1.43, -4.76)

function onLoad(save_string)
  local save_data = {}
  if save_string and save_string ~= '' then
    save_data = JSON.decode(save_string)
  end
  if save_data.rows then
    shared.rows = {}
    for color, guid in pairs(save_data.rows) do
      shared.rows[color] = getObjectFromGUID(guid)
    end
  end
  AddContextMenuToObject(owner)
  end

function onSave()
  local save_data = {}

  save_data.rows = {}
  for color, row in pairs(shared.rows) do
    save_data.rows[color] = row.guid
  end
  return JSON.encode(save_data)
end

function AddContextMenuToObject(object)
  if (object) then
    object.clearContextMenu()
    object.addContextMenuItem("Influence", OnInfluence)
    object.addContextMenuItem("Secure", OnSecure)
    object.addContextMenuItem("Ransack", OnRansack)
  end
end

function onScriptingButtonDown(index, player_color)
  local pointerPosition = Player[player_color].getPointerPosition()
  local rotatedScale = owner.getScale()
  rotatedScale:rotateOver("y", owner.getRotation().y)
  
  local minBounds = owner.getPosition() - 0.5 * rotatedScale
  local maxBounds = owner.getPosition() + 0.5 * rotatedScale
  if minBounds.x > maxBounds.x then
    local temp = minBounds.x
    minBounds.x = maxBounds.x
    maxBounds.x = temp
  end
  if minBounds.z > maxBounds.z then
    local temp = minBounds.z
    minBounds.z = maxBounds.z
    maxBounds.z = temp
  end
  if minBounds.x < pointerPosition.x and maxBounds.x > pointerPosition.x and minBounds.z < pointerPosition.z and maxBounds.z > pointerPosition.z then
    printToColor("Influencing "..tostring(index).." Times", player_color)
    for i = 1, index do
      OnInfluence(player_color, pointerPosition, i)
    end
  end
end

function IsCardInMarketSlot(card)
  local SlotPosition = owner.getPosition() + cardOffset
  local CardPosition = card.getPosition()
  return math.abs(SlotPosition.x - CardPosition.x) < 0.1 and math.abs(SlotPosition.z - CardPosition.z) < 0.1
end

function onObjectDrop(colorName, object)
  if object.type ~= 'Card' then
    return
  end
  Wait.frames(function ()
    if object.isDestroyed() then
      return
    end
    if IsCardInMarketSlot(object) then
      AddContextMenuToObject(object)
    end
  end, 1)
end

function OnInfluence(player_color, menu_position, i)
  if i == nil then
    i = 1
  end
  local agentSupply = getObjectsWithAllTags({ "PlayerAgentSupply", player_color })[1]
  local agentSupplyZone = Shared(agentSupply).zone
  local agents = agentSupplyZone.getObjects()
  if agents and #agents >= i then
    InvokeEvent("SimulateObjectPickup", player_color, agents[i])
    local destination = owner.getPosition() + Vector(-2, 0, 0)
    agents[i].setPosition(destination)
    InvokeEvent("SimulateObjectDrop", player_color, agents[i])
  else
    printToColor("You're out of agents", player_color)
  end
end

function CanSecure(player_color)
  local maxAgentCount = 0
  local maxAgentColor = nil
  for color, row in pairs(shared.rows) do
    local agentCount = #Shared(row).zone.getObjects()
    if agentCount > maxAgentCount then
      maxAgentCount = agentCount
      maxAgentColor = color
    elseif agentCount == maxAgentCount then
      maxAgentColor = nil -- don't allow ties
    end
  end
  return maxAgentColor == player_color
end

function OnSecure(player_color, menu_position)
  if not CanSecure(player_color) then
    printToColor("You cannot secure this card.", player_color)
    return
  end
  
  for color, row in pairs(shared.rows) do
    local supply
    if color == player_color then
      supply = getObjectsWithAllTags({ "PlayerAgentSupply", player_color }) -- send player pieces back to supply
    else
      supply = getObjectsWithAllTags({ "PlayerCaptiveTile", player_color }) -- send rival pieces to Captives
    end

    for i, piece in ipairs(Shared(row).zone.getObjects()) do
      InvokeMethod("MoveObjectToTile", supply[1], player_color, piece)
    end
  end
end

function OnRansack(player_color, menu_position)
  for color, row in pairs(shared.rows) do
    local supply
    if color == player_color then
      supply = getObjectsWithAllTags({ "PlayerAgentSupply", player_color }) -- send player pieces back to supply
    else
      supply = getObjectsWithAllTags({ "PlayerTrophyTile", player_color }) -- send rival pieces to Trophies
    end

    for i, piece in ipairs(Shared(row).zone.getObjects()) do
      InvokeMethod("MoveObjectToTile", supply[1], player_color, piece)
    end
  end
end
