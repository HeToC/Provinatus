local Provinatus = {}

Provinatus.UpdateFunctions = {}

local function AddUpdateFunction(Function)
  table.insert(Provinatus.UpdateFunctions, Function)
end

function Provinatus.OnUpdate()
  for key, UpdateFunction in pairs(Provinatus.UpdateFunctions) do
    UpdateFunction()
  end
end

function Provinatus.EVENT_ADD_ON_LOADED(eventCode, addonName)
  if addonName == CrownPointerThing.name then
    CrownPointerThing:Initialize()
    ProvinatusMenu:Initialize()
    ProvinatusSocket:Initialize()
    UltimateHUD:Initialize()
    AddUpdateFunction(CrownPointerThing.OnUpdate)
    AddUpdateFunction(UltimateHUD.OnUpdate)
    -- Check if Provision's Team Formation enabled.
    -- If it is, disable HUD and inform player.
    if (ProvTF == nil) then
      ProvinatusHud:Initialize()
      AddUpdateFunction(
        function()
          ProvinatusHud:OnUpdate()
        end
      )

      if (YACS == nil) then
        ProvinatusCompass:Initialize()
        AddUpdateFunction(
          function()
            ProvinatusCompass:OnUpdate()
          end
        )
      else
        d(GetString(PROVINATUS_DETECTED_YAC))
      end
    else
      d(GetString(PROVINATUS_DISABLE))
    end

    local fragment = ZO_SimpleSceneFragment:New(CrownPointerThingIndicator)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    SIEGE_BAR_SCENE:AddFragment(fragment)

    EVENT_MANAGER:RegisterForUpdate(CrownPointerThing.name, 1000, ProvinatusUltimateHandler.SendData)
    EVENT_MANAGER:RegisterForUpdate(CrownPointerThing.name .. "Update", 1000 / CrownPointerThing.SavedVars.HUD.RefreshRate, Provinatus.OnUpdate)
  end
end

-- TODO load addon more smarter so others can use it
EVENT_MANAGER:RegisterForEvent(CrownPointerThing.name, EVENT_ADD_ON_LOADED, Provinatus.EVENT_ADD_ON_LOADED)
