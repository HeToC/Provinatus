ProvinatusUltimateHandler = {}

function ProvinatusUltimateHandler.HandleData(UnitTag, Data)
  -- TODO Sanitize input
  UltimateHUD:UpdateUnit(UnitTag, PROVINATUS_ULTIMATES_BY_NAME[Data[1]], Data[2])
end

function ProvinatusUltimateHandler.SendData()
  local abilityCost, mechanicType = GetSlotAbilityCost(8)
  local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_ULTIMATE)
  local data = {
    [1] = PROVINATUS_ULTIMATES_BY_NAME[GetSlotName(8)],
    [2] = math.min(zo_round(1.0 * current / abilityCost * 100), 100)
  }
  return ProvinatusSocket.LGS:Send(ProvinatusSocket.MessageType, data)
end