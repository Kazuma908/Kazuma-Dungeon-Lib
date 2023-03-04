DUNGEON_TYPE_NONE = 0
DUNGEON_TYPE_KILL_MONSTER = 1
DUNGEON_TYPE_KILL_BOSS = 2
DUNGEON_TYPE_KILL_METINSTONE = 3
DUNGEON_TYPE_KEYSTONE = 4
DUNGEON_TYPE_TALK_TO_NPC = 5
DUNGEON_TYPE_KEYSTONE_IN_WAVES = 6
DUNGEON_TYPE_FIND_REAL_METINSTONE = 7
DUNGEON_TYPE_KILL_RANDOM_BOSS = 8

function selectDungeon(min_level, dungeon_map_idx, dungeon_local_x, dungeon_local_y, dungeon_name, fail_time, entry_item, entry_item_count, only_solo_modus, dungeon_cooldown, dungeon_cooldown_reset_item, dungeon_cooldown_reset_item_count)
	printQuestHeader(mob_name(npc.race))

	if min_level > pc.get_level() then
		center(string.format("Du bist noch nicht Stark genug! Du musst Level %d erreicht haben!", min_level))
		return
	end

	local cooldown_sucsess = true

	if hasDungeonCooldown(dungeon_map_idx) then
		local v = dungeon_cooldown_reset_item
		local c = dungeon_cooldown_reset_item_count

		if v == 0 then 
			center(string.format("Du musst noch %s warten!", second_to_hms((getDungeonTimerFlag(dungeon_map_idx)-os.time()))))
			cooldown_sucsess = false
		end

		if v > 0 and pc.count_item(v) >= c then
			center(string.format("Du hast das %s dabei! Möchtest du es verwenden?", item_name(v)))
			
			local reduce_time = select(string.format("%s anwenden!", item_name(v)), "Abbrechen")
			if reduce_time == 2 then 
				cooldown_sucsess = false 
			end
			pc.remove_item(v, c)
			resetDungeonTimerFlag(dungeon_map_idx)
		else
			center(string.format("Du musst noch %s warten!", second_to_hms((getDungeonTimerFlag(dungeon_map_idx)-os.time()))))
			cooldown_sucsess = false
		end
	end

	if not cooldown_sucsess then return end

	center(string.format("Möchstest du %s bereten?", dungeon_name))
	
	local s = select("Eintreten!", "Abbrechen")
	if s == 2 then return end
	
	if not checkEntryMember(min_level, npc.race) then return end
	if not checkEntryItems(entry_item, entry_item_count, entry_npc) then return end
	
	if only_solo_modus == 0 then
		if party.is_party() then
			if party.is_leader() then
				d.new_jump_party(dungeon_map_idx, dungeon_local_x, dungeon_local_y)
			else
				printQuestHeader(mob_name(npc.race))
				center("Bitte lass mich mit deinem Gruppenanführer sprechen!")
				return
			end
		else
			d.new_jump(dungeon_map_idx, dungeon_local_x*100, dungeon_local_y*100)
		end
	elseif only_solo_modus == 1 then
		d.new_jump(dungeon_map_idx, dungeon_local_x*100, dungeon_local_y*100)
	end

	pc.remove_item(entry_item, entry_item_count)
	setBasePositions(dungeon_local_x, dungeon_local_y)
	setDungeonMapIndex(dungeon_map_idx)
	setDungeonCooldownTime(dungeon_cooldown, dungeon_map_idx)

	if fail_time > 0 then
		server_timer("failed_dungeon", fail_time, d.get_map_index())
	end

	d.set_warp_location( dungeon_map_idx, dungeon_local_x*100, dungeon_local_y*100 )
end

