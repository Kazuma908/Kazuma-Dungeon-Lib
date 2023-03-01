function setupBioQuestCounter()
	pc.setqf("collectCount", 0)
end

function updateBioQuestCounter()
	pc.setqf("collectCount", pc.getqf("collectCount") + 1)
end

function getBioQuestCount()
	return pc.getqf("collectCount")
end

function setTarget(vnum)
	local vid = find_npc_by_vnum(vnum)
	if not vid then return end

	target.vid(tostring(vnum), vid, mob_name(vnum))
end

function deleteTarget(vnum)
	target.delete(tostring(vnum))
end

function printQuestHeader(title)
	local title = title or "Information"

	say_title(title)
	say("")
end

function printQuestInfo(text)
	local text = text or "Aufgabe"

	say_reward(text)
	say("")
end

function sayQuestText(text, value)
	say2(text)

	if not value then
		say("")
	end
end

function inDropList(compare, list)
	for i = 1, table.getn(list) do
		if compare == list[i] then return true end
	end
	return false
end

function dropBioItem(vnum, count, chance)
	if pc.count_item(vnum) < count then
		local perc = number(1, 100)
	
		if perc <= chance then 
			game.drop_item_with_ownership(vnum, 1)
		end
	end	
end

function canProcessBioQuest(vnum)
	local sucsess = false
		if pc.count_item(vnum) > 0 then
			sucsess = true
		end
	return sucsess
end