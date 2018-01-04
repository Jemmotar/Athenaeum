local _, core = ...; -- Namespace
local Module = core.Config.modules.morph;

--------------------------------------
-- Module
--------------------------------------

local UIMorph;

function Module:GetDescription()
  return "User interface for .morph command";
end

function Module:Enable()
  local overlay = UIMorph or Create();
  overlay:Show();
end

function Module:Disable()
  UIMorph:Hide();
end

--------------------------------------
-- Logic
--------------------------------------

function Create()
  local pointer = 0;

  UIMorph = CreateFrame("Frame", "AT_MORPH")
  UIMorph:SetPoint("LEFT", UIParent, "LEFT", 10, 250)
  UIMorph:SetSize(48, 128)

  local InputPointer = CreateFrame("EditBox", "AT_INPUT", UIMorph, "InputBoxTemplate")
  InputPointer:SetPoint("CENTER", UIMorph, "CENTER")
  InputPointer:SetWidth(48)
  InputPointer:SetHeight(24)
  InputPointer:SetNumeric(true)
  InputPointer:SetNumber(pointer)
  InputPointer:SetScript("OnEnterPressed", function(self)
    ExecMorph(InputPointer:GetNumber())
  end)

  local BtnPlus = CreateFrame("Button", "AT_BTN_PLUS", UIMorph, "UIPanelButtonTemplate")
  BtnPlus:SetPoint("CENTER", UIMorph, "CENTER", 0, 25)
  BtnPlus:SetWidth(32)
  BtnPlus:SetHeight(24)
  BtnPlus:SetText("+")
  BtnPlus:RegisterForClicks("LeftButtonUp, RightButtonUp")
  BtnPlus:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      pointer = pointer + 1
    else
      pointer = pointer + 10
    end
    ExecMorph(pointer)
  end)

  local BtnMinus = CreateFrame("Button", "ADD_BTN_MINUS", UIMorph, "UIPanelButtonTemplate")
  BtnMinus:SetPoint("CENTER", UIMorph, "CENTER", 0, -24)
  BtnMinus:SetWidth(32)
  BtnMinus:SetHeight(24)
  BtnMinus:SetText("-")
  BtnMinus:RegisterForClicks("LeftButtonUp, RightButtonUp")
  BtnMinus:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      if pointer > 0 then
        pointer = pointer - 1
      end
    else
      if pointer > 10 then
        pointer = pointer - 10
      else
        pointer = 0
      end
    end
    ExecMorph(pointer)
  end)

  function ExecMorph(id)
    if pointer ~= id then
      pointer = id
    end

    InputPointer:SetNumber(id)
    InputPointer:ClearFocus()
    SendChatMessage(".morph " .. id)
  end

	UIMorph:Hide()
  return UIMorph
end
