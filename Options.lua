local addonName, AugmentRuneReminder = ...

function AugmentRuneReminder:SetupOptions()
    local options = {
        name = "Augment Rune Reminder",
        type = "group",
        args = {
            showText = {
                type = "toggle",
                name = "Show reminder text",
                get = function() return self.db.profile.showText end,
                set = function(_, value)
                    self.db.profile.showText = value
                    if self.button:IsShown() and value then
                        self.text:Show()
                    else
                        self.text:Hide()
                    end
                end,
            },
            posX = {
                type = "range",
                name = "Button X position",
                min = -1000, max = 1000, step = 1,
                get = function() return self.db.profile.posX end,
                set = function(_, value)
                    self.db.profile.posX = value
                    self.button:ClearAllPoints()
                    self.button:SetPoint("CENTER", UIParent, "CENTER", value, self.db.profile.posY)
                end,
            },
            posY = {
                type = "range",
                name = "Button Y position",
                min = -1000, max = 1000, step = 1,
                get = function() return self.db.profile.posY end,
                set = function(_, value)
                    self.db.profile.posY = value
                    self.button:ClearAllPoints()
                    self.button:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.posX, value)
                end,
            },
        }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("AugmentRuneReminder", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AugmentRuneReminder", "Augment Rune Reminder")
end

function AugmentRuneReminder:OpenOptions()
    LibStub("AceConfigDialog-3.0"):Open("AugmentRuneReminder")
end
