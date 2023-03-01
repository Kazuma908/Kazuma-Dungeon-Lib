-- NPCs
define QUEST_NPC 20084

-- Items
define BIO_ITEM_1 30006
define BIO_ITEM_COUNT 10
define PUSH_ITEM 71035
define BIO_SOULSTONE 30220

-- Generals
define MIN_LEVEL 30
define CHANCE 50
define DROPCHANCE 2
define DROP_CHANCE_SOULSTONE 5

quest biologe_level_30 begin
	state start begin
		when login or levelup with pc.get_level() >= MIN_LEVEL  begin
			set_state(stage_quest_start)
		end	
	end
	
	state stage_quest_start begin
		when login or letter begin
			send_letter("Die Forschung des Biologen")
			setTarget(QUEST_NPC)
		end

		when button or info begin
			printQuestHeader("Die Forschung des Biologen")
			sayQuestText("Der Biologe benötigt deine Hilfe.")

			printQuestInfo()
			say_reward("Sprich mit dem Biologen")
		end
		
		when __TARGET__.target.click or	QUEST_NPC.chat."Die Forschung des Biologen" begin
			deleteTarget(QUEST_NPC)

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText(string.format("Hallo %s, hilfst du mir? Ich studiere zahlreiches aus der Pflanzenwelt. Zurzeit arbeite ich an einer Legende, die besagt, dass ein Orkzahn härter als Diamant sein soll. Hilfst du mir bei meinen Untersuchungen?", pc.get_name()))

			printQuestInfo()
			say(string.format("Ich benötige %d mal einen %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			say("Möchtest du den Auftrag jetzt beginnen?")
			
			local s = select("Auftrag annehmen", "Abbrechen")
			if s == 2 then return end

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText("Vielen Dank! Du wirst sie den Orks abnehmen müssen. Du findest sie in dem Tal von Seungryong")

			printQuestInfo()
			say(string.format("Ich benötige %d mal einen %s.", BIO_ITEM_COUNT, item_name(BIO_ITEM_1)))
			wait()
			
			setupBioQuestCounter()
			set_state(stage_1)
		end
	end

	state stage_1 begin
		when login or enter or letter begin
			send_letter("Auftrag: Orkzähne")
		end

		when kill with inDropList(npc.race(), {101, 102}) then begin
			dropBioItem(BIO_ITEM_1, BIO_ITEM_COUNT, DROPCHANCE)
		end

		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Der Biologe gab dir den Auftrag, %d Orkzähne zu sammeln. Du findest sie bei den Orks im Tal von Seungryong.", BIO_ITEM_COUNT))

			printQuestInfo()
			say_reward(string.format("Sammel alle %d Orkzähne.", BIO_ITEM_COUNT))
			say_reward(string.format("Du hast derzeit %s abgegeben!", getBioQuestCount()))

			if canProcessBioQuest(BIO_ITEM_1) then
				local s = select(string.format("5s abgeben", item_name(BIO_ITEM_1)), "Abbrechen")
				if s == 2 then return end

				if number(0, 99) <= CHANCE then
					if getBioQuestCount() < 10 then
						printQuestHeader(mob_name(QUEST_NPC))
						sayQuestText("Hervorragend, damit kann ich sehr gut arbeiten. Bring mir noch welche, damit ich meine Forschungen abschließen kann.")
						say_reward(string.format("Du hast derzeit %s abgegeben!", getBioQuestCount()+1))
						wait()

						updateBioQuestCounter()
					else
						printQuestHeader(mob_name(QUEST_NPC))
						sayQuestText(string.format("Vielen Dank für die %d Orkzähne. Ich benötige jetzt außerdem noch Jinunggyis Seelenstein. Jinunggyi ist einer der antiken Herrscher von Jinno. Die stozlen Orks tragen ihn bei sich. In seiner letzten Amtszeit hat er seine Seelensteine an sie verteilt.", BIO_ITEM_COUNT))
						wait()

						setupBioQuestCounter()
						clear_letter()
						set_state(stage_2)
					end
				else
					printQuestHeader(mob_name(QUEST_NPC))
					sayQuestText("Es tut mir leid, dieses Exemplar kann ich nicht verwenden. Bitte bringe mir weitere!")
				end

				pc.remove_item(BIO_ITEM_1, 1)
			end
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
			say_reward("Du findest ihn bei allen Stolzen Orks.")
			
			local s = select("Seelenstein abgeben", "Abbrechen")
			if s == 2 then return end
			
			if pc.count_item(BIO_SOULSTONE) > 0 then
				printQuestHeader()
				sayQuestText(string.format("Dank deiner Hilfe verstehe ich nun die Legende um %s. Du hast hart gekämpft. Sprich mit %s, er wird dir helfen, deine inneren Kräfte zu steigern.", item_name(BIO_SOULSTONE), mob_name(QUEST_NPC)))
				wait()

				pc.remove_item(BIO_SOULSTONE, 1)
				clear_letter()
				set_state(stage_quest_reward)
			else
				printQuestHeader()
				sayQuestText(string.format("Du hast den %s nicht dabei!", item_name(BIO_SOULSTONE)))
			end
		end

		when 631.kill or 632.kill or 633.kill or 634.kill or 635.kill begin
			dropBioItem(BIO_SOULSTONE, 1, DROP_CHANCE_SOULSTONE)
		end
	end	

	state stage_quest_reward begin
		when letter begin
			send_letter("Die Belohnung")
			setTarget(QUEST_NPC)
		end

		when button or info begin
			printQuestHeader()
			sayQuestText(string.format("Um die Belohnung des Biologen zu erhalten sprich mit %s, er wird dir sie überreichen!", mob_name(QUEST_NPC)))
		end

		when __TARGET__.target.click or QUEST_NPC.chat."Belohnung des Biologen" begin
			deleteTarget(QUEST_NPC)

			printQuestHeader(mob_name(QUEST_NPC))
			sayQuestText("Der Biologe hat dich zu mir geschickt? Ich soll dir deine Belohnung geben? Dann mache ich das doch mal!")

			printQuestInfo("Belohnung:")
			say_reward("Bewegungsgeschwindigkeit +10 (Dauerhaft)")
			wait()

			affect.add_collect(apply.MOV_SPEED, 10, 60*60*24*365*60)
			clear_letter()
			set_quest_state("biologe_level_40", "run")
			complete_quest()
		end
	end

	state __COMPLETE__ begin
	end
end