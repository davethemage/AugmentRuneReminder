local addonName, AugmentRuneReminder = ...
local LSM = LibStub("LibSharedMedia-3.0")

function AugmentRuneReminder:CreateButton()
    local button = CreateFrame(
        "Button",
        "AugmentRuneReminder_Button",
        UIParent,
        "SecureActionButtonTemplate"
    )

    self.button = button

    local size = self.db.profile.buttonSize or 40
    button:SetSize(size, size)
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
    if self.db.profile.fontName then
        text:SetFont(LSM:Fetch("font", self.db.profile.fontName), self.db.profile.fontSize or 16, "OUTLINE")
    end
    text:SetPoint("TOP", button, "BOTTOM", 0, -6)
    text:SetText(self.db.profile.text or "Rune missing!")
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

    --Button glow
    if self.db.profile.buttonGlow or false then
        LibStub("LibButtonGlow-1.0").ShowOverlayGlow(self.button)
    else
        LibStub("LibButtonGlow-1.0").HideOverlayGlow(self.button)
    end

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
