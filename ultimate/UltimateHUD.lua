UltimateHUD = {}

function UltimateHUD:Initialize()
  -- Maps players to their ultimate data
  self.Players = {}
  self.HUD = {}
  self.HUD.Container = WINDOW_MANAGER:CreateControl(CrownPointerThing.name, nil, CT_CONTROL)
  self.AvailableUltimates = {}
end

function UltimateHUD:UpdateUnit(UnitTag, UltimateIndex, UltimatePercentage)
  if self.Players[UnitTag] == nil then
    self.Players[UnitTag] = {}
  end

  self.Players[UnitTag].UltimateIndex = UltimateIndex
  self.Players[UnitTag].UltimatePercentage = UltimatePercentage
end

-- Go through group members and remove any offliners
function UltimateHUD.Clean()
  for UnitTag, Data in UltimateHUD.Players do
    if not IsUnitGrouped(UnitTag) then
      UltimateHUD.Players[UnitTag] = nil
    end
  end
end

function UltimateHUD:UpdateHUD()
  for UltimateIndex, UnitPercentage in pairs(UltimateHUD.AvailableUltimates) do
    -- d(UltimateIndex)
    -- d(UnitPercentage)
    -- d("&&&&")
  end
end

function UltimateHUD.OnUpdate()
  for UnitTag, UltimateData in pairs(UltimateHUD.Players) do
    d(UltimateData)
    local Index = UltimateData.UltimateIndex
    local Percent = UltimateData.UltimatePercentage
    if UltimateHUD.AvailableUltimates[Index] == nil then
      UltimateHUD.AvailableUltimates = {}
      UltimateHUD.AvailableUltimates = {}
    end

    UltimateHUD.AvailableUltimates[Index] = {UnitTag = Percent}
  end

  UltimateHUD:UpdateHUD()
end
