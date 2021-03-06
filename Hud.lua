ProvinatusHud = {}

local ClassMapping = {
  [1] = "Dragonknight",
  [2] = "Sorcerer",
  [3] = "Nightblade",
  [4] = "Warden",
  [6] = "Templar"
}

local function GetIconDimensions(UnitTag)
  if IsUnitGroupLeader(UnitTag) or GetUnitName(UnitTag) == CrownPointerThing.CustomTarget then
    return CrownPointerThing.SavedVars.HUD.TargetIconSize, CrownPointerThing.SavedVars.HUD.TargetIconSize
  else
    return CrownPointerThing.SavedVars.HUD.PlayerIconSize, CrownPointerThing.SavedVars.HUD.PlayerIconSize
  end
end

local function UnitHasBeenTendedTo(UnitTag)
  return IsUnitReincarnating(UnitTag) or IsUnitBeingResurrected(UnitTag) or DoesUnitHaveResurrectPending(UnitTag)
end

local function GetIconColor(UnitTag)
  local R, G, B = 1, 1, 1
  if not IsUnitDead(UnitTag) then
    local health, maxHealth, effectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
    local ratio = health / maxHealth
    G = ratio
    B = ratio
  elseif not DoesUnitHaveResurrectPending(UnitTag) then
    G = 0
    B = 0
  end
  return R, G, B
end

local function GetIconTexture(UnitTag)
  local Texture
  if IsUnitDead(UnitTag) then
    if UnitHasBeenTendedTo(UnitTag) then
      Texture = CrownPointerThing.SavedVars.PlayerIcons.ResurrectionPending
    else
      Texture = CrownPointerThing.SavedVars.PlayerIcons.Dead
    end
  else
    if IsUnitGroupLeader(UnitTag) then
      Texture = CrownPointerThing.SavedVars.PlayerIcons.Crown.Alive
    elseif CrownPointerThing.SavedVars.HUD.ShowRoleIcons then
      local IsDps, IsHealer, IsTank = GetGroupMemberRoles(UnitTag)
      local Role = "dps"
      if IsTank then
        Role = "tank"
      elseif IsHealer then
        Role = "healer"
      end
      Texture = "/esoui/art/lfg/lfg_" .. Role .. "_up.dds"
    else
      local Class = ClassMapping[GetUnitClassId(UnitTag)]
      if Class == nil then
        Texture = "/esoui/art/icons/mapkey/mapkey_groupmember.dds"
      else
        Texture = "esoui/art/contacts/social_classicon_" .. Class .. ".dds"
      end
    end
  end
  return Texture
end

local function GetLifeBarDimensions(UnitTag, IconX, IconY)
  local health, maxHealth, effectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
  local ratio = health / maxHealth
  -- TODO increase height based on IconY
  return IconX / 2 * ratio, 2
end

local function GetIconAlpha(UnitTag)
  local Alpha
  if not IsUnitGrouped(UnitTag) or not IsUnitOnline(UnitTag) or GetUnitZoneIndex("player") ~= GetUnitZoneIndex(UnitTag) then
    Alpha = 0
  elseif IsUnitGroupLeader(UnitTag) or GetUnitName(UnitTag) == CrownPointerThing.CustomTarget then
    Alpha = CrownPointerThing.SavedVars.HUD.TargetIconAlpha
  else
    Alpha = CrownPointerThing.SavedVars.HUD.PlayerIconAlpha
  end
  return Alpha
end

local function GetLifeBarAlpha(UnitTag, SuggestedAlpha)
  local Alpha = SuggestedAlpha or GetIconAlpha(UnitTag)
  if not IsUnitInCombat(UnitTag) then
    Alpha = 0
  end
  return Alpha
end

local function GetDrawLevel(UnitTag)
  if IsUnitGroupLeader(UnitTag) or GetUnitName(UnitTag) == CrownPointerThing.CustomTarget then
    return CrownPointerThing.SavedVars.HUD.TargetIconDrawLevel
  else
    return CrownPointerThing.SavedVars.HUD.PlayerIconDrawLevel
  end
end

local function GetProjectedCoordinates(X1, Y1, X2, Y2, CameraHeading)
  -- Horizontal distance to target
  local DistanceX = X1 - X2
  -- Vertical distance to target
  local DistanceY = Y1 - Y2
  -- Angle to target.
  local Phi = -1 * CameraHeading - math.atan2(DistanceY, DistanceX)
  -- The closer the target the more exaggerated the movement becomes. See 3d chart here https://www.wolframalpha.com/input/?i=arctan(sqrt(add(x%5E2,+y%5E2)))
  local DistanceProjected = math.atan(math.sqrt((DistanceX * DistanceX) + (DistanceY * DistanceY)) * 250) * (CrownPointerThing.SavedVars.HUD.Size / 2)
  -- Calculates where to draw on the screen.
  local XProjected = -DistanceProjected * math.cos(Phi) + CrownPointerThing.SavedVars.HUD.PositionX
  local YProjected = DistanceProjected * math.sin(Phi) + CrownPointerThing.SavedVars.HUD.PositionY
  if CrownPointerThing.SavedVars.HUD.Offset then
    YProjected = YProjected + CrownPointerThing.SavedVars.CrownPointer.Size / 2
  end

  return XProjected, YProjected
end

local function GetQuestPins()
  local pins = ZO_WorldMap_GetPinManager():GetActiveObjects()
  local questPins = {}
  for pinKey, pin in pairs(pins) do
    local curIndex = pin:GetQuestIndex()
    if curIndex == QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex() then
      table.insert(questPins, pin)
    end
  end

  return questPins
end

-- Copied from esoui source code compass.lua
local function IsPlayerInsideJournalQuestConditionGoalArea(journalIndex, stepIndex, conditionIndex)
  journalIndex = journalIndex - 1
  stepIndex = stepIndex - 1
  conditionIndex = conditionIndex - 1
  return IsPlayerInsidePinArea(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, journalIndex, stepIndex, conditionIndex) or
    IsPlayerInsidePinArea(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, journalIndex, stepIndex, conditionIndex)
end

local function IsPlayerInAreaPin()
  local _, visibility, stepType, stepOverrideText, conditionCount = GetJournalQuestStepInfo(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex(), QUEST_MAIN_STEP_INDEX)
  local Result = false
  for ConditionIndex = 1, conditionCount do
    if IsPlayerInsideJournalQuestConditionGoalArea(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex(), QUEST_MAIN_STEP_INDEX, ConditionIndex) then
      Result = true
      break
    end
  end

  return Result
end

function ProvinatusHud:Initialize()
  self.Players = {}
end

function ProvinatusHud:DrawWaypoint(MyX, MyY, CameraHeading)
  local WaypointX, WaypointY = GetMapPlayerWaypoint()
  if (WaypointX ~= 0 or WaypointY ~= 0) and CrownPointerThing.SavedVars.HUD.ShowMapPlayerWaypoint then
    local XProjected, YProjected = GetProjectedCoordinates(MyX, MyY, WaypointX, WaypointY, CameraHeading)
    if self.Waypoint == nil then
      self.Waypoint = {}
      self.Waypoint.Icon = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
      self.Waypoint.Icon:SetTexture("esoui/art/compass/compass_waypoint.dds")
      self.Waypoint.Icon:SetDrawLevel(1)
    end

    self.Waypoint.Icon:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, XProjected, YProjected)
    self.Waypoint.Icon:SetAlpha(CrownPointerThing.SavedVars.HUD.PlayerWaypointIconAlpha)
    self.Waypoint.Icon:SetDimensions(CrownPointerThing.SavedVars.HUD.PlayerWaypointIconSize, CrownPointerThing.SavedVars.HUD.PlayerWaypointIconSize)
  elseif self.Waypoint ~= nil and self.Waypoint.Icon ~= nil and self.Waypoint.Icon:GetAlpha() ~= 0 then
    self.Waypoint.Icon:SetAlpha(0)
  end
