-- Cooldown Assistant - Addon WoW

CooldownSavedData = CooldownSavedData or {}
CooldownSavedTimers = CooldownSavedTimers or {}

local currentProfile = nil
local combatStartTime = nil
local currentTimerBoss = nil

-- 🧠 Alerta por % de vida
function Cooldown_AddAlert()
  local boss = BossNameInput:GetText()
  local percent = tonumber(PercentInput:GetText())
  local message = MessageInput:GetText()
  if not boss or boss == "" or not percent or not message or message == "" then
    print("⚠️ Faltan datos.")
    return
  end
  CooldownSavedData[boss] = CooldownSavedData[boss] or {}
  table.insert(CooldownSavedData[boss], { percent = percent, message = message, triggered = false })
  print("✅ Alerta agregada para " .. boss .. ": " .. percent .. "% - " .. message)
  PercentInput:SetText("")
  MessageInput:SetText("")
  CooldownUI_ShowAlertsForBoss(boss)
end

-- ⏱️ Alerta por tiempo
function Cooldown_AddTimerAlert()
  local boss = BossNameInput:GetText()
  local seconds = tonumber(PercentInput:GetText())
  local message = MessageInput:GetText()
  if not boss or boss == "" or not seconds or not message or message == "" then
    print("⚠️ Faltan datos.")
    return
  end
  CooldownSavedTimers[boss] = CooldownSavedTimers[boss] or {}
  table.insert(CooldownSavedTimers[boss], { time = seconds, message = message, triggered = false })
  print("⏱️ Alerta por tiempo agregada para " .. boss .. ": " .. seconds .. "s - " .. message)
  PercentInput:SetText("")
  MessageInput:SetText("")
  CooldownUI_ShowAlertsForBoss(boss)
end

-- 📋 Mostrar alertas guardadas
function CooldownUI_ShowAlertsForBoss(boss)
  if CooldownUI.alertLabels then
    for _, entry in ipairs(CooldownUI.alertLabels) do
      entry.label:Hide()
      entry.button:Hide()
    end
  end
  CooldownUI.alertLabels = {}
  local row = 0
  local data = CooldownSavedData[boss]
  if data then
    for i, alert in ipairs(data) do
      local label = CooldownUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 20, -200 - (row * 20))
      label:SetText("🧠 " .. alert.percent .. "%: " .. alert.message)
      local button = CreateFrame("Button", nil, CooldownUI, "UIPanelCloseButton")
      button:SetSize(20, 20)
      button:SetPoint("LEFT", label, "RIGHT", 5, 0)
      button:SetScript("OnClick", function()
        table.remove(data, i)
        print("🗑️ Alerta eliminada.")
        CooldownUI_ShowAlertsForBoss(boss)
      end)
      table.insert(CooldownUI.alertLabels, { label = label, button = button })
      row = row + 1
    end
  end
  local timers = CooldownSavedTimers[boss]
  if timers then
    for i, alert in ipairs(timers) do
      local label = CooldownUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 20, -200 - (row * 20))
      label:SetText("⏱️ " .. alert.time .. "s: " .. alert.message)
      local button = CreateFrame("Button", nil, CooldownUI, "UIPanelCloseButton")
      button:SetSize(20, 20)
      button:SetPoint("LEFT", label, "RIGHT", 5, 0)
      button:SetScript("OnClick", function()
        table.remove(timers, i)
        print("🗑️ Alerta eliminada.")
        CooldownUI_ShowAlertsForBoss(boss)
      end)
      table.insert(CooldownUI.alertLabels, { label = label, button = button })
      row = row + 1
    end
  end
end

-- 🔁 Chequeo de % de vida
local frame = CreateFrame("Frame")
local lastGUID = nil
local lastPercent = nil
frame:SetScript("OnUpdate", function()
  if not UnitExists("target") or UnitIsDead("target") then return end
  local name = UnitName("target")
  if not CooldownSavedData[name] then return end
  local currentGUID = UnitGUID("target")
  if currentGUID ~= lastGUID then
    lastGUID = currentGUID
    lastPercent = nil
    for _, a in ipairs(CooldownSavedData[name]) do a.triggered = false end
  end
  local hp = UnitHealth("target")
  local max = UnitHealthMax("target")
  if max == 0 then return end
  local percent = (hp / max) * 100
  if lastPercent then
    for _, a in ipairs(CooldownSavedData[name]) do
      if not a.triggered and lastPercent > a.percent and percent <= a.percent then
        RaidNotice_AddMessage(RaidWarningFrame, a.message, ChatTypeInfo["RAID_WARNING"])
        PlaySound(8959)
        a.triggered = true
      end
    end
  end
  lastPercent = percent
end)