function checkEntryMember(min_level, entry_npc)
	local cancelLevelUsers = {}
	local pids = {party.get_member_pids()}

	for i = 1, table.getn(pids), 1 do
		q.begin_other_pc_block(pids[i])
		if pc.get_level() < min_level then
			table.insert(cancelLevelUsers, table.getn(cancelLevelUsers)+1, pc.get_name())
		end
		q.end_other_pc_block()
	end

	if table.getn(cancelLevelUsers) >= 1 then
		center_title(mob_name(entry_npc))
		center(string.format("Einer deiner Gruppenmitglieder ist nicht Level %d!", min_level))
		
		for x = 1, table.getn(cancelLevelUsers), 1 do
			center(string.format("- %s", cancelLevelUsers[x]), true)
		end

		return false
	end

	if table.getn(cancelLevelUsers) == 0 then
		return true
	end
end

function checkEntryItems(vnum, count, entry_npc)
	local sucsess = false

	if vnum == 0 then
		sucsess = true
	end

	if party.is_party() then
		if party.is_leader() then
			if pc.count_item(vnum) >= count then 
				sucsess = true
			else
				center_title(mob_name(entry_npc))
				center(string.format("Euch fehlt das %s %d mal!", item_name(vnum), count))
			end
		else
			center_title(mob_name(entry_npc))
			center(string.format("Du musst Anführer der Gruppe sein um %s abzugeben!", item_name(vnum)))
		end
	else
		if pc.count_item(vnum) >= count then 
			sucsess = true
		else
			center_title(mob_name(entry_npc))
			center(string.format("Dir fehlt das %s %d mal!", item_name(vnum), count))
		end
	end
	return sucsess
end

function setDungeonCooldownTime(dungeon_cooldown, map_index)
	if dungeon_cooldown == 0 then return end

	local idx = map_index or getDungeonBaseMapIndex()
	pc.setf("dungeon", string.format("cooldown_%d_timer_flag", idx), (get_time() + dungeon_cooldown))
end

function getDungeonTimerFlag(idx)
	return pc.getf("dungeon", string.format("cooldown_%d_timer_flag", idx))
end

function hasDungeonCooldown(idx)
	return get_time() < getDungeonTimerFlag(idx)
end

function resetDungeonTimerFlag(idx)
	pc.setf("dungeon", string.format("cooldown_%d_timer_flag", idx), 0)
end

function getDungeonCooldown(idx)
	return (getDungeonTimerFlag(idx)-get_time())
end

function isPartyLeaderOrSolo()
	return (party.is_party() and party.is_leader()) or not party.is_party()
end

function setDungeonMapIndex(idx)
	d.setf("base_map_index", idx)

	if party.is_party() then
		party.setf("dungeonIndex", d.get_map_index())
	else
		pc.setf("dungeon", "dungeonIndex", d.get_map_index())
	end
end

function getDungeonMapIndex()
	if party.is_party() then
		return party.getf("dungeonIndex")
	else
		return pc.getf("dungeon", "dungeonIndex")
	end
end

function getDungeonBaseMapIndex()
	return d.getf("base_map_index")
end

function isInDungeonByMapIndex(map_index)
	return pc.get_map_index() >= (map_index * 10000) and pc.get_map_index() < ((map_index+1) * 10000)
end

function clearDungeon()
	d.setf("stage", 0)
	d.setf("dungeon_started", 0)
	d.clear_regen()
	d.kill_all()
	d.kill_all()
end

function clearStage()
	d.clear_regen()
	d.kill_all()
	d.kill_all()
end

function incDungeonStage()
	d.setf("stage", d.getf("stage")+1)
end

function setStage(val)
	d.setf("stage", val)
end

function setNextDungeonStageTimer()
	setDungeonStageType(0)

	if isDungeonEndFlag() then
		d.notice("Du hast den Dungeon abgeschlossen. Du wirst in 20 Sekunden herrausteleportiert!")
		clearDungeon()

		server_timer("dungeonExitTimer", 20, d.get_map_index())
	else
		clearStage()
		d.notice(string.format("Du hast die Ebene abgeschlossen. Die nächste Ebene startet in %d Sekunden!", 3))
		incDungeonStage()
		timer("increaseStageTimer", 3)
	end
end

function setBasePositions(x, y)
	d.setf("base_x", x)
	d.setf("base_y", y)
end

function getBasePositions()
	return getDungeonBaseMapIndex(), d.getf("base_x"), d.getf("base_y")
end

function setDungeonWarpLocation()
	d.set_warp_location(getDungeonBaseMapIndex(), d.getf("base_x"), d.getf("base_y"))
	d.setf("dungeon_started", 1)
end

function isDungeonStarted()
	return d.getf("dungeon_started") == 1
end

function setDungeonStageType(val)
	d.setf("dungeon_stage_type", val)
end

function getDungeonStageType()
	return d.getf("dungeon_stage_type")
end

function setDungeonEndFlag()
	d.setf("dungeon_end", 1)
end

function isDungeonEndFlag()
	return d.getf("dungeon_end") == 1
end

function exitDungeon()
	d.setf("base_map_index", 0)
	d.setf("dungeon_stage_type", 0)
	d.setf("dungeon_end", 0)
	d.exit_all()
end

function printDungeonStageText(text)
	local stageText = string.format("[Ebene %d]: ", getStage()+1)

	d.notice(stageText .. text)
end

function getStage()
	return d.getf("stage")
end

function setMaxStage(val)
	d.setf("max_stage", val)
end

function getMaxStage()
	return d.getf("max_stage")
end

-- DUNGEON_SETTINGS END

-- DUNGEON BASIC FUNCTIONS START

function getDungeonItemVnum()
	return d.getf("dungeon_item_vnum")
end

function setDungeonItemVnum(vnum)
	d.setf("dungeon_item_vnum", vnum)
end

function getDungeonItemDropCount()
	return d.getf("dungeon_item_drop_count")
end

function setDungeonItemDropCount(c)
	d.setf("dungeon_item_drop_count", c)
end

function getItemDropChance()
	return d.getf("dungeon_item_drop_chance")
end

function setItemDropChance(val)
	d.setf("dungeon_item_drop_chance", val)
end

function dropItemInDungeon()
	if number(1, 100) <= getItemDropChance() then
		local c = getDungeonItemDropCount() or 1
		game.drop_item(getDungeonItemVnum(), c)
	end
end

-- DUNGEON BASIC FUNCTIONS END

-- STAGE KILL BOSS START

function setBossNeededCount(count)
	d.setf("boss_monster_max_count", count)
end

function getNeededBossCount()
	return d.getf("boss_monster_max_count")
end

function setBossCount(count)
	d.setf("boss_monster_count", count)
end

function getBossCount()
	return d.getf("boss_monster_count")
end

function increaseBossCount()
	d.setf("boss_monster_count", getBossCount() + 1)
end

function setBossVnum(v)
	d.setf("boss_monster_vnum", v)
end

function getBossVnum()
	return d.getf("boss_monster_vnum")
end

function clearBossStage()
	setBossVnum(0)
	setBossCount(0)
	setBossNeededCount(0)
end

function spawnBoss(boss_table, alternativ_regen, aggressive)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local monsterTableLength = table.getn(boss_table)
	if not boss_table or monsterTableLength == 0 then return end

	setDungeonStageType(DUNGEON_TYPE_KILL_BOSS)
	setBossNeededCount(monsterTableLength)

	local bossNamesTable = {}

	for i = 1, monsterTableLength do
		local t = boss_table[i]
		local name = mob_name(t.vnum)

		radius = t.radius or 0

		d.set_unique(string.format("boss_vnum_%d", i) , d.spawn_mob(t.vnum, t.x, t.y, radius, 1))

		if not contains(bossNamesTable, name) then
			table.insert(bossNamesTable, name)
		end
	end

	printDungeonStageText(string.format("Besiege %s!", tableToEnumeratedString(bossNamesTable)))

	aggressive = aggressive or false

	if alternativ_regen then
		d.regen_file(alternativ_regen, aggressive)
	end
end

function stageKillBoss(vid)
	if getDungeonStageType() == DUNGEON_TYPE_KILL_BOSS then
		for i = 1, getNeededBossCount() do
			if d.get_unique_vid(string.format("boss_vnum_%d", i)) == vid then
				increaseBossCount()
				printDungeonStageText(string.format("%s wurde besiegt!", mob_name(npc.race)))

				if getBossCount() == getNeededBossCount() then
					clearBossStage()
					setNextDungeonStageTimer()
				end
			end
		end
	end
end

-- STAGE KILL BOSS END

-- STAGE KILL RANDOM BOSS START

function setRandomBossVid(v)
	d.setf("boss_random_monster_vid", v)
end

function getRandomBossVid()
	return d.getf("boss_random_monster_vid")
end

function clearRandomBossStage()
	d.setf("boss_random_monster_vid", 0)
end

function spawnRandomBoss(boss_table, alternativ_regen, aggressive)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local monsterTableLength = table.getn(boss_table)
	if not boss_table or monsterTableLength == 0 then return end

	setDungeonStageType(DUNGEON_TYPE_KILL_RANDOM_BOSS)

	for _, t in ipairs(boss_table) do
		local count = t.count or 1
		local radius = t.radius or 0
		local boss_vnum = choice(t.vnum)

		local vid = d.spawn_mob(boss_vnum, t.x, t.y, radius, count)
		printDungeonStageText(string.format("Besiege %s!", mob_name(boss_vnum)))
		setRandomBossVid(vid)
	end

	aggressive = aggressive or false

	if alternative_regen then
		d.regen_file(alternative_regen, aggressive)
	end
end

function stageKillRandomBoss(vid)
	if getDungeonStageType() == DUNGEON_TYPE_KILL_RANDOM_BOSS then
		if getRandomBossVid() == vid then
			printDungeonStageText(string.format("%s wurde besiegt!", mob_name(npc.race)))
			clearRandomBossStage()
			setNextDungeonStageTimer()
		end
	end
end

-- STAGE KILL RANDOM BOSS END

-- STAGE KILL MONSTER START

function incMobCount()
	d.setf("monster_count", getDungeonMobCount()+1)
end

function clearKillMonsterStage()
	d.setf("monster_count", 0)
	d.setf("max_monster_count", 0)
end

function getDungeonMobCount()
	return d.getf("monster_count")
end

function setMaxMobCount(count)
	d.setf("max_monster_count", count)
end

function getDungeonMaxMobCount()
	return d.getf("max_monster_count")
end

function spawnMonsters(regen_file, count, aggro, respawn)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local aggressiv = aggro or false

	if respawn then
		d.set_regen_file(regen_file, aggressiv)
	else
		d.regen_file(regen_file, aggressiv)
	end

	setDungeonStageType(DUNGEON_TYPE_KILL_MONSTER)
	setMaxMobCount(count)
	printDungeonStageText(string.format("Besiege %d Monster!", count))
end

function stageKillMonster()
	if getDungeonStageType() == DUNGEON_TYPE_KILL_MONSTER then
		incMobCount(getDungeonMobCount()+1)
	
		if getDungeonMobCount() == getDungeonMaxMobCount() then
			printDungeonStageText(string.format("Alle %s Monster wurden besiegt!", getDungeonMaxMobCount()))
			clearKillMonsterStage()
			setNextDungeonStageTimer()
		end
	end
end

-- STAGE KILL MONSTER END

-- STAGE DESTROY METINSTONE START

function getDungeonMetinCount()
	return d.getf("metin_count")
end

function incDungeonMetinCount()
	d.setf("metin_count", getDungeonMetinCount()+1)
end

function clearDestroyMetinStage()
	d.setf("metin_count", 0)
	d.setf("metinstone_vnum", 0)
	d.setf("metin_max_count", 0)
end

function setMetinstoneVnum(race)
	d.setf("metinstone_vnum", race)
end

function getMetinstoneVnum()
	return d.getf("metinstone_vnum")
end

function setMetinstoneMaxCount(count)
	d.setf("metin_max_count", count)
end

function getMetinstoneMaxCount()
	return d.getf("metin_max_count")
end

function spawnMetinstone(metin_table, alternativ_regen)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local monsterTableLength = table.getn(metin_table)
	if not metin_table or monsterTableLength == 0 then return end

	setDungeonStageType(DUNGEON_TYPE_KILL_METINSTONE)
	setMetinstoneMaxCount(monsterTableLength)

	local metinNamesTable = {}

	for i = 1, monsterTableLength do
		local t = metin_table[i]
		local name = mob_name(t.vnum)

		d.set_unique(string.format("metin_vnum_%d", i) , d.spawn_mob_dir(t.vnum, t.x, t.y, 1))
		if not contains(metinNamesTable, name) then
			table.insert(metinNamesTable, name)
		end
	end

	printDungeonStageText(string.format("Besiege %d %s!", monsterTableLength, tableToEnumeratedString(metinNamesTable)))

	local aggro = aggressive or false

	if alternativ_regen then
		d.regen_file(alternativ_regen, aggro)
	end
end

function stageDestroyMetinstone(vid)
	if getDungeonStageType() == DUNGEON_TYPE_KILL_METINSTONE then
		for i = 1, getMetinstoneMaxCount() do
			if d.get_unique_vid(string.format("metin_vnum_%d", i)) == vid then
				incDungeonMetinCount()
				printDungeonStageText(string.format("%s wurde zerstört!", mob_name(npc.race)))
				if getDungeonMetinCount() == getMetinstoneMaxCount() then
					clearDestroyMetinStage()
					setNextDungeonStageTimer()
				end
			end
		end
	end
end

-- STAGE DESTROY METINSTONE END

-- STAGE KEYSTONE START

function getKeystoneChance()
	return d.getf("keystone_chance")
end

function setKeystoneChance(chance)
	d.setf("keystone_chance", chance)
end

function getMaxItemCount()
	return d.getf("dungeon_item_max_count")
end

function setMaxItemCount(val)
	d.setf("dungeon_item_max_count", val)
end

function clearKeystoneStage()
	d.setf("dungeon_item_vnum", 0)
	setItemDropChance(0)
	setMaxItemCount(0)
	d.setf("dungeon_item_count", 0)
	setKeystoneCount(0)
	setMonsterKeystoneCount(0)
	setMonsterKeystoneMaxCount(0)
end

function setKeystoneCount(val)
	d.setf("dungeon_keystone_count", val)
end

function getKeystoneCount()
	return d.getf("dungeon_keystone_count")
end 

function increaseKeystoneCount()
	d.setf("dungeon_keystone_count", getKeystoneCount()+1)
end

function setMonsterKeystoneCount(val)
	d.setf("dungeon_keystone_mob_count", val)
end

function getMonsterKeystoneCount()
	return d.getf("dungeon_keystone_mob_count")
end

function increaseMonsterKeystoneCount()
	d.setf("dungeon_keystone_mob_count", getMonsterKeystoneCount()+1)
end

function setMonsterKeystoneMaxCount(val)
	d.setf("dungeon_keystone_max_mob_count", val)
end

function getMonsterKeystoneMaxCount()
	return d.getf("dungeon_keystone_max_mob_count")
end

function spawnKeystoneNpc(npc_table, item_table, regen_file, aggro, respawn)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local aggressiv = aggro or false
	local respawn = respawn or false
	local npcNameTable = {}

	for _, npc in ipairs(npc_table) do
		local count = npc.count or 1
		local radius = npc.radius or 0

		local vid = d.spawn_mob(npc.vnum, npc.x, npc.y, radius, count)
		local name = mob_name(npc.vnum)

		if not contains(npcNameTable, name) then
			table.insert(npcNameTable, name)
		end
	end

	printDungeonStageText(string.format("Finde %s und gebe es bei %s ab!", item_name(item_table.vnum), tableToEnumeratedString(npcNameTable)))

	setMaxItemCount(table.getn(npc_table))
	setItemDropChance(item_table.drop_chance)
	setDungeonItemVnum(item_table.vnum)
	setKeystoneChance(item_table.sucsess_chance)

	if canRespawn then
		d.set_regen_file(regen_file, aggressiv)
	else
		d.regen_file(regen_file, aggressiv)
	end

	setDungeonStageType(DUNGEON_TYPE_KEYSTONE)
end

function spawnKeystoneNpcInWaves(item_table, npc_table, regen_file, aggressiv)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local item_vnum = item_table.vnum
	local item_count = item_table.count
	local npcNamesTable = {}

	for _, npc in ipairs(npc_table) do
		local vid = d.spawn_mob(npc.vnum, npc.x, npc.y)
		local name = mob_name(npc.vnum)

		if not contains(npcNamesTable, name) then
			table.insert(npcNamesTable, name)
		end
	end

	d.regen_file(regen_file, aggressiv)
	setMonsterKeystoneMaxCount(d.count_monster()-5)

	setMaxItemCount(table.getn(npc_table))
	setItemDropChance(item_table.drop_chance)
	setDungeonItemVnum(item_vnum)
	setKeystoneChance(item_table.sucsess_chance)
	setDungeonStageType(DUNGEON_TYPE_KEYSTONE_IN_WAVES)

	printDungeonStageText(string.format("Finde %s und gebe es bei %s ab!", item_name(item_vnum), tableToEnumeratedString(npcNamesTable)))
end

function stageKeystoneWithItem()
	if getDungeonStageType() == DUNGEON_TYPE_KEYSTONE then
		increaseKeystoneCount()
		pc.remove_item(getDungeonItemVnum(), 1)
		printDungeonStageText(string.format("Es fehlen noch %d x %s!", (getMaxItemCount()-getKeystoneCount()), item_name(getDungeonItemVnum())))

		if getKeystoneCount() == getMaxItemCount() then
			clearKeystoneStage()
			setNextDungeonStageTimer()
		end

		npc.purge()
	end
end

function stageKeystoneInWaves(regen)
	if getDungeonStageType() == DUNGEON_TYPE_KEYSTONE_IN_WAVES then
		if number(1, 100) <= getKeystoneChance() then
			increaseKeystoneCount()
			pc.remove_item(getDungeonItemVnum(), 1)
	
			if getKeystoneCount() == getMaxItemCount() then
				clearKeystoneStage()
				setNextDungeonStageTimer()
			else
				printDungeonStageText(string.format("Es fehlen noch %d x %s!", (getMaxItemCount()-getKeystoneCount()), item_name(getDungeonItemVnum())))
				d.regen_file(regen)
			end
	
			npc.purge()
		end
	end
end

function stageDropKeystoneItem()
	if getDungeonStageType() == DUNGEON_TYPE_KEYSTONE then
		increaseMonsterKeystoneCount()
		local rand = number(1, 100)
		local sucsess = false

		if getItemDropChance() >= rand then
			sucsess = true
		end
		
		if sucsess then
			printDungeonStageText(string.format("%s wurde gefunden!", item_name(getDungeonItemVnum())))
			local c = getDungeonItemDropCount() or 1

			setMonsterKeystoneCount(0)
			game.drop_item(getDungeonItemVnum(), c)
		end
	end
end