end

function ProvinatusHud:DrawRallyPoint(MyX, MyY, CameraHeading)
  local RallyX, RallyY = GetMapRallyPoint()
  if (RallyX ~= 0 or RallyY ~= 0) and CrownPointerThing.SavedVars.HUD.ShowMapRallyPoint then
    local XProjected, YProjected = GetProjectedCoordinates(MyX, MyY, RallyX, RallyY, CameraHeading)
    if self.RallyPoint == nil then
      self.RallyPoint = {}
      self.RallyPoint.Icon = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
      self.RallyPoint.Icon:SetTexture("esoui/art/mappins/maprallypoint.dds")
      local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, self.RallyPoint.Icon)
      animation:SetImageData(32, 1)
      animation:SetFramerate(CrownPointerThing.SavedVars.HUD.RefreshRate)
      timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
      timeline:PlayFromStart()
    end

    self.RallyPoint.Icon:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, XProjected, YProjected)
    self.RallyPoint.Icon:SetAlpha(CrownPointerThing.SavedVars.HUD.RallyPointIconAlpha)
    self.RallyPoint.Icon:SetDimensions(CrownPointerThing.SavedVars.HUD.RallyPointIconSize, CrownPointerThing.SavedVars.HUD.RallyPointIconSize)
  elseif self.RallyPoint ~= nil and self.RallyPoint.Icon ~= nil and self.RallyPoint.Icon:GetAlpha() ~= 0 then
    self.RallyPoint.Icon:SetAlpha(0)
  end
end

function ProvinatusHud:DrawQuestMarker(MyX, MyY, CameraHeading)
  if CrownPointerThing.SavedVars.HUD.ShowQuestMarker then
    if self.QuestMarkers == nil then
      self.QuestMarkers = {}
    end

    -- TODO cache this and use events to get quest pins
    local QuestPins = GetQuestPins()
    for i = 1, #QuestPins do
      if self.QuestMarkers[i] == nil then
        self.QuestMarkers[i] = {}
        self.QuestMarkers[i].Icon = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
        self.QuestMarkers[i].Icon:SetDrawLevel(0)
      end

      if QuestPins[i] then
        local QuestTexture = QuestPins[i]:GetQuestIcon()
        local ProjectedX, ProjectedY = GetProjectedCoordinates(MyX, MyY, QuestPins[i].normalizedX, QuestPins[i].normalizedY, CameraHeading)
        self.QuestMarkers[i].Icon:SetDimensions(CrownPointerThing.SavedVars.HUD.QuestMarkerIconSize, CrownPointerThing.SavedVars.HUD.QuestMarkerIconSize)
        self.QuestMarkers[i].Icon:SetTexture(QuestTexture)
        self.QuestMarkers[i].Icon:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, ProjectedX, ProjectedY)
        self.QuestMarkers[i].Icon:SetAlpha(CrownPointerThing.SavedVars.HUD.QuestMarkerIconAlpha)

        if QuestPins[i]:IsAreaPin() then
          if self.QuestMarkers[i].AreaIcon == nil then
            self.QuestMarkers[i].AreaIcon = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
          end

          self.QuestMarkers[i].AreaIcon:SetDimensions(CrownPointerThing.SavedVars.HUD.QuestMarkerIconSize, CrownPointerThing.SavedVars.HUD.QuestMarkerIconSize)
          if IsPlayerInAreaPin() then
            self.QuestMarkers[i].AreaIcon:SetTexture("esoui/art/mappins/map_assistedareapin.dds")
          else
            self.QuestMarkers[i].AreaIcon:SetTexture("esoui/art/mappins/map_areapin.dds")
          end
          self.QuestMarkers[i].AreaIcon:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, ProjectedX, ProjectedY)
          self.QuestMarkers[i].AreaIcon:SetAlpha(CrownPointerThing.SavedVars.HUD.QuestMarkerIconAlpha)
        elseif self.QuestMarkers[i].AreaIcon then
          self.QuestMarkers[i].AreaIcon:SetAlpha(0)
        end
      else
        self.QuestMarkers[i]:SetAlpha(0)
        if self.QuestMarkers[i].AreaIcon then
          self.QuestMarkers[i].AreaIcon:SetAlpha(0)
        end
      end
    end

    for i = #QuestPins + 1, #self.QuestMarkers do
      self.QuestMarkers[i].Icon:SetAlpha(0)
      if self.QuestMarkers[i].AreaIcon then
        self.QuestMarkers[i].AreaIcon:SetAlpha(0)
      end
    end
  elseif self.QuestMarkers then
    for i = 1, #self.QuestMarkers do
      if self.QuestMarkers[i] ~= nil and self.QuestMarkers[i]:GetAlpha() ~= 0 then
        self.QuestMarkers[i]:SetAlpha(0)
      end
    end
  end
end

function ProvinatusHud:DrawUnit(MyX, MyY, CameraHeading, UnitIndex)
  local UnitTag = "group" .. UnitIndex

  -- If unit not in group, unit is me, or unit in a different zone than me...  hide icon
  if GetUnitName(UnitTag) ~= GetUnitName("player") then
    if self.Players[UnitIndex] == nil then
      self.Players[UnitIndex] = {}
      self.Players[UnitIndex].Icon = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
      self.Players[UnitIndex].LifeBar = WINDOW_MANAGER:CreateControl(nil, CrownPointerThingIndicator, CT_TEXTURE)
      self.Players[UnitIndex].LifeBar:SetColor(1, 0, 0)
    end
    local X, Y, Heading = GetMapPlayerPosition(UnitTag)
    local XProjected, YProjected = GetProjectedCoordinates(MyX, MyY, X, Y, CameraHeading)
    -- Get icon dimensions
    local IconX, IconY = GetIconDimensions(UnitTag)
    local IconAlpha = GetIconAlpha(UnitTag)

    -- Get icon draw level
    local DrawLevel = GetDrawLevel(UnitTag)

    -- Need to flip the x axis.
    self.Players[UnitIndex].Icon:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, XProjected, YProjected)
    self.Players[UnitIndex].Icon:SetTexture(GetIconTexture(UnitTag))
    self.Players[UnitIndex].Icon:SetDimensions(IconX, IconY)
    self.Players[UnitIndex].Icon:SetColor(GetIconColor(UnitTag))
    self.Players[UnitIndex].Icon:SetAlpha(IconAlpha)
    self.Players[UnitIndex].Icon:SetDrawLevel(DrawLevel)

    self.Players[UnitIndex].LifeBar:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, XProjected, YProjected + self.Players[UnitIndex].Icon:GetWidth() / 2)
    self.Players[UnitIndex].LifeBar:SetDimensions(GetLifeBarDimensions(UnitTag, IconX, IconY))
    self.Players[UnitIndex].LifeBar:SetAlpha(GetLifeBarAlpha(UnitTag, IconAlpha))
    self.Players[UnitIndex].LifeBar:SetDrawLevel(DrawLevel)
  end
end

function ProvinatusHud:OnUpdate()
  if not CrownPointerThing or not CrownPointerThing.SavedVars then
    return
  end

  local MyX, MyY, MyHeading = GetMapPlayerPosition("player")
  local CameraHeading = GetPlayerCameraHeading()
  self:DrawWaypoint(MyX, MyY, CameraHeading)
  self:DrawRallyPoint(MyX, MyY, CameraHeading)
  self:DrawQuestMarker(MyX, MyY, CameraHeading)
  for i = 1, GetGroupSize() do
    ProvinatusHud:DrawUnit(MyX, MyY, CameraHeading, i)
  end

  for i = GetGroupSize() + 1, #self.Players do
    if self.Players[i] ~= nil and self.Players[i].Icon ~= nil and self.Players[i].Icon:GetAlpha() ~= 0 then
      self.Players[i].Icon:SetAlpha(0)
      self.Players[i].LifeBar:SetAlpha(0)
    end
  end
end
