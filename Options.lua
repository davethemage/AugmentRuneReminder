local addonName, AugmentRuneReminder = ...
local LSM = LibStub("LibSharedMedia-3.0")

local function fontValues()
    local fonts = LSM:HashTable("font")
    local values = {}
    for name, _ in pairs(fonts) do
        values[name] = name -- key = label
    end
    return values
end

local function UpdateButtonGlow(self)
    LibStub("LibButtonGlow-1.0").HideOverlayGlow(self.button)
    if self.db.profile.buttonGlow then
        LibStub("LibButtonGlow-1.0").ShowOverlayGlow(self.button)
    end
end
function AugmentRuneReminder:SetupOptions()
    local options = {
        name = "Augment Rune Reminder",
        type = "group",
        args = {
            -- Text Options Header
            textHeader = {
                type = "header",
                name = "Text Options",
                order = 1,
            },
            font = {
                type = "select",
                name = "Font",
                order = 2,
                values = fontValues,
                get = function() return self.db.profile.fontName or "Friz Quadrata TT" end,
                set = function(info, value)
                    self.db.profile.fontName = value;
                    self.text:SetFont(LSM:Fetch("font", self.db.profile.fontName), self.db.profile.fontSize or 16, "OUTLINE")
                end,
            },
            textSize = {
                type = "range",
                name = "Text Size",
                order = 3,
                min = 6, max = 32, step = 1,
                get = function() return self.db.profile.fontSize or 16 end,
                set = function(info, value)
                    self.db.profile.fontSize = value;
                    self.text:SetFont(LSM:Fetch("font", self.db.profile.fontName or "Friz Quadrata TT"), self.db.profile.fontSize, "OUTLINE")
                end,
            },
            showText = {
                type = "toggle",
                name = "Show text",
                order = 4,
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

            -- Button Options Header
            buttonHeader = {
                type = "header",
                name = "Button Options",
                order = 10,
            },
            buttonSize = {
                type = "range",
                name = "Button Size",
                order = 11,
                min = 10, max = 100, step = 1,
                get = function() return self.db.profile.buttonSize or 40 end,
                set = function(_, value)
                    self.db.profile.buttonSize = value
                    self.button:SetSize(value, value)
                    UpdateButtonGlow(self)
                end,
            },
            buttonGlow = {
                type = "toggle",
                name = "Button Glow",
                order = 12,
                get = function() return self.db.profile.buttonGlow or false end,
                set = function(_, value)
                    self.db.profile.buttonGlow = value
                    UpdateButtonGlow(self)
                end,
            },

            -- Position Options Header
            positionHeader = {
                type = "header",
                name = "Position Options",
                order = 20,
            },
            posX = {
                type = "range",
                name = "Button X position",
                order = 21,
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
                order = 22,
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