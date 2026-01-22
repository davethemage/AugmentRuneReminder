-- Addon namespace
AugmentRuneReminder = LibStub("AceAddon-3.0"):NewAddon("AugmentRuneReminder", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("AugmentRuneReminder", true)

-- Default config
local defaults = {
    profile = {
        showText = true,
        posX = 0,
        posY = 200,
    }
}

------------------------------------------------
-- Constants
------------------------------------------------
local BUFF_ID = 1234969
local ITEM_ID = 243191

------------------------------------------------
-- OnInitialize
------------------------------------------------
function AugmentRuneReminder:OnInitialize()
    -- Database setup
    self.db = LibStub("AceDB-3.0"):New("AugmentRuneReminderDB", defaults, true)

    -- Setup options panel
    self:SetupOptions()

    -- Create button
    self:CreateButton()

    -- Slash command
    self:RegisterChatCommand("arr", "OpenOptions")
end

------------------------------------------------
-- Create the secure button and text
------------------------------------------------
function AugmentRuneReminder:CreateButton()
    self.button = CreateFrame("Button", "AugmentRuneReminder_Button", UIParent, "SecureActionButtonTemplate")
    self.button:SetSize(40, 40)
    self.button:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.posX, self.db.profile.posY)
    self.button:SetAttribute("type", "item")
    self.button:SetAttribute("item", "item:"..ITEM_ID)

    -- Icon
    self.button.icon = self.button:CreateTexture(nil, "ARTWORK")
    self.button.icon:SetAllPoints()
    self.button.icon:SetTexture(GetItemIcon(ITEM_ID))

    -- Text
    self.text = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.text:SetPoint("TOP", self.button, "BOTTOM", 0, -6)
    self.text:SetText("Rune missing!")

    if not self.db.profile.showText then
        self.text:Hide()
    end

    -- Hook text visibility
    self.button:HookScript("OnShow", function() if self.db.profile.showText then self.text:Show() end end)
    self.button:HookScript("OnHide", function() self.text:Hide() end)

    -- Hide initially
    self.button:Hide()
    self.text:Hide()

    -- Combat-safe state driver
    RegisterStateDriver(self.button, "visibility", "[combat] hide;")

    -- PostClick
    self.button:SetScript("PostClick", function()
        if not InCombatLockdown() then
            self.button:Hide()
            self.text:Hide()
        end
    end)

    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "UpdateVisibility")
    self:RegisterEvent("UNIT_AURA", "UpdateVisibility")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "UpdateVisibility")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "UpdateVisibility")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellcastSucceeded")
end

------------------------------------------------
-- Track item usage for in-combat buff approximation
------------------------------------------------
function AugmentRuneReminder:OnSpellcastSucceeded(event, unit, _, spellID)
    if unit ~= "player" then return end
    if spellID == ITEM_ID then
        self:UpdateVisibility()
    end
end

------------------------------------------------
-- Utility Functions
------------------------------------------------
function AugmentRuneReminder:ItemExists()
    return GetItemCount(ITEM_ID, false) > 0
end

function AugmentRuneReminder:ItemReady()
    local start, duration = GetItemCooldown(ITEM_ID)
    return start == 0 or duration == 0
end

function AugmentRuneReminder:HasBuff()
    if InCombatLockdown() or UnitIsDeadOrGhost("player") then
        -- Do not call in combat
        return false
    end

    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if aura and aura.spellId == BUFF_ID and aura.sourceUnit == "player" then
            return true
        end
    end
    return false
end


------------------------------------------------
-- Update visibility (out of combat)
------------------------------------------------
function AugmentRuneReminder:UpdateVisibility()
    if InCombatLockdown() or UnitIsDeadOrGhost("player") then return end

    local shouldShow = UnitExists("player") and not self:HasBuff() and self:ItemExists() and self:ItemReady()
    local isShown = self.button:IsShown()

    if shouldShow and not isShown then
        self.button:Show()
    elseif not shouldShow and isShown then
        self.button:Hide()
    end
end


------------------------------------------------
-- Options Panel
------------------------------------------------
function AugmentRuneReminder:SetupOptions()
    local options = {
        name = "Augment Rune Reminder",
        handler = AugmentRuneReminder,
        type = 'group',
        args = {
            showText = {
                type = "toggle",
                name = "Show reminder text",
                desc = "Toggle the 'Rune missing!' text",
                get = function() return self.db.profile.showText end,
                set = function(_, value)
                    self.db.profile.showText = value
                    if value then
                        if self.button:IsShown() then self.text:Show() end
                    else
                        self.text:Hide()
                    end
                end,
            },
            posX = {
                type = "range",
                name = "Button X position",
                min = -1000,
                max = 1000,
                step = 1,
                get = function() return self.db.profile.posX end,
                set = function(_, value)
                    self.db.profile.posX = value
                    self.button:ClearAllPoints()
                    self.button:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.posX, self.db.profile.posY)
                end,
            },
            posY = {
                type = "range",
                name = "Button Y position",
                min = -1000,
                max = 1000,
                step = 1,
                get = function() return self.db.profile.posY end,
                set = function(_, value)
                    self.db.profile.posY = value
                    self.button:ClearAllPoints()
                    self.button:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.posX, self.db.profile.posY)
                end,
            },
        }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("AugmentRuneReminder", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AugmentRuneReminder", "AugmentRuneReminder")
end

function AugmentRuneReminder:OpenOptions(input)
    LibStub("AceConfigDialog-3.0"):Open("AugmentRuneReminder")
end

