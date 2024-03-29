define DUNGEON_NPC 20355
define STAGE_1_METIN_VNUM 8001
define NO_ENTRY_ITEM 0
define DUNGEON_INDEX 71
define STAGE_4_PILLAR_NPC 20361
define STAGE_5_NPC 20370
define DUNGEON_ENTRY_POS_X 7039
define DUNGEON_ENTRY_POS_Y 4630
define STAGE_1_WARP_X 7124
define STAGE_1_WARP_Y 4727

quest dungeon_index_71 begin
	state start begin
		when DUNGEON_NPC.chat."Spinnen Dungeon" begin
			selectDungeon(99, DUNGEON_INDEX, DUNGEON_ENTRY_POS_X, DUNGEON_ENTRY_POS_Y, "Spinnen Dungeon", 60*60, NO_ENTRY_ITEM, NO_ENTRY_ITEM, 1, 0, 0, 0)
		end

		-- START for testing!
		when letter with pc.is_gm() and isInDungeonByMapIndex(DUNGEON_INDEX) begin
			send_letter("Zu Ebene springen")
		end

		when button or info with pc.is_gm() and isInDungeonByMapIndex(DUNGEON_INDEX) begin
			center_title("Zu Ebene springen")
			center("How To:!", true)
			center("Du tr�gst hier deine gew�nschte Ebene -1 ein! Im Code ist die erste Ebene 0.", true)
			center("Wenn du also in die erste Ebene m�chtest tr�gst du eine 0 ein!")

			local stage = input()

			setStage(tonumber(stage)-1)
			setNextDungeonStageTimer()
		end
		-- END for testing!

		when login or enter with isInDungeonByMapIndex(DUNGEON_INDEX) begin
			local stage = getStage()
	
			if stage == 0 then
				setDungeonWarpLocation()
	
				spawnMetinstone({
					{vnum = 8001, x = 387, y = 316}, 
					{vnum = 8002, x = 387, y = 352}, 
					{vnum = 8003, x = 387, y = 374}, 
				})
	
			elseif stage == 1 then
				spawnMonsters("data/dungeon/basic_dungeon_kazuma/regen_stage_1.txt", 30)
	
			elseif stage == 2 then
				spawnBoss({
					{vnum = 692, x = 428, y = 375, radius = 0},
				}, nil, true)
	
			elseif stage == 3 then
				destroyRealMetinstone(8004, {
					{vnum = 8004, x = 387, y = 316}, 
					{vnum = 8004, x = 387, y = 352}, 
				})
	
			elseif stage == 4 then
				spawnKeystoneNpc({{vnum = STAGE_4_PILLAR_NPC, x = 387, y = 374}}, {vnum = 30007, sucsess_chance = 75, drop_chance = 1}, "data/dungeon/basic_dungeon_kazuma/regen_stage_1.txt", true, true)
	
			elseif stage == 5 then
				spawnNpcInDungeon({vnum = STAGE_5_NPC, x = 387, y = 374})
	
			elseif stage == 6 then
				setDungeonEndFlag()
				spawnRandomBoss({
					{vnum = {1101, 1102, 1103}, x = 387, y = 374, count = 1, radius = 0},
				}, "data/dungeon/basic_dungeon_kazuma/regen_stage_1.txt", true)
			end
		end	

		when kill with isInDungeonByMapIndex(DUNGEON_INDEX) begin
			local stage = getStage()
			local race = npc.get_race()
			local vid = npc.get_vid()

			if stage == 0 then
				stageDestroyMetinstone(vid)
			elseif stage == 1 then
				stageKillMonster()
			elseif stage == 2 then
				stageKillBoss(vid)
			elseif stage == 3 then
				stageDestroyRealMetinstone(vid)
			elseif stage == 4 then
				stageDropKeystoneItem()
			elseif stage == 5 then
				return
			elseif stage == 6 then
				stageKillRandomBoss(vid)
			end
		end

		when STAGE_4_PILLAR_NPC.take with item.vnum == getDungeonItemVnum() and isInDungeonByMapIndex(DUNGEON_INDEX) begin
			local stage = getStage()

			if stage == 4 then
				stageKeystoneWithItem()
			end
		end

		when STAGE_5_NPC.click with isInDungeonByMapIndex(DUNGEON_INDEX) begin
			local stage = getStage()

			if stage == 5 then
				talkToNpc(npc.get_vid(), "Hallo! Hier kommt ein Text rein, welche irgendeinen Sinn hat!")
			end
		end

		when increaseStageTimer.timer with isInDungeonByMapIndex(DUNGEON_INDEX) begin
			set_state("restart_stage")
		end
	end

	state restart_stage begin
		when enter or login begin
			if isInDungeonByMapIndex(DUNGEON_INDEX)
				local stage = getStage()
				if stage == 1 then
					d.jump_all(STAGE_1_WARP_X, STAGE_1_WARP_Y)
				end
			end

			set_state("start")
		end
	end

	state __FUNCTIONS__ begin
	end
end