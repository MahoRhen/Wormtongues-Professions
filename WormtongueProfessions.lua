--[[This is a multi-line comment, for future reference ]]
-- This is an inline comment

--[[
	Wormtongue's Professions

	Displays the player's primary and secondary professions.
]]

--------------------------------------------------
-- Configuration
--------------------------------------------------
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
-- Profession Data
--------------------------------------------------
local function getProfessionSkills()
	local skills = {}
	local currentSection = nil

	for i = 1, GetNumSkillLines() do
		local name, _, _, rank, _, _, maxRank = GetSkillLineInfo(i)

		if name == "Professions" then
			currentSection = "Professions"

		elseif name == "Secondary Skills" then
			currentSection = "Secondary Skills"

		elseif name == "Weapon Skills" then
			currentSection = nil

		elseif currentSection and name ~= "Riding" then
			table.insert(skills, {
				name = name,
				rank = rank,
				maxRank = maxRank,
				section = currentSection
			})
		end
	end

	return skills
end

--------------------------------------------------
-- Skill Color
--------------------------------------------------
local function getSkillColor(rank, maxRank)
	if maxRank == 0 then
		return 1, 0, 0, 1
	end

	local percent = rank / maxRank
	local red
	local green

	if percent <= 0.5 then
		red = 1
		green = percent * 2
	else
		red = (1 - percent) * 2
		green = 1
	end

	return red, green, 0, 1
end

--------------------------------------------------
-- UI Element Creation
--------------------------------------------------
local function createHeader(parent)
	local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	header:SetJustifyH("LEFT")

	return header
end

--------------------------------------------------
-- Create Profession Row
--------------------------------------------------
local function createRow(parent)
	local row = {}

	row.name = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetWidth(120)
	row.name:SetJustifyH("LEFT")

	row.current = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--row.current:SetWidth(25) 
	row.current:SetJustifyH("LEFT") 

	row.slash = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.slash:SetText("/")
	row.slash:SetTextColor(1, 1, 1, 1)

	row.maximum = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--row.maximum:SetWidth(25) 
	row.maximum:SetJustifyH("LEFT") 

	return row
end

--------------------------------------------------
-- Reusable UI Element Retrieval
--------------------------------------------------
local function getHeader(frame, index)
	if not frame.headers[index] then
		frame.headers[index] = createHeader(frame)
	end

	return frame.headers[index]
end

local function getRow(frame, index)
	if not frame.rows[index] then
		frame.rows[index] = createRow(frame)
	end

	return frame.rows[index]
end

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
	local skills = getProfessionSkills()

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

			local header = getHeader(frame, headerIndex)

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

		local row = getRow(frame, rowIndex)

		local red, green, blue, alpha =
			getSkillColor(skill.rank, skill.maxRank)
			
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

--------------------------------------------------
-- Public Test Command
--------------------------------------------------
function wp()
	toggleWindow()
end

--------------------------------------------------
-- Events
--------------------------------------------------
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event)
	if professionFrame:IsShown() then
		updateWindow(professionFrame)
	end
end)
