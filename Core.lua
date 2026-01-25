local addonName, Addon = ...
local shortName = "ARR"
local longName = "Augment Rune Reminder"
local version = "1.0.1"
local AugmentRuneReminder = LibStub("AceAddon-3.0"):NewAddon(
    Addon,
    addonName,
    "AceConsole-3.0",
    "AceEvent-3.0"
)
local L = LibStub("AceLocale-3.0"):GetLocale("AugmentRuneReminder", true)

-- Constants
AugmentRuneReminder.BUFF_ID = 1234969
AugmentRuneReminder.ITEM_ID = 243191
AugmentRuneReminder.DEBOUNCE_DELAY = 0.5

-- Defaults
AugmentRuneReminder.defaults = {
    profile = {
        showText = true,
        posX = 0,
        posY = 200,
    }
}

-- Helpers
function AugmentRuneReminder:IsSafe()
    return not InCombatLockdown() and not UnitIsDeadOrGhost("player")
end

-- Initialization
function AugmentRuneReminder:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AugmentRuneReminderDB", self.defaults, true)
    self.hasRuneBuff = false
    self.debouncePending = false

    -- Load other modules
    self:SetupOptions()
    self:CreateButton()

    self:RegisterChatCommand(shortName:lower(), "OpenOptions")

    self:RegisterEvent("PLAYER_LOGIN", "ScheduleUpdate")
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "ScheduleUpdate")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "ScheduleUpdate")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellcastSucceeded")
    -- print out status
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..shortName.."]|r ".. longName .." v".. version .. " - |cff00ff00/".. shortName:lower() .. "|r")
end

-- Debounced update
function AugmentRuneReminder:ScheduleUpdate()
    if self.debouncePending then return end
    self.debouncePending = true

    C_Timer.After(self.DEBOUNCE_DELAY, function()
        self.debouncePending = false
        if self:IsSafe() then self:UpdateReminder() end
    end)
end

-- Buff state
function AugmentRuneReminder:UpdateBuffState()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(self.BUFF_ID, "HELPFUL")
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
function AugmentRuneReminder:OnSpellcastSucceeded(_, unit, _, spellID)
    if unit == "player" and spellID == self.ITEM_ID then
        self:ScheduleUpdate()
    end
end

-- Unit aura handler
function AugmentRuneReminder:OnUnitAura(_, unit)
    if unit == "player" then self:ScheduleUpdate() end
end
