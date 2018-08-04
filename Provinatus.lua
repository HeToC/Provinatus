local Provinatus = {}

Provinatus.UpdateFunctions = {}

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
    table.insert(
      Provinatus.UpdateFunctions,
      function()
        CrownPointerThing.OnUpdate()
      end
    )
    -- Check if Provision's Team Formation enabled.
    -- If it is, disable HUD and inform player.
    if (ProvTF == nil) then
      ProvinatusHud:Initialize()
      table.insert(
        Provinatus.UpdateFunctions,
        function()
          ProvinatusHud:OnUpdate()
        end
      )

      if (YACS == nil) then
        ProvinatusCompass:Initialize()
        table.insert(
          Provinatus.UpdateFunctions,
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
    EVENT_MANAGER:RegisterForUpdate(CrownPointerThing.name .. "Update", 1000 / CrownPointerThing.SavedVars.HUD.RefreshRate, Provinatus.OnUpdate)
  end
end

-- TODO load addon more smarter so others can use it
EVENT_MANAGER:RegisterForEvent(CrownPointerThing.name, EVENT_ADD_ON_LOADED, Provinatus.EVENT_ADD_ON_LOADED)
