
local cardOffset = Vector(35.16, 1.45, -4.76) - Vector(36.89, 1.43, -4.76)

function onLoad()
  AddContextMenuToObject(owner)
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
      Wait.frames(
        function()
          OnInfluence(player_color, pointerPosition)
        end, i)
    end
  end
end

function IsCardInMarketSlot(card)
  local SlotPosition = owner.getPosition() + cardOffset
  local CardPosition = card.getPosition()
  return math.abs(SlotPosition.x - CardPosition.x) < 0.1 and math.abs(SlotPosition.z - CardPosition.z) < 0.1
end

function onObjectDrop(colorName, object)
  Wait.frames(function ()
    if object.type == 'Card' and IsCardInMarketSlot(object) then
      AddContextMenuToObject(object)
    end
  end, 1)
end

function CanSecure()
  return false
end

function CanRansack()
  return false
end

function OnInfluence(player_color, menu_position)
  local agentSupply = getObjectsWithAllTags({ "PlayerAgentSupply", player_color })[1]
  local agentSupplyZone = Shared(agentSupply).zone
  local agents = agentSupplyZone.getObjects()
  if agents and #agents > 0 then
    for _, agent in ipairs(agents) do
      if agent.getPositionSmooth() == nil then---@type tts__Object
        InvokeEvent("SimulateObjectPickup", player_color, agent)
        local destination = owner.getPosition() + Vector(-2, 0, 0)
        agent.setPositionSmooth(destination, false, true)
        Wait.condition(
          function()
            InvokeEvent("SimulateObjectDrop", player_color, agent)
          end,
          function()
            return agent.getPositionSmooth() == nil
          end
        )
        break
      end
    end
  else
    printToColor("You're out of agents", player_color)
  end
end

function OnSecure(player_color, menu_position)
  if not CanSecure() then
    printToColor("You cannot secure this card.", player_color)
  end
  
  
end

function OnRansack(player_color, menu_position)
  if not CanRansack() then
    printToColor("You cannot ransack this card.", player_color)
  end
end
