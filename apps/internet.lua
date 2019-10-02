--SJNOS by MC403. internet.exe (tCzfDtdK)

local tArgs = {...} --internet.exe <USERNAME>

local function start()


if (not term.isColor()) then
	error('This program needs support for colors.')
elseif (tArgs[1] == nil or not fs.exists("SJNOS/users/"..tArgs[1].."/config/.config")) then
    error('Invalid parameters.')
end

os.loadAPI("SJNOS/system/SJNOS/sjn")

if (not os.loadAPI("SJNOS/net/web/sweb")) then
	error("Error while loading SWEB NET API.")
end

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
local WIDTH, HEIGHT = term.getSize()

local function showDialog(head, texts, buttons, enterButton, delay)
	return sjn.showDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, buttons, enterButton, delay)
end
local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
	return sjn.showInputDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
end


local USERNAME = tArgs[1]
local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

local REDNET, REDNETSIDE = sjn.getRednet(true)

local DNS_SERVER = tonumber(sjn.getConfigFileContent("SJNOS/settings/net.set").dns)

local COLOR_INTERNET_TEXT = colors.black
local COLOR_INTERNET_BG = colors.white
local COLOR_INTERNET_TYPE_TEXT = colors.orange
local COLOR_INTERNET_TYPE_BG = colors.gray
local COLOR_INTERNET_ADRESS_TEXT = colors.orange
local COLOR_INTERNET_ADRESS_BG = colors.gray
local COLOR_INTERNET_BUTTON_TEXT = colors.orange
local COLOR_INTERNET_BUTTON_BG = colors.gray

local INTERNET_SURF_STP = 1
local INTERNET_SURF_LOC = 2
local INTERNET_SURF = INTERNET_SURF_STP
local INTERNET_SURF_TEXT = {"STP://","LOC://"}

local adresse = "@HOME"

local website_object = {}

local lastside = {
	["content"] = "",
	["doctype"] = ""
}

local history = {}

