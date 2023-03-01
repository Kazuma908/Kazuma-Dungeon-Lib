-- NPCs
define QUEST_NPC 20084

-- Items
define BIO_ITEM_1 30047
define BIO_ITEM_COUNT 15
define PUSH_ITEM 71035
define BIO_SOULSTONE 30220

-- Generals
define MIN_LEVEL 40
define CHANCE 50
define DROP_CHANCE_SOULSTONE 5

quest biologe_level_40 begin
	state run begin
		when login or levelup with pc.get_level() >= MIN_LEVEL  begin
			set_state(stage_quest_start)
		end	
	end
	
	state stage_quest_start begin
		when login or letter begin
			send_letter("Die Forschung des Biologen 2")
			setTarget(QUEST_NPC)
		end

		when button or info begin
			printQuestHeader("Die Forschung des Biologen 2")
			sayQuestText("Der Biologe benötigt erneut deine Hilfe.")

			printQuestInfo()
			say_reward("Sprich mit dem Biologen")
		end
		
		when __TARGET__.target.click or	QUEST_NPC.chat."Die Forschung des Biologen 2" begin
			deleteTarget(QUEST_NPC)

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText(string.format("Hallo %s, hilfst du mir? Ich habe gerade meine Untersuchungen zum Orkzahn und den Seelenstein fertig.. Jetzt gibt es neue Dinge die ich studieren will..", pc.get_name()))

			printQuestInfo()
			say(string.format("Ich benötige %d mal eine %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			say("Möchtest du den Auftrag jetzt beginnen?")
			
			local s = select("Auftrag annehmen", "Abbrechen")
			if s == 2 then return end

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText("Vielen Dank! Du wirst sie den Esoterischen abnehmen müssen. Du findest sie in dem Hwang Tempel!")

			printQuestInfo()
			say(string.format("Ich benötige %d mal eine %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			wait()
			
			setupBioQuestCounter()
			set_state(stage_1)
		end
	end

	state stage_1 begin
		when login or enter or letter begin
			send_letter("Auftrag: Fluchsammlung")
		end

		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Der Biologe gab dir den Auftrag, %d Fluchsammlungen zu sammeln. Du findest sie bei den Esoterischen im Tal von Seungryong.", BIO_ITEM_COUNT))

			printQuestInfo()
			say_reward(string.format("Sammel alle %d Fluchsammlungen.", BIO_ITEM_COUNT))
			say_reward("Du hast derzeit "..pc.getqf("collectCount").." abgegeben!")
		end

		when QUEST_NPC.chat."Auftrag: Fluchsammlung" with pc.count_item(BIO_ITEM_1) > 0 begin
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
					sayQuestText(string.format("Vielen Dank für die %d Fluchsammlungen. Ich benötige jetzt außerdem noch den Tempelseelenstein. Der Tempelseelenstein enthält die gesammte Kraft des Tempels.", BIO_ITEM_COUNT))
					wait()

					setupBioQuestCounter()
					set_state(stage_2)
				end
			else
				printQuestHeader(mob_name(QUEST_NPC))
				sayQuestText("Es tut mir leid, dieses Exemplar kann ich nicht verwenden. Bitte bringe mir ein Neues!")
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
			say_reward("Du findest ihn bei allen Esoterischen im Hwang Tempel.")
		end

		when 731.kill or 732.kill or 733.kill or 734.kill or 735.kill or 736.kill or 737.kill begin
			if pc.count_item(BIO_SOULSTONE) < 1 then
				local perc = number(1,100)

				if perc <= DROP_CHANCE_SOULSTONE then 
					game.drop_item_with_ownership(BIO_SOULSTONE, 1)
					setTarget(QUEST_NPC)
				end
			end	
		end

		when __TARGET__.target.click or	QUEST_NPC.chat."Tempelseelenstein" begin
			deleteTarget(QUEST_NPC)

			if pc.count_item(BIO_SOULSTONE) > 0 then
				printQuestHeader(mob_name(QUEST_NPC))
				sayQuestText("Dank deiner Hilfe verstehe ich nun die Legende um Tempelseelenstein. Du hast hart gekämpft. Sprich mit Baek-Go, er wird dir helfen, deine inneren Kräfte zu steigern.")
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
			say_reward("Angriffsgeschwindigkeit +5 (Dauerhaft)")
			say_reward("1x Prunk Ebenholzkiste")
			wait()

			affect.add_collect(apply.ATT_SPEED, 5, 60*60*24*365*60)
			pc.give_item2(50110, 1)
			clear_letter()
			set_quest_state("biologe_level_50", "run")
			complete_quest()
		end
	end

	state __COMPLETE__ begin
	end
end