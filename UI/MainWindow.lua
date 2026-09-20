

local WINDOW = {
	MIN_WIDTH = 250,
	MIN_HEIGHT = 250,
	MAX_WIDTH = 600,
	MAX_HEIGHT = 600,

	TITLE_Y = -15,
	CONTENT_START_Y = -45,

	LEFT_PADDING = 20,
	RIGHT_PADDING = 20,

	ROW_HEIGHT = 20,
	HEADER_HEIGHT = 25,
	SECTION_SPACING = 10
}

--------------------------------------------------
-- Window Creation
--------------------------------------------------
local function createWindow()
	local frame = CreateFrame("Frame", "WormtongueProfessionsFrame", UIParent)

	frame.rows = {}
	frame.headers = {}

	frame:SetWidth(WINDOW.MIN_WIDTH)
	frame:SetHeight(WINDOW.MIN_HEIGHT)
	frame:SetPoint("CENTER")

	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)

	frame:SetMinResize(WINDOW.MIN_WIDTH, WINDOW.MIN_HEIGHT)
	frame:SetMaxResize(WINDOW.MAX_WIDTH, WINDOW.MAX_HEIGHT)

	frame:RegisterForDrag("LeftButton")

	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,

		insets = {
			left = 11,
			right = 12,
			top = 12,
			bottom = 11
		}
	})

	----------------------------------------------
	-- Window Title
	----------------------------------------------
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

	frame.title:SetPoint("TOP", 0, WINDOW.TITLE_Y)
	frame.title:SetText(UnitName("player") .. "'s Professions")
	frame.title:SetTextColor(1, 0.5, 0, 1)

	----------------------------------------------
	-- Resize Button
	----------------------------------------------
	local resizeButton = CreateFrame("Button", nil, frame)

	resizeButton:SetWidth(16)
	resizeButton:SetHeight(16)
	resizeButton:SetPoint("BOTTOMRIGHT", -8, 8)

	resizeButton:SetNormalTexture(
		"Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
	)

	resizeButton:SetHighlightTexture(
		"Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight"
	)

	resizeButton:SetPushedTexture(
		"Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
	)

	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self:GetParent():StartSizing("BOTTOMRIGHT")
		end
	end)

	resizeButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			self:GetParent():StopMovingOrSizing()
		end
	end)
	
	----------------------------------------------
	-- Close Button
	----------------------------------------------
	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")	
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5. -5)
	closeButton:SetScript("OnClick", function()
		frame:Hide()
	end)

	frame:Hide()

	return frame
end

--------------------------------------------------
-- Hide Existing Content
--------------------------------------------------
local function hideWindowContent(frame)
	for _, header in ipairs(frame.headers) do
		header:Hide()
	end

	for _, row in ipairs(frame.rows) do
		row.name:Hide()
		row.current:Hide()
		row.slash:Hide()
		row.maximum:Hide()
	end
end

--------------------------------------------------
-- Window Update
--------------------------------------------------
local function updateWindow(frame)
	local skills =Wormtongue:GetProfessionSkills()

	hideWindowContent(frame)

	frame.title:SetText(UnitName("player") .. "'s Professions")

	local y = WINDOW.CONTENT_START_Y
	local lastSection = nil
	local headerIndex = 0
	local rowIndex = 0

	for i = 1, #skills do
		local skill = skills[i]

		------------------------------------------
		-- Section Header
		------------------------------------------

		if skill.section ~= lastSection then
			if lastSection then
				y = y - WINDOW.SECTION_SPACING
			end

			headerIndex = headerIndex + 1

			local header = Wormtongue:GetHeader(frame, headerIndex)

			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.LEFT_PADDING, y)

			header:SetText(skill.section)
			header:Show()

			y = y - WINDOW.HEADER_HEIGHT
			lastSection = skill.section
		end

		------------------------------------------
		-- Profession Row
		------------------------------------------

		rowIndex = rowIndex + 1

		local row = Wormtongue:GetRow(frame, rowIndex)

		local red, green, blue, alpha =
			Wormtongue:GetSkillColor(skill.rank, skill.maxRank)
			
		------------------------------------------
		-- Set Text
		------------------------------------------

		row.name:SetText(skill.name)
		row.current:SetText(skill.rank)
		row.maximum:SetText(skill.maxRank)

		------------------------------------------
		-- Position Elements
		------------------------------------------

		row.name:ClearAllPoints()
		row.name:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.LEFT_PADDING, y)

		row.current:ClearAllPoints()
		row.current:SetPoint("TOPLEFT", frame, "TOPLEFT", 145, y) -- 150, y

		row.slash:ClearAllPoints()
		row.slash:SetPoint("TOPLEFT", frame, "TOPLEFT", 145 + row.current:GetStringWidth() + 4, y) -- 170, y

		row.maximum:ClearAllPoints()
		row.maximum:SetPoint("TOPLEFT", frame, "TOPLEFT", 145 + row.current:GetStringWidth() + row.slash:GetStringWidth() + 8, y)

		------------------------------------------
		-- Set Skill Colors
		------------------------------------------

		row.current:SetTextColor(red, green, blue, alpha)
		row.maximum:SetTextColor(red, green, blue, alpha)

		------------------------------------------
		-- Show Elements
		------------------------------------------

		row.name:Show()
		row.current:Show()
		row.slash:Show()
		row.maximum:Show()

		y = y - WINDOW.ROW_HEIGHT
	end
end

--------------------------------------------------
-- Create Main Window
--------------------------------------------------
local professionFrame = createWindow()

--------------------------------------------------
-- Toggle Window
--------------------------------------------------
local function toggleWindow()
	if professionFrame:IsShown() then
		professionFrame:Hide()
	else
		updateWindow(professionFrame)
		professionFrame:Show()
	end
end

Wormtongue.ToggleWindow = toggleWindow

Wormtongue.UpdateWindow = function()
    updateWindow(professionFrame)
end
Wormtongue.IsWindowShown = function()
    return professionFrame:IsShown()
end

