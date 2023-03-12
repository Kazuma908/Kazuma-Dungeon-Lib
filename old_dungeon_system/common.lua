colors_data = {
	['green'] = {0,190,0},
	['light green'] = {0,255,0},
	['dark green'] = {0,110,0},
	['semi light green'] = {144,238,144},
	['teal'] = {102,205,170},
	['red'] = {240,0,0},
	['semi light red'] = {255,69,51},
	['rose'] = {255,64,160},
	['dark rose'] = {255,0,128},
	['light rose'] = {255,182,193},
	['light orange'] = {255,127,80},
	['orange'] = {255,130,0},    
	['dark orange'] = {255,90,0},                
	['semi dark violet'] = {255,0,255},    
	['violet'] = {224,129,255},
	['dark violet'] = {148,0,148},
	['light violet'] = {200,162,200},
	['brown'] = {161,63,0},
	['dark brown'] = {120,66,0},
	['light brown'] = {200,164,115},
	['yellow'] = {255,255,53},
	['light yellow'] = {255,255,128}, 
	['gold'] = {255,191,24},
	['blue'] = {0,0,250},
	['dark blue'] = {0,0,150},
	['cyan'] = {128,255,255},
	['light cyan'] = {180,255,255},
	['turquoise'] = {0,255,255},
	['white'] = {255,255,225},
	['gray'] = {128,128,128},
	['black'] = {0,0,0},
	['default'] = {196,196,196}
}

function modulo(v1, v2)
	return v1-(math.floor(v1/v2)*v2)
end

function disp_time(t)
	local days = (t / 86400) or 0
	local hours = (modulo(t, 86400) / 3600) or 0
	local minutes = (modulo(t, 3600) / 60) or 0
	local seconds = (modulo(t, 60)) or 0

	return math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds)
end

function tableToEnumeratedString(strTable)
	local lastElementIndex = table.getn(strTable)
	local lastElement = strTable[lastElementIndex]
	if not lastElement then return "" end	

	local str = ""
	if table.getn(strTable) > 1 then
		table.remove(strTable, lastElementIndex)
		str = table.concat(strTable, ", ")
		str = str .. " und " .. lastElement
	else
		str = lastElement
	end
	
	return trim(str)
end

function second_to_hms(t)
	local days, hours, minutes, seconds = disp_time(t)
	local strTable = {}

	if days > 0 then
		table.insert(strTable, string.format("%d Tage", days))
	end

	if hours > 0 then
		table.insert(strTable, string.format("%d Stunden", hours))
	end

	if minutes > 0 then
		table.insert(strTable, string.format("%d Minuten", minutes))
	end

	if seconds > 0
		then table.insert(strTable, string.format("%d Sekunden", seconds))
	end

	return tableToEnumeratedString(strTable)
end

function setTarget(vnum)
	local vid = find_npc_by_vnum(vnum)
	if not vid then return end

	target.vid(tostring(vnum), vid, mob_name(vnum))
end

function deleteTarget(vnum)
	target.delete(tostring(vnum))
end

function clearTarget(vnum)
	target.delete(tostring(vnum))
end

function printEnterLine()
	say2("________________________________________________")
	say()
end

function printQuestHeader(title)
	local title = title or getGlobalText("information")

	center_title_color("gold", title, true)
	printEnterLine()
end

function printQuestInfo(text)
	local text = text or getGlobalText("task")

	center_color("semi light green", text, true)
	printEnterLine()
end

function center_title(title, val)
	say_title("[TEXT_HORIZONTAL_ALIGN_CENTER]" .. title .. "[/TEXT_HORIZONTAL_ALIGN_CENTER]")

	if not val then
		say()
	end
end

function center_title_color(color, text, val)
    local rgb = rawget(colors_data, color)
    raw_script(color256(rgb[1],rgb[2],rgb[3]))

	text_c = color256(rgb[1], rgb[2], rgb[3]) .. text .. color256(colors_data.default[1], colors_data.default[2], colors_data.default[3])

	say_title("[TEXT_HORIZONTAL_ALIGN_CENTER]" .. text_c .. "[/TEXT_HORIZONTAL_ALIGN_CENTER]")

	if not val then
		say()
	end
end

function center(text, val)
	say2("[TEXT_HORIZONTAL_ALIGN_CENTER]" .. text .. "[/TEXT_HORIZONTAL_ALIGN_CENTER]")

	if not val then
		say()
	end
end

function center_color(color, text, val)
    local rgb = rawget(colors_data, color)
    raw_script(color256(rgb[1],rgb[2],rgb[3]))

	text_c = color256(rgb[1], rgb[2], rgb[3]) .. text .. color256(colors_data.default[1], colors_data.default[2], colors_data.default[3])

	say2("[TEXT_HORIZONTAL_ALIGN_CENTER]" .. text_c .. "[/TEXT_HORIZONTAL_ALIGN_CENTER]")

	if not val then
		say()
	end
end

function say2(str,dx) 
    local maxl,actl,pat = dx or 50,0,'(.-)(%[.-%])()' 
    local result,nb,lastPos,outp = {},0,0,'' 
    local function bere(stx) 
        for le in string.gfind(stx,'((%S+)%s*)') do  
            if actl + string.len(le) > maxl then  
                outp = outp..'[ENTER]'  
                actl = 0  
            end  
            outp = outp..le  
            actl = actl + string.len(le)  
        end  
    end 
    for part, dos,pos in string.gfind(str, pat) do  
        if part ~= '' then  
            bere(part) 
        end 
        outp = outp..dos  
        lastPos = pos  
    end  
    bere(string.sub(str,lastPos)) 
    say(outp) 
end 

function contains(tbl, val)
	for i = 1, table.getn(tbl) do
		if tbl[i] == val then 
			return true
		end
	end
	
	return false
end

function choice(tab)
	local rand = number(1, table.getn(tab))
	
	return tab[rand]
end

function setToday()
	pc.setf("sys", "today", os.date("%d"))
end

function getToday()
	return pc.getf("sys", "today")
end

function isToday()
	return tonumber(os.date("%d")) == getToday()
end

function getHour()
	return os.date("%H")
end

-- @Syreldar
table_shuffle = function(table_ex)
    local rand = 0

    for i = table.getn(table_ex), 2, -1 do
        rand = math.random(i);
        table_ex[i], table_ex[rand] = table_ex[rand], table_ex[i]
    end

    return table_ex;
end
