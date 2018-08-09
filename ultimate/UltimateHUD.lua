UltimateHUD = {}

function UltimateHUD:Initialize()
  -- Maps players to their ultimate data
  self.Players = {}
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

function UltimateHUD.OnUpdate()
  for UnitTag, UltimateData in UltimateHUD.Players do
    local Index = UltimateData.UltimateIndex
    local Percent = UltimateData.UltimatePercentage
    
  end
end