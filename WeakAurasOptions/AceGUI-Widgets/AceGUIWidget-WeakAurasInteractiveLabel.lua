if not WeakAuras.IsLibsOK() then return end

local Type, Version = "WeakAurasInteractiveLabel", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local AdjustHeight = function(self, padding)
  self.frame:SetHeight(self.label.frame:GetHeight() + padding)
end

local Control_OnEnter = function(self)
  self.obj:Fire("OnEnter")
end

local Control_OnClick = function(self, ...)
  self.obj:Fire("OnClick", ...)
end

local methods = {
  ["OnAcquire"] = function(self)

  end,
  ["SetText"] = function(self, text)
    self.label:SetText(text)
    AdjustHeight(self, 12)
  end,
  ["SetSize"] = function(self, width, height)
    self.frame:SetSize(width, height)
  end,
  ["SetScript"] = function(self, handler, callback)
    self.frame:SetScript(handler, callback)
  end
}

local function Constructor()
  local frame = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
  frame:SetSize(200, 40)
  frame:EnableMouse(true)
  frame:RegisterForClicks("AnyUp")
  frame:SetScript("OnEnter", Control_OnEnter)
  frame:SetScript("OnClick", Control_OnClick)

  local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetAllPoints(frame)
  highlight:SetAtlas("Options_List_Hover")
  highlight:SetBlendMode("ADD")

  local label = AceGUI:Create("Label")
  label.frame:SetParent(frame)
  label.frame:SetPoint("LEFT", frame, "LEFT", 0, 0)
  label.frame:Show()
  label:SetWidth(185)
  label:SetFontObject(GameFontNormalSmall2)

  local widget = {
    frame = frame,
    label = label,
    type = Type,
    highlight = highlight,
  }

  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
