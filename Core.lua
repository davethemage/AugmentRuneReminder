local addonName, AugmentRuneReminder = ...
local shortName = "ARR"
local longName = "Augment Rune Reminder"
local version = "1.0.4"

AugmentRuneReminder.addon = LibStub("AceAddon-3.0"):NewAddon(
    addonName,
    "AceConsole-3.0",
    "AceEvent-3.0"
)

local addon = AugmentRuneReminder.addon
local L = LibStub("AceLocale-3.0"):GetLocale("AugmentRuneReminder", true)

-- Constants
AugmentRuneReminder.BUFF_ID = 1234969
AugmentRuneReminder.ITEM_ID = 243191
local DEBOUNCE_DELAY = 0.5

-- Defaults
AugmentRuneReminder.defaults = {
    profile = {
        showText = true,
        posX = 0,
        posY = 200,
        buttonGlow = false,
        text = "Rune missing!",
        fontName = "Friz Quadrata TT",
        fontSize = 16,
        buttonSize = 40,
    }
}

-- Helpers
function AugmentRuneReminder:IsSafe()
    return not InCombatLockdown() and not UnitIsDeadOrGhost("player")
end

-- Initialization
function addon:OnInitialize()
    AugmentRuneReminder.db = LibStub("AceDB-3.0"):New("AugmentRuneReminderDB", AugmentRuneReminder.defaults, true)
    AugmentRuneReminder.hasRuneBuff = false
    addon.debouncePending = false

    -- Load other modules
    AugmentRuneReminder:SetupOptions()

    addon:RegisterChatCommand(shortName:lower(), "OpenOptions")

    addon:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    addon:RegisterEvent("UNIT_AURA", "OnUnitAura")
    addon:RegisterEvent("BAG_UPDATE_DELAYED", "ScheduleUpdate")
    addon:RegisterEvent("SPELL_UPDATE_COOLDOWN", "ScheduleUpdate")
    addon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellcastSucceeded")
    -- print out status
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..shortName.."]|r ".. longName .." v".. version .. " - |cff00ff00/".. shortName:lower() .. "|r")
end

-- On login
function addon:OnPlayerLogin()
    AugmentRuneReminder:CreateButton()
    addon:ScheduleUpdate()
end

-- Debounced update
function addon:ScheduleUpdate()
    if addon.debouncePending then return end
    addon.debouncePending = true

    C_Timer.After(DEBOUNCE_DELAY, function()
        addon.debouncePending = false
        if AugmentRuneReminder:IsSafe() then AugmentRuneReminder:UpdateReminder() end
    end)
end

-- Buff state
function AugmentRuneReminder:UpdateBuffState()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(AugmentRuneReminder.BUFF_ID, "HELPFUL")
    self.hasRuneBuff = aura and aura.sourceUnit == "player" or false
end

-- Item helpers
function AugmentRuneReminder:ItemExists()
    return GetItemCount(self.ITEM_ID, false) > 0
end

function AugmentRuneReminder:ItemReady()
    return GetItemCooldown(self.ITEM_ID) == 0
end

-- Spellcast fallback
function addon:OnSpellcastSucceeded(_, unit, _, spellID)
    if unit == "player" and spellID == AugmentRuneReminder.ITEM_ID then
        self:ScheduleUpdate()
    end
end

-- Unit aura handler
function addon:OnUnitAura(_, unit)
    if unit == "player" then self:ScheduleUpdate() end
end
function addon:OpenOptions()
    LibStub("AceConfigDialog-3.0"):Open("AugmentRuneReminder")
end
