quest young_hero_weapon_quest begin
	state start begin
		when login or letter or enter or levelup begin
			if pc.level >= young_hero_weapon_quest.getNextQuestLevel() then
				pc.setf("system", "is_younghero_weapon_aviable", 1)
			end

			if young_hero_weapon_quest.canReciveWeapon() then
				send_letter("Die Junghelden-Waffen")
			end
		end

		when button or info begin
			local settings = young_hero_weapon_quest.getWeaponVnums()
			if not settings then notice("Syserr: No Settings aviable!") return end

			local choice_1 = settings[1]
			local choice_2 = settings[2]

			say_title("Die Junghelden-Waffen")
			say("Hier kannst du nun die Junghelden-Waffe auswählen:")

			local s = select(string.format("%s", item_name(choice_1)), string.format("%s", item_name(choice_2)), "Abbrechen")
			if s == 3 then return end

			pc.give_item2(settings[s], 1)
			pc.setf("system", "is_younghero_weapon_aviable", 0)

			if young_hero_weapon_quest.setNextQuestLevel() then
				chat("Du hast die Jungehlden-Waffe erhalten!")
				clear_letter()
			else
				complete_quest()
				clear_letter()
			end
		end
	end

	state __COMPLETE__ begin
	end

	state __FUNCTIONS__ begin
		function canReciveWeapon()
			return pc.getf("system", "is_younghero_weapon_aviable") == 1
		end

		function setNextQuestLevel()
			local sucsess = true

			if young_hero_weapon_quest.getNextQuestLevel() >= 90 then
				sucsess = false
			else
				pc.setf("system", "get_next_younghero_weapon_level", pc.getf("system", "get_next_younghero_weapon_level")+10)
			end

			return sucsess
		end

		function getNextQuestLevel()
			local level = pc.getf("system", "get_next_younghero_weapon_level")

			if level == 0 then 
				level = 1
			end

			return level
		end
		
		function getWeaponVnums()
			local level = young_hero_weapon_quest.getNextQuestLevel()
			local race = pc.get_job()

			local tab = {
				[0] = {
					[1] =  {10, 1000},
					[10] = {11, 1001},
					[20] = {12, 1002},
					[30] = {13, 1003},
					[40] = {14, 1004},
					[50] = {15, 1005},
					[60] = {16, 1006},
					[70] = {17, 1007},
					[80] = {18, 1008},
					[90] = {19, 1009},
				},
				[1] = {
					[1] =  {10, 1000},
					[10] = {11, 1001},
					[20] = {12, 1002},
					[30] = {13, 1003},
					[40] = {14, 1004},
					[50] = {15, 1005},
					[60] = {16, 1006},
					[70] = {17, 1007},
					[80] = {18, 1008},
					[90] = {19, 1009},
				},
				[2] = {
					[1] =  {10, 1000},
					[10] = {11, 1001},
					[20] = {12, 1002},
					[30] = {13, 1003},
					[40] = {14, 1004},
					[50] = {15, 1005},
					[60] = {16, 1006},
					[70] = {17, 1007},
					[80] = {18, 1008},
					[90] = {19, 1009},
				},
				[3] = {
					[1] =  {10, 1000},
					[10] = {11, 1001},
					[20] = {12, 1002},
					[30] = {13, 1003},
					[40] = {14, 1004},
					[50] = {15, 1005},
					[60] = {16, 1006},
					[70] = {17, 1007},
					[80] = {18, 1008},
					[90] = {19, 1009},
				},
			}
			return tab[race][level]
		end
	end
end