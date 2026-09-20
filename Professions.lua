

--------------------------------------------------
-- Profession Data
--------------------------------------------------
function Wormtongue:GetProfessionSkills()
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
function Wormtongue:GetSkillColor(rank, maxRank)
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
