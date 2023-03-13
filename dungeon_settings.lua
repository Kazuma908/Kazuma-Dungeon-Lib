function getDungeonItemSettings(vnum)
	local item_table = {
		[30006] = {index = XXX, level = 99, local_x = XXXXX, local_y = XXXXX, fail_time = 60*60},
	}
	return item_table[vnum]
end

function isDungeonEntryItem(vnum, map_index)
	local settings = getDungeonItemSettings(vnum)
	if not settings then return false
	
	return settings.index == map_index
end