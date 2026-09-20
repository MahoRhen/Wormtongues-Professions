local Wormtongue = {}
_G.Wormtongue = Wormtongue

--------------------------------------------------
-- Public Test Command
--------------------------------------------------
function wp()
	Wormtongue.ToggleWindow()
end

--------------------------------------------------
-- Events
--------------------------------------------------
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event)
	if Wormtongue.IsWindowShown() then
        Wormtongue.UpdateWindow()
    end
end)