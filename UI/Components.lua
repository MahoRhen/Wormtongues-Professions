

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
function Wormtongue:GetHeader(frame, index)
	if not frame.headers[index] then
		frame.headers[index] = createHeader(frame)
	end

	return frame.headers[index]
end

function Wormtongue:GetRow(frame, index)
	if not frame.rows[index] then
		frame.rows[index] = createRow(frame)
	end

	return frame.rows[index]
end

