quest dungeon_server_timer begin
	state start begin
		when dungeonExitTimer.server_timer begin
			if d.select(get_server_timer_arg()) then
				exitDungeon()
				dungeon_server_timer.clearDungeonServerTimer()
			end
		end

		when failed_dungeon.server_timer begin
			if d.select(get_server_timer_arg()) then
				exitDungeon()
				dungeon_server_timer.clearDungeonServerTimer()
			end
		end
	end
	state __FUNCTIONS__ begin
		function clearDungeonServerTimer()
			clear_server_timer("exit_dungeon", get_server_timer_arg())
			clear_server_timer("failed_dungeon", get_server_timer_arg())
		end
	end
end