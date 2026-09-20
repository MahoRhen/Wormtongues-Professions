

local WINDOW = {
	MIN_WIDTH = 250,
	MIN_HEIGHT = 250,
	MAX_WIDTH = 600,
	MAX_HEIGHT = 600,

	TITLE_Y = -15,
	CONTENT_START_Y = -45,

	LEFT_PADDING = 20,
	--RIGHT_PADDING = 20,

    SKILL_VALUE_X = 145,
    SKILL_SLASH_PADDING = 4,
    SKILL_MAX_PADDING = 8,

    RESIZE_BUTTON_SIZE = 16,
    RESIZE_BUTTON_OFFSET = 8,

    BACKDROP_INSET_LEFT = 11,
    BACKDROP_INSET_RIGHT = 12,
    BACKDROP_INSET_TOP = 12,
    BACKDROP_INSET_BOTTOM = 11,

    CLOSE_BUTTON_OFFSET = 5,

	ROW_HEIGHT = 20,
	HEADER_HEIGHT = 25,
	SECTION_SPACING = 10
}

--------------------------------------------------
-- Configure Window Frame
--------------------------------------------------
local function setupWindowFrame(frame)
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
end

--------------------------------------------------
-- Configure Window Backdrop
--------------------------------------------------
local function setupWindowBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = WINDOW.BACKDROP_TILE_SIZE,
        edgeSize = WINDOW.BACKDROP_EDGE_SIZE,

        insets = {
            left = WINDOW.BACKDROP_INSET_LEFT,
            right = WINDOW.BACKDROP_INSET_RIGHT,
            top = WINDOW.BACKDROP_INSET_TOP,
            bottom = WINDOW.BACKDROP_INSET_BOTTOM
        }
    })
end

--------------------------------------------------
-- Create Window Title
--------------------------------------------------
local function setupWindowTitle(frame)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, WINDOW.TITLE_Y)
    frame.title:SetText(UnitName("player") .. "'s Professions")
    frame.title:SetTextColor(1, 0.5, 0, 1)
end

--------------------------------------------------
-- Create Resize Button
--------------------------------------------------
local function setupResizeButton(frame)
    local resizeButton = CreateFrame("Button", nil, frame)

    resizeButton:SetWidth(WINDOW.RESIZE_BUTTON_SIZE)
    resizeButton:SetHeight(WINDOW.RESIZE_BUTTON_SIZE)
    resizeButton:SetPoint("BOTTOMRIGHT", -WINDOW.RESIZE_BUTTON_OFFSET, WINDOW.RESIZE_BUTTON_OFFSET)

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
end

--------------------------------------------------
-- Create Close Button
--------------------------------------------------
local function setupCloseButton(frame)
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -WINDOW.CLOSE_BUTTON_OFFSET, -WINDOW.CLOSE_BUTTON_OFFSET)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
end

--------------------------------------------------
-- Initialize Window Data
--------------------------------------------------
local function initializeWindowData(frame)
    frame.rows = {}
    frame.headers = {}
end

--------------------------------------------------
-- Window Creation
--------------------------------------------------
local function createWindow()
	local frame = CreateFrame("Frame", "WormtongueProfessionsFrame", UIParent)

    initializeWindowData(frame)

    setupWindowFrame(frame)
    setupWindowBackdrop(frame)
    setupWindowTitle(frame)
    setupResizeButton(frame)
    setupCloseButton(frame)

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
-- Update Section Header
--------------------------------------------------
local function updateSectionHeader(frame, skill, lastSection, headerIndex, y)
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
    return y, lastSection, headerIndex
end

--------------------------------------------------
-- Update Profession Row
--------------------------------------------------
local function updateProfessionRow(frame, skill, rowIndex, y)
    rowIndex = rowIndex + 1

    local row = Wormtongue:GetRow(frame, rowIndex)
    local red, green, blue, alpha = Wormtongue:GetSkillColor(skill.rank, skill.maxRank)
    
    -- Set Text
    row.name:SetText(skill.name)
    row.current:SetText(skill.rank)
    row.maximum:SetText(skill.maxRank)

    -- Position Elements
    row.name:ClearAllPoints()
    row.name:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.LEFT_PADDING, y)

    row.current:ClearAllPoints()
    row.current:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.SKILL_VALUE_X, y)

    row.slash:ClearAllPoints()
    row.slash:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.SKILL_VALUE_X + row.current:GetStringWidth() + WINDOW.SKILL_SLASH_PADDING, y)

    row.maximum:ClearAllPoints()
    row.maximum:SetPoint("TOPLEFT", frame, "TOPLEFT", WINDOW.SKILL_VALUE_X + row.current:GetStringWidth() + row.slash:GetStringWidth() + WINDOW.SKILL_MAX_PADDING, y)

    -- Set Skill Colors
    row.current:SetTextColor(red, green, blue, alpha)
    row.maximum:SetTextColor(red, green, blue, alpha)

    -- Show Elements
    row.name:Show()
    row.current:Show()
    row.slash:Show()
    row.maximum:Show()

    y = y - WINDOW.ROW_HEIGHT

    return rowIndex, y
end

--------------------------------------------------
-- Window Update
--------------------------------------------------
local function updateWindow(frame)
	local skills = Wormtongue:GetProfessionSkills()

	hideWindowContent(frame)

    -- Window Title
	frame.title:SetText(UnitName("player") .. "'s Professions")

	local y = WINDOW.CONTENT_START_Y
	local lastSection = nil
	local headerIndex = 0
	local rowIndex = 0

	for i = 1, #skills do
		local skill = skills[i]

		-- Section Header
		y, lastSection, headerIndex = updateSectionHeader(frame, skill, lastSection, headerIndex, y)

		-- Profession Row
		rowIndex, y = updateProfessionRow(frame, skill, rowIndex, y)
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