function stageDropKeystoneItemInWaves()
	if getDungeonStageType() == DUNGEON_TYPE_KEYSTONE_IN_WAVES then
		increaseMonsterKeystoneCount()
		local rand = number(1, 100)
		local sucsess = false

		if (getMonsterKeystoneCount() >= getMonsterKeystoneMaxCount()) then
			sucsess = true
		end

		if sucsess then
			printDungeonStageText(string.format("%s wurde gefunden!", item_name(getDungeonItemVnum())))
			local c = getDungeonItemDropCount() or 1

			setMonsterKeystoneCount(0)
			game.drop_item(getDungeonItemVnum(), c)
		end
	end
end

-- STAGE KEYSTONE AND KEYSTONE_IN_WAVES END

-- STAGE FIND_REAL_METINSTONE START

function setRealMetinstoneVid(vid)
	d.setf("real_metinstone_vid", vid)
end

function getRealMetinstoneVid()
	return d.getf("real_metinstone_vid")
end

function destroyRealMetinstone(race, metin_table)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local monsterTableLength = table.getn(metin_table)
	setMetinstoneMaxCount(count)
	local stone_vids = {}

	for i = 1, monsterTableLength do
		local t = metin_table[i]

		local v = d.spawn_mob(t.vnum, t.x, t.y)
		table.insert(stone_vids, v)
	end

	setRealMetinstoneVid(choice(stone_vids))

	setDungeonStageType(DUNGEON_TYPE_FIND_REAL_METINSTONE)
	printDungeonStageText(string.format("Finde den echten %s und zerstöre ihn!", mob_name(race)))
end

function stageDestroyRealMetinstone(vid)
	if getDungeonStageType() == DUNGEON_TYPE_FIND_REAL_METINSTONE then
		if vid == getRealMetinstoneVid() then
			printDungeonStageText(string.format("Der richtige %s wurde zerstörte!", mob_name(npc.race)))
			setRealMetinstoneVid(0)
			setNextDungeonStageTimer()
		end
	end
end

-- STAGE FIND_REAL_METINSTONE END

-- STAGE DUNGEON_TYPE_TALK_TO_NPC START

function setDungeonNpcVid(vid)
	d.setf("dungeon_npc_vid", vid)
end

function getDungeonNpcVid()
	return d.getf("dungeon_npc_vid")
end

function setDungeonNpcCount(vid)
	d.setf("dungeon_npc_count", vid)
end

function getDungeonNpcCount()
	return d.getf("dungeon_npc_count")
end

function setDungeonNpcMaxCount(val)
	d.setf("dungeon_npc_max_count", val)
end

function getDungeonNpcMaxCount()
	return d.getf("dungeon_npc_max_count")
end

function clearTalkToNpcStage()
	setDungeonNpcMaxCount(0)
	setDungeonNpcCount(0)
	setDungeonNpcVid(0)
end

function spawnNpcInDungeon(npc_table)
	if getDungeonStageType() > DUNGEON_TYPE_NONE then return end

	local npc_vnum = npc_table.vnum
	local vid = d.spawn_mob_dir(npc_vnum, npc_table.x, npc_table.y, 1)

	d.set_unique("npc_vid", vid)
	target.vid(tostring(vid), vid, mob_name(npc_vnum))
	setDungeonStageType(DUNGEON_TYPE_TALK_TO_NPC)

	printDungeonStageText(string.format("Sprich mit %s um den Dungeon fortzusetzen!", mob_name(npc_vnum)))
end

function talkToNpc(vid, text)
	if getDungeonStageType() == DUNGEON_TYPE_TALK_TO_NPC then
		if d.get_unique_vid("npc_vid") == vid then
			target.delete(tostring(vid))

			printQuestHeader(mob_name(npc.race))
			center(string.format("%s", text))

			npc.purge()
			clearTalkToNpcStage()
			setNextDungeonStageTimer()
			return
		end
	end
end

-- STAGE DUNGEON_TYPE_TALK_TO_NPC END
