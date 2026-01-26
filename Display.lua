local addonName, AugmentRuneReminder = ...

function AugmentRuneReminder:CreateButton()
    local button = CreateFrame(
        "Button",
        "AugmentRuneReminder_Button",
        UIParent,
        "SecureActionButtonTemplate"
    )

    self.button = button

    button:SetSize(40, 40)
    button:SetPoint("CENTER", UIParent, "CENTER",
        self.db.profile.posX,
        self.db.profile.posY
    )

    button:RegisterForClicks("AnyUp")

    -- Secure attributes
    button:SetAttribute("type", "item")
    button:SetAttribute("item", "item:" .. AugmentRuneReminder.ITEM_ID)
    -- Fallback: secure macro (more resilient)
    button:SetAttribute("macrotext", "/use item:" .. AugmentRuneReminder.ITEM_ID)
    -- Icon
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(GetItemIcon(AugmentRuneReminder.ITEM_ID))
    button.icon = icon

    -- Text
    local text = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("TOP", button, "BOTTOM", 0, -6)
    text:SetText("Rune missing!")
    self.text = text

    if not self.db.profile.showText then
        text:Hide()
    end

    button:HookScript("OnShow", function()
        if self.db.profile.showText then
            text:Show()
        end
    end)

    button:HookScript("OnHide", function()
        text:Hide()
    end)

    RegisterStateDriver(button, "visibility", "[combat][dead] hide;")

    button:SetScript("PostClick", function()
        if self:IsSafe() then
            button:Hide()
            text:Hide()
        end
    end)

    button:Hide()
    text:Hide()
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