local function drawMenu()
	cpos(1,19)
	bcolor(COLOR_INTERNET_ADRESS_BG)
	term.clearLine()
	tcolor(COLOR_INTERNET_TYPE_TEXT)
	bcolor(COLOR_INTERNET_TYPE_BG)
	write(INTERNET_SURF_TEXT[INTERNET_SURF])
	tcolor(COLOR_INTERNET_ADRESS_TEXT)
	bcolor(COLOR_INTERNET_ADRESS_BG)
	write(adresse)
	cpos(42,19)
	tcolor(COLOR_INTERNET_BUTTON_TEXT)
	bcolor(COLOR_INTERNET_BUTTON_BG)
	write("SUBMIT")

	if (#history > 1) then
		cpos(49, 19)
		write("<")
	end

	cpos(51,19)
	write("#")
end

local function clearScreen()
	bcolor(COLOR_INTERNET_BG)
	clear()
	drawMenu()
end

local function drawWebsite()
	clearScreen()
	local result, object = sweb.int(lastside.content, lastside.doctype, USERNAME, DNS_SERVER, INTERNET_SURF, colors.cyan, colors.white)
	if (result) then
		website_object = object
	else
		website_object = {}
	end
	drawMenu()
end

local function draw()
	drawWebsite()
	drawMenu()
end

local function normalWebsite(content, doctype)
	lastside.content = content
	lastside.doctype = doctype
end

local function specialWebsite(link)
	local content = ''
	if (link == 'HOME') then
		content = 'Hello '..USERNAME..'!\n\nWhat do you want to do next?\n<text=Your#Files color=orange link=LOC:>\n<text=Help color=orange link=STP:@HELP>'
	else
		content = 'The page \'@' .. link .. '\' doesn\'t exist (yet).\n\n<text=Home color=orange link=STP:@HOME>'
	end
	normalWebsite(content, 'stp')
end

function infoWebsite(info, para1, para2)
	para1 = para1 or '%'
	para2 = para2 or '%'

	local content = info
	if (info == "LOC_URL_NOT_FOUND") then
		content = "The File\n<text="..para1.." color=orange>\ndoes not exist!"
	elseif (info == "STP_DNS_NO_RESULT") then
		content = "The Server <text="..para1.." color=orange> is not registered on your DNS or there is some sort of back-end problem."
	elseif (info == "STP_SERVER_NO_ANSWER") then
		content = "The Server\n<text="..para1.."#("..para2..") color=orange> \ndoes not respond."
	end

	normalWebsite(content, "stp")
end

local function connect()
	if (INTERNET_SURF == INTERNET_SURF_STP) then
		local server = adresse

		if (string.find(adresse, '@')==1) then
			local link = string.sub(adresse, 2) .. ''
			specialWebsite(link)
			return
		end

		local path = ""
		local p1, p2 = string.find(adresse, "/")

		if (p1 ~= nil) then
			server = string.sub(adresse, 1, p1 - 1)
			path = string.sub(adresse, p1 + 1)
		end

		rednet.send(DNS_SERVER, "~SJN@SWEBCLIENT:GETIDOF#" .. server)

		local time = 1
		local id, target_msg
		local timer = os.startTimer(time)
		local mini = os.startTimer(0)

		local pos = 1
		local dist = 52

		cpos(1, 18)
		bcolor(colors.lime)

		while true do
			local event, inner_id, inner_msg = os.pullEvent()
			if (event == "rednet_message") then
				id = inner_id
				target_msg = inner_msg
				break
			elseif (event == "timer") then
				if (inner_id == timer) then
					break
				elseif (inner_id == mini) then
					mini = os.startTimer(0)
					local left_way = dist - pos
					local t = 2.5 / time
					for i=1, math.floor(t) do
						write(" ")
						pos = pos + 1
					end
				end
			end
		end

		local num = 4
		local runs = math.floor((dist-pos)/num)
		for i=1, runs do
			write(string.rep(" ", num))
			pos = pos + num
			sleep(time / 300)
		end

		for i=0,dist-pos do
			write(" ")
		end

		if (id ~= nil and id == DNS_SERVER) then
			local p1, p2 = string.find(target_msg, "~SJN@SWEBDNS:IDIS#")

			if (p1 and #target_msg >= p2 + 1) then
				local targetID = tonumber(string.sub(target_msg, p2 + 1))

				rednet.send(targetID, "~SJN@SWEBCLIENT:GETCONTENTFORPATH#" .. path)

				local id2, response = rednet.receive(2)

				if (id2 == targetID) then
					local msg = response
					local data = adresse

					if (string.find(response, "#") ~= nil) then
						data = string.sub(response, 1, string.find(response, "#")-1)..""
						msg = string.sub(response, string.find(response, "#")+1)
					end

					local _, pos = string.find(data, "doctype=")
					local doctype = "txt"
					if (pos ~= nil) then
						doctype = string.sub(data, pos+1)
					end

					normalWebsite(msg, doctype)
				else
					infoWebsite("STP_SERVER_NO_ANSWER", server, targetID)
				end
			else
				infoWebsite("STP_DNS_NO_RESULT", server)
			end
		else
			infoWebsite("STP_DNS_NO_RESULT", server)
		end

	elseif (INTERNET_SURF == INTERNET_SURF_LOC) then
		-- Local Side
		if (string.find(adresse, '%.%.')) then
			infoWebsite('Please do not use two dots (\'..\')!')
			return
		end

		local path = "SJNOS/users/"..USERNAME.."/home/"..adresse

		if (fs.exists(path)) then
			if (fs.isDir(path)) then
				local list = fs.list(path)
				local content = "Files in <text="..path.." color=orange>:\n"

				local up = adresse .. ''
				if (adresse ~= '') then
					local nonsense = string.reverse(adresse)
					local p = string.find(nonsense, "/")
					if (p) then
						local sense = string.reverse(string.sub(nonsense, p + 1))
						up = sense
					else
						up = '+' --Ich wollte nicht weiter nachdenken...
					end
				end

				if (up == '') then
					content = content .. "<text=[=] color=black bg=gray>\n"
				else
					if (up == '+') then
						up = ''
					end

					content = content .. "<text=[=] color=lightGray bg=gray> <text=.. color=cyan link=LOC:"..up..">\n"
				end

				for i=1,#list do
					local dir = fs.isDir(path .. "/" .. list[i])
					local type_text = "-~-"
					local color = colors.lime
					if (dir) then
						type_text = "[=]"
						color = colors.white
					end

					local elementPath = list[i]
					if (adresse ~= '') then
						elementPath = adresse .. '/' .. list[i]
					end
					content = content .. "<text="..type_text.. " color="..color.." bg=gray> <text=" .. list[i] .. " color=cyan link=LOC:"..elementPath..">\n"
				end
				normalWebsite(content, "stp")
			else
				local content = sjn.getFileAll(path) or ''
				local place, name, ending = sjn.getPathContent(path)

				normalWebsite(content, ending or 'txt')
			end
		else
			infoWebsite("LOC_URL_NOT_FOUND", path)
		end
	end
end


local function internet_INPUT_SUBMIT(h)
	if (h == true) then
		table.insert(history, {
			["surf"] = INTERNET_SURF,
			["url"] = adresse
		})
	end

	connect()
	draw()
end
local function internet_INPUT_ADDRESS()
	cpos(7,19)
	tcolor(COLOR_INTERNET_ADRESS_TEXT)
	bcolor(COLOR_INTERNET_ADRESS_BG)
	write("                                  ")
	cpos(7,19)
	local ad = read()
	if (string.find(ad," ") == nil and string.find(ad,"~") == nil and string.find(ad, "%.%.") == nil) then
		if ((INTERNET_SURF == INTERNET_SURF_STP and ad ~= "")
			or (INTERNET_SURF == INTERNET_SURF_LOC)) then
			adresse = ad
		end
	end

	clearScreen()
	internet_INPUT_SUBMIT(true)
end
local function internet_INPUT_HISTORY_BACK()
	if (#history > 1) then
		INTERNET_SURF = history[#history-1].surf
		adresse = history[#history-1].url
		history[#history] = nil
		internet_INPUT_SUBMIT(false)
	end
end


local internet = true

internet_INPUT_SUBMIT(true)

while internet do
	draw()
	local event, side, channel, id, msg, dis = os.pullEventRaw()
	local btn = side local x = channel local y = id

	if (event=="mouse_click") then
		if (y==19) then
			--MENU
			if (x<=6) then
				--STP:// LOC://
				tcolor(COLOR_INTERNET_TYPE_BG)
				bcolor(COLOR_INTERNET_TYPE_TEXT)
				local text1, text2, i, j = "STP://", "LOC://", INTERNET_SURF_STP, INTERNET_SURF_LOC
				if (INTERNET_SURF == INTERNET_SURF_LOC) then
					text1, text2, i, j = "LOC://", "STP://", INTERNET_SURF_LOC, INTERNET_SURF_STP
				end
				cpos(1,18)
				write(text1)
				cpos(1,19)
				write(text2)

				while true do
					local event, btn, x, y = os.pullEventRaw()
					if (event=="mouse_click") then
						if (x<=6 and y==18) then
							INTERNET_SURF = i
						elseif (x<=6 and y==19) then
							INTERNET_SURF = j
						end
						break
					end
				end

				clearScreen()
				connect()
				draw()
			elseif (x>=7 and x<=40) then
				--Adresse
				internet_INPUT_ADDRESS()
			elseif (x >= 42 and x <= 47) then
				--Submit
				internet_INPUT_SUBMIT(true)
			elseif (x == 49) then
				--<
				internet_INPUT_HISTORY_BACK()
			elseif (x == 51) then
				--#
				internet = false
				draw()
			end
		else
			local links = website_object.link
			for i=1,#links do
				local link = links[i]
				if (x >= link.x and x < link.x + link.width and y == link.y) then
					local new_adresse = adresse
					local link_type = ""

					cpos(1,1)
					if (link.target == nil) then

					elseif (string.find(link.target, "LOC:")) then
						local target = string.sub(link.target, 5)..""
						INTERNET_SURF = INTERNET_SURF_LOC
						new_adresse = target

						link_type = "local"
					elseif (string.find(link.target, "INT:") and INTERNET_SURF == INTERNET_SURF_STP) then
						local target = string.sub(link.target, 5)
						local pos = string.find(adresse, "/")
						local server = adresse
						if (pos ~= nil) then
							server = string.sub(adresse, 1, pos - 1)
						end
						new_adresse = server .. "/" .. target

						link_type = "internal"
					elseif (string.find(link.target, "STP:")) then
						local target = string.sub(link.target, 5)
						new_adresse = target

						link_type = "global"
					elseif (string.find(link.target, "~/")) then
						local target = string.sub(link.target, 3)..""
						local reverse = string.reverse(adresse)..""
						local pos = string.find(reverse, "/")
						if (pos ~= nil) then
							local adresse_reverse = string.sub(reverse, pos + 1)..""
							if (target == "..") then
								new_adresse = string.reverse(adresse_reverse)
							else
								new_adresse = string.reverse(adresse_reverse) .. "/" .. target
							end
						else
							if (adresse == "") then
								new_adresse = target
							else
								new_adresse = adresse .. "/" .. target
							end
						end

						link_type = "relative"
					end

					adresse = new_adresse .. ''

					internet_INPUT_SUBMIT(true)
				end
			end
		end
	elseif (event == "key") then
		if (btn == keys.enter) then
			--Submit
			internet_INPUT_SUBMIT()
		elseif (btn == keys.tab) then
			--Adresse
			internet_INPUT_ADDRESS()
		elseif (btn == keys.leftCtrl) then
			if (INTERNET_SURF == INTERNET_SURF_LOC) then
				INTERNET_SURF = INTERNET_SURF_STP
			else
				INTERNET_SURF = INTERNET_SURF_LOC
			end
		end
	end
end


return true
end

sjn.program(start)
os.unloadAPI("SJNOS/system/SJNOS/sjn")
