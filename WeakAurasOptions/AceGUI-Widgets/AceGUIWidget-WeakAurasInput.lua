if not WeakAuras.IsLibsOK() then return end

local Type, Version = "WeakAurasInput", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local OnEditFocusGained = function(frame)
  local self = frame.obj
  local option = self.userdata.option
  if option and option.OnEditFocusGained then
    option.OnEditFocusGained(self)
  end
end

local OnShow = function(frame)
  local self = frame.obj
  local option = self.userdata.option
  if option and option.SetWidget then
    option.SetWidget(self)
  end
end

local function Constructor()
	local widget = AceGUI:Create("EditBox")
	widget.type = Type
	widget.editbox:SetScript("OnEditFocusGained", OnEditFocusGained)
  widget.editbox:SetScript("OnShow", OnShow)
	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
