local hasAddedWarcraftLogsLink = false
local regionMap = {
    [1] = "us",
    [2] = "kr",
    [3] = "eu",
    [4] = "tw",
    [5] = "cn"
}

local frame = CreateFrame("Frame", "WarcraftLogsLinkFrame", PlayerFrame)
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        hasAddedWarcraftLogsLink = false
    end
end)

local linkFrame = CreateFrame("Frame", "LinkFrame", UIParent, "BasicFrameTemplateWithInset")
linkFrame.title = linkFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
linkFrame.title:SetPoint("CENTER", linkFrame.TitleBg, "CENTER", 5, 0)
linkFrame.title:SetText("Warcraftlogs Link")
linkFrame:SetSize(500, 80)
linkFrame:SetPoint("CENTER")
linkFrame:Hide()

table.insert(UISpecialFrames, "LinkFrame")

linkFrame:SetScript("OnHide", function()
    hasAddedWarcraftLogsLink = false
end)

local linkText = linkFrame:CreateFontString(nil, "OVERLAY")
linkText:SetFontObject("GameFontHighlight")
linkText:SetPoint("CENTER", linkFrame, "CENTER")
linkText:SetText("")

local linkEditBox = CreateFrame("EditBox", nil, linkFrame, "InputBoxTemplate")
linkEditBox:SetSize(450, 30)
linkEditBox:SetPoint("CENTER", linkFrame, "CENTER")
linkEditBox:SetAutoFocus(false)
linkEditBox:SetScript("OnEscapePressed", linkEditBox.ClearFocus)

local copiedText = linkFrame:CreateFontString(nil, "OVERLAY")
copiedText:SetFontObject("GameFontHighlight")
copiedText:SetPoint("TOP", linkEditBox, "BOTTOM", 0, 0)
copiedText:SetText("")
copiedText:Hide()

linkEditBox:SetScript("OnMouseDown", function()
    local link = linkEditBox:GetText()
    if link and link ~= "" then
        linkEditBox:HighlightText()
        copiedText:SetText("Press Ctrl+C to copy the link.")
        copiedText:Show()
        C_Timer.After(4, function()
            copiedText:Hide()
        end)
    end
end)

local function AddWarcraftLogsLink(self, unit)
    if UnitIsPlayer(unit) and not hasAddedWarcraftLogsLink then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Warcraftlogs Link"
        info.isNotRadio = true
        info.notCheckable = true
        info.func = function()
            if UnitIsPlayer("target") then
                local name, realm = UnitName("target")
                if not realm then
                    realm = GetRealmName()
                end
                local region = regionMap[GetCurrentRegion()]
                if region then
                    local link = "https://sod.warcraftlogs.com/character/" .. region .. "/" ..
                                     realm:lower():gsub(" ", "-") .. "/" .. name:lower()
                    linkEditBox:SetText(link)
                    linkFrame:Show()
                else
                    print("Could not determine region for " .. name)
                end
            end
        end

        UIDropDownMenu_AddButton(info)
        hasAddedWarcraftLogsLink = true
    end
end

hooksecurefunc("UnitPopup_ShowMenu", AddWarcraftLogsLink)