-- ⏱️ Alerta por tiempo
local timerFrame = CreateFrame("Frame")
timerFrame:SetScript("OnUpdate", function()
  if not UnitExists("target") or UnitIsDead("target") then combatStartTime = nil return end
  local bossName = UnitName("target")
  if not CooldownSavedTimers[bossName] then return end
  if not combatStartTime or currentTimerBoss ~= bossName then
    combatStartTime = GetTime()
    currentTimerBoss = bossName
    for _, alert in ipairs(CooldownSavedTimers[bossName]) do alert.triggered = false end
  end
  local elapsed = GetTime() - combatStartTime
  for _, alert in ipairs(CooldownSavedTimers[bossName]) do
    if not alert.triggered and elapsed >= alert.time then
      RaidNotice_AddMessage(RaidWarningFrame, alert.message, ChatTypeInfo["RAID_WARNING"])
      PlaySound(8959)
      alert.triggered = true
    end
  end
end)

-- 🧾 Interfaz SlashCommand
SLASH_COOLDOWN1 = "/cooldown"
SlashCmdList["COOLDOWN"] = function()
  if CooldownUI and CooldownUI:IsShown() then
    CooldownUI:Hide()
  elseif CooldownUI then
    if not CooldownUI.backdropSet then
      CooldownUI:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
      })
      CooldownUI.backdropSet = true
    end

-- 🏷️ Crear etiquetas si aún no existen
if not CooldownUI.labelBoss then
  -- Etiqueta: Título para el campo de nombre del boss
  local labelBoss = CooldownUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  labelBoss:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 20, -15)  -- Posición superior izquierda del frame
  labelBoss:SetText("Nombre del Boss:")
  CooldownUI.labelBoss = labelBoss

  -- Etiqueta: Título para el campo de porcentaje o tiempo
  local labelPercent = CooldownUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  labelPercent:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 20, -55)  -- Un poco más arriba para que no se tape con el input
  labelPercent:SetText("% de vida o Tiempo:")
  CooldownUI.labelPercent = labelPercent

  -- Etiqueta: Título para el mensaje que se mostrará cuando se active la alerta
  local labelMessage = CooldownUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  labelMessage:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 150, -55)  -- A la derecha de labelPercent
  labelMessage:SetText("Mensaje:")
  CooldownUI.labelMessage = labelMessage
end

-- 🔘 Botón para agregar una alerta basada en % de vida
if not MyAddAlertButton then
  local button = CreateFrame("Button", "MyAddAlertButton", CooldownUI, "UIPanelButtonTemplate")
  button:SetSize(140, 25)  -- Ancho x Alto
  button:SetPoint("TOPLEFT", CooldownUI, "TOPLEFT", 20, -110)  -- Ubicación dentro del frame
  button:SetText("Agregar Alerta %")
  button:SetScript("OnClick", function()
    Cooldown_AddAlert()
  end)
end

-- 🔘 Botón para agregar una alerta basada en tiempo (desde inicio de combate)
if not MyAddTimerButton then
  local button = CreateFrame("Button", "MyAddTimerButton", CooldownUI, "UIPanelButtonTemplate")
  button:SetSize(160, 25)
  button:SetPoint("TOPLEFT", MyAddAlertButton, "BOTTOMLEFT", 0, -10)  -- Justo debajo del botón anterior
  button:SetText("Agregar por Tiempo")
  button:SetScript("OnClick", function()
    Cooldown_AddTimerAlert()
  end)
end

-- 👁️ Mostrar la interfaz
    CooldownUI:Show()

    -- 👁️ Mostrar alertas guardadas del boss actual al abrir la UI
      local boss = BossNameInput:GetText()
    if boss and boss ~= "" then
      CooldownUI_ShowAlertsForBoss(boss)
    else
      -- Buscar primer boss con datos
      for name, _ in pairs(CooldownSavedData) do
        BossNameInput:SetText(name)
        CooldownUI_ShowAlertsForBoss(name)
        break
      end
    end

  else
    print("Cooldown Assistant: UI no cargada.")
  end
end
