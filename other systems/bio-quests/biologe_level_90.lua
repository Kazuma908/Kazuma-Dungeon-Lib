-- NPCs
define QUEST_NPC 20084
define REWARD_NPC 20018

-- Items
define BIO_ITEM_1 30168
define BIO_ITEM_COUNT 50
define PUSH_ITEM 71035
define BIO_SOULSTONE 30227

-- Generals
define MIN_LEVEL 90
define CHANCE 75
define DROP_CHANCE_SOULSTONE 50
define DROPCHANCE 75

quest biologe_level_90 begin
	state run begin
		when login or levelup with pc.get_level() >= MIN_LEVEL  begin
			set_state(stage_quest_start)
		end	
	end
	
	state stage_quest_start begin
		when login or letter begin
			send_letter("Die Forschung des Biologen 8")
			setTarget(QUEST_NPC)
		end

		when button or info begin
			printQuestHeader("Die Forschung des Biologen 8")
			sayQuestText("Der Biologe benötigt ein weiteres Mal deine Hilfe.")

			printQuestInfo()
			say_reward("Sprich mit dem Biologen")
		end
		
		when __TARGET__.target.click or	QUEST_NPC.chat."Die Forschung des Biologen 8" begin
			deleteTarget(QUEST_NPC)

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText(string.format("Hallo %s, hilfst du mir? Ich habe die Forschungen mit den roten Ästen abgeschlossen. Ich möchte, dass du diesmal die Anführer der Gebiete besiegst. Bei ihnen findest du Notizen der Anführer. Hilfst du mir bei meinen Untersuchungen?", pc.get_name()))

			printQuestInfo()
			say(string.format("Ich benötige %d mal ein %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			say("Möchtest du die Aufgabe jetzt beginnen?")
			
			local s = select("Auftrag annehmen", "Abbrechen")
			if s == 2 then return end

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText("Vielen Dank! Du wirst sie bei allen Anführern finden!")

			printQuestInfo()
			say(string.format("Ich benötige %d mal %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			wait()
			
			setupBioQuestCounter()
			set_state(stage_1)
		end
	end

	state stage_1 begin
		when login or enter or letter begin
			send_letter("Auftrag: Notizen der Anführer")
		end

		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Der Biologe gab dir den Auftrag, %d Notizen der Anführer zu sammeln. Du findest sie bei allen Anführern.", BIO_ITEM_COUNT))

			printQuestInfo()
			say_reward(string.format("Sammel alle %d Notizen der Anführer.", BIO_ITEM_COUNT))
			say_reward("Du hast derzeit "..pc.getqf("collectCount").." abgegeben!")
		end

		when kill with biologe_level_90.inBossList(npc.race(), {591, 691, 791, 793,  991, 992, 993, 1091, 1092, 1093, 1304, 1403, 2091, 2191, 2206, 2207 ,2306, 2493, 2494, 5001, 5004, 5161, 5162, 5163}) then begin
			local rand = number(0,99)

			if rand < DROPCHANCE then 
				game.drop_item_with_ownership(BIO_ITEM_1, 1)
			end
		end

		when QUEST_NPC.chat."Auftrag: Notizen der Anführer" with pc.count_item(BIO_ITEM_1) > 0 begin
			local perc = number(0, 99)

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText("Einen Moment bitte.. Ah da ist er sehr gut.. Lass mich schnell mal gucken, ob ich ihn gebrauchen kann..")
			wait()
			
			if pc.count_item(PUSH_ITEM) > 0 then
				printQuestHeader(mob_name(QUEST_NPC))
				sayQuestText("Du trägst das Elixier des Forschers bei dir! Damit kannst du die Qualität des Gegenstands verbessern und somit die Wahrscheinlichkeit steigern, dass die Abgabe erfolgreich ist.")
				say_item_vnum(PUSH_ITEM)

				local s = select("Verwenden", "Abbrechen")
				if s == 2 then return end

				local perc = perc - 25
				pc.remove_item(PUSH_ITEM, 1)
			end
			
			if perc <= CHANCE then
				if getBioQuestCount() < 10 then
					printQuestHeader(mob_name(QUEST_NPC))
					sayQuestText("Hervorragend, damit kann ich sehr gut arbeiten. Bring mir noch welche, damit ich meine Forschungen abschließen kann.")
					say_reward("Du hast derzeit "..pc.getqf("collectCount").." abgegeben!")
					wait()

					updateBioQuestCounter()
				else
					printQuestHeader(mob_name(QUEST_NPC))
					sayQuestText(string.format("Vielen Dank für die %d Äste. Ich benötige jetzt außerdem noch Seelenstein der Anführer. Du findest ihn bei allen Anführern. Er sollte leicht zu finden sein!", BIO_ITEM_COUNT))
					wait()

					setupBioQuestCounter()
					set_state(stage_2)
				end
			else
				printQuestHeader(mob_name(QUEST_NPC))
				sayQuestText("Es tut mir leid, dieses Exemplar kann ich nicht verwenden. Bitte bringe mir weitere!")
			end

			pc.remove_item(BIO_ITEM_1, 1)
		end
	end

	state stage_2 begin
		when letter begin
			send_letter("Auftrag: Der Seelenstein")
		end
		
		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Du sollst als nächstes den %s finden.", item_name(BIO_SOULSTONE)))

			printQuestInfo()
			say_reward("Du findest ihn auch bei den Keaturen im Roten Wald.")
		end

		when kill with biologe_level_90.inBossList(npc.race(), {591, 691, 791, 793,  991, 992, 993, 1091, 1092, 1093, 1304, 1403, 2091, 2191, 2206, 2207 ,2306, 2493, 2494, 5001, 5004, 5161, 5162, 5163}) then begin
			if pc.count_item(BIO_SOULSTONE) < 1 then
				local perc = number(1,100)

				if perc <= DROP_CHANCE_SOULSTONE then 
					game.drop_item_with_ownership(BIO_SOULSTONE, 1)
					setTarget(QUEST_NPC)
				end
			end	
		end

		when __TARGET__.target.click or	QUEST_NPC.chat."Seelenstein der Anführer" begin
			deleteTarget(QUEST_NPC)

			if pc.count_item(BIO_SOULSTONE) > 0 then
				printQuestHeader(mob_name(QUEST_NPC))
				sayQuestText("Dank deiner Hilfe verstehe ich nun die Legende des Seelensteins der Anführer. Du hast hart gekämpft. Sprich mit Baek-Go, er wird dir helfen, deine inneren Kräfte zu steigern.")
				wait()

				pc.remove_item(BIO_SOULSTONE, 1)
				set_state(stage_quest_reward)
			end
		end
	end	

	state stage_quest_reward begin
		when letter begin
			send_letter("Die Belohnung")
			setTarget(REWARD_NPC)
		end

		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Um die Belohnung des Biologen zu erhalten sprich mit %s, er wird dir sie überreichen!", mob_name(REWARD_NPC)))
		end

		when __TARGET__.target.click or REWARD_NPC.chat."Belohnung des Biologen" begin
			deleteTarget(REWARD_NPC)

			printQuestHeader(mob_name(REWARD_NPC))
			sayQuestText("Der Biologe hat dich zu mir geschickt? Ich soll dir deine Belohnung geben? Dann mache ich das doch mal!")

			printQuestInfo("Belohnung:")
			say_reward("Schaden gegen andere Spieler: +8% (Dauerhaft)")
			say_reward("1x Schwarzer Ebenholzkasten")
			wait()
			
			affect.add_collect(apply.ATTBONUS_WARRIOR, 8, 60*60*24*365*60)
			affect.add_collect(apply.ATTBONUS_ASSASSIN, 8, 60*60*24*365*60)
			affect.add_collect(apply.ATTBONUS_SURA, 8, 60*60*24*365*60)
			affect.add_collect(apply.ATTBONUS_SHAMAN, 8, 60*60*24*365*60)
			pc.give_item2(50116, 1)
			clear_letter()
			set_quest_state("biologe_level_92", "run")
			complete_quest()
		end
	end

	state __COMPLETE__ begin
	end
	
	state __FUNCTIONS__ begin
	
		function inBossList(compare, list)
			for i = 1, table.getn(list) do
				if compare == list[i] then return true end
			end
			return false
		end
	
		function getBossSoulStoneVnums()
            return {
                [ BIO_SOULSTONE ] = { 40200, 40201, 40202, 40203 },
            }
		end
	end
end