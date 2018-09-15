UltimateHUD = {}

function UltimateHUD:Initialize()
  -- Maps players to their ultimate data
  self.Players = {}
end

function UltimateHUD:UpdateUnit(UnitTag, UltimateIndex, UltimatePercentage)
  if self.Players[UnitTag] == nil then
    self.Players[UnitTag] = {}
    self.Players[UnitTag].Icon = WINDOW_MANAGER:CreateControl(CrownPointerThing.name, nil, CT_CONTROL)
  end

  self.Players[UnitTag].UltimateIndex = UltimateIndex
  self.Players[UnitTag].UltimatePercentage = UltimatePercentage
end

function UltimateHUD:UpdateHUD()
  for UltimateIndex, UnitPercentage in pairs(UltimateHUD.AvailableUltimates) do
    d(UltimateIndex)
    d(UnitPercentage)
    d("&&&&")
  end
end

function UltimateHUD.OnUpdate(debug)
  for UnitTag, UltimateData in pairs(UltimateHUD.Players) do
    local Index = UltimateData.UltimateIndex
    local Percent = UltimateData.UltimatePercentage
    if debug then
      d(UltimateData)
    end
    if UltimateHUD.AvailableUltimates[Index] == nil then
      UltimateHUD.AvailableUltimates[Index] = {}
    end

    UltimateHUD.AvailableUltimates[Index] = {UnitTag = Percent}
  end

  UltimateHUD:UpdateHUD()
end
