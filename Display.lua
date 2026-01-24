local addonName, AugmentRuneReminder = ...

function AugmentRuneReminder:CreateButton()
    local button = CreateFrame("Button", "AugmentRuneReminder_Button", UIParent, "SecureActionButtonTemplate")
    button:SetSize(40, 40)
    button:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.posX, self.db.profile.posY)
    button:SetAttribute("type", "item")
    button:SetAttribute("item", "item:" .. self.ITEM_ID)
    self.button = button

    -- Icon
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(GetItemIcon(self.ITEM_ID))
    button.icon = icon

    -- Text
    local text = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("TOP", button, "BOTTOM", 0, -6)
    text:SetText("Rune missing!")
    if not self.db.profile.showText then text:Hide() end
    self.text = text

    button:HookScript("OnShow", function() if self.db.profile.showText then text:Show() end end)
    button:HookScript("OnHide", function() text:Hide() end)

    button:Hide()
    text:Hide()

    RegisterStateDriver(button, "visibility", "[combat][dead] hide;")

    button:SetScript("PostClick", function()
        if self:IsSafe() then
            button:Hide()
            text:Hide()
        end
    end)
end

function AugmentRuneReminder:UpdateReminder()
    if not self:IsSafe() then return end
    self:UpdateBuffState()

    local shouldShow = UnitExists("player") and not self.hasRuneBuff and self:ItemExists() and self:ItemReady()
    if shouldShow then
        self.button:Show()
    else
        self.button:Hide()
    end
end
