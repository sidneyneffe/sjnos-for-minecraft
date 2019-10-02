--SJNOS by MC403. rednet.sys (pQbhxiMi)

local w, h = term.getSize()

local tArgs = {...}

local COLOR_TEXT = colors.cyan
local COLOR_BG = colors.white
local COLOR_HEAD_TEXT = colors.orange
local COLOR_HEAD_BG = colors.cyan
local COLOR_SIDE_TEXT = colors.cyan
local COLOR_SIDE_BG = colors.lightGray
local COLOR_SIDE_SEL_TEXT = colors.white
local COLOR_SIDE_SEL_BG = colors.orange

local function start()
	if (term.isColor()) then
		local function cpos(x,y) term.setCursorPos(x,y) end
		local function clear() term.clear() end
		local function tcolor(c) term.setTextColor(c) end
		local function bcolor(c) term.setBackgroundColor(c) end
		local function getTime() local a = textutils.formatTime(os.time(),true) if #a==4 then a = "0"..a end return a end
		
		tcolor(COLOR_TEXT)
		bcolor(COLOR_BG)
		clear()

		local USERNAME = tArgs[1]
		f = fs.open("SJNOS/users/"..USERNAME.."/config/.config","r")
		f.readLine()
		f.readLine()
		f.readLine()
		local USERRANK = f.readLine()
		USERRANK = string.sub(USERRANK,string.find(USERRANK,"=")+1)

		local REDNET = false
		local REDNETSIDE = "-"
		local sides = {"left","right","top","bottom","front","back"}
		for i=1,6 do
			if peripheral.isPresent(sides[i]) then
				if peripheral.getType(sides[i])=="modem" then
					rednet.open(sides[i])
					REDNETSIDE = sides[i]
					REDNET = true
					break
				end
			end
		end


		local receiver = "all"
		local messages = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}

		local function drawTopBar()
			bcolor(COLOR_BG)
			clear()
			cpos(1,1)
			bcolor(COLOR_HEAD_BG)
			tcolor(COLOR_HEAD_TEXT)
			term.clearLine()
			cpos(2,1)
			write("SJNOS")
			cpos(46,1)
			write(textutils.formatTime(os.time(),true))
			tcolor(colors.black)
			bcolor(colors.red)
			cpos(51, 1)
			write("X")
			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
		end

		local function drawMain()
			cpos(2, 3)
			write("Status:   ")
			if (REDNET) then
				tcolor(colors.lime)
				write("online")
			else
				tcolor(colors.red)
				write("offline")
			end
			cpos(2, 4)
			tcolor(COLOR_TEXT)
			write("Side:     " .. REDNETSIDE)

			cpos(2, 7)
			write("ID:       " .. os.getComputerID())

			if (REDNET) then
				cpos(2, 5)
				tcolor(COLOR_TEXT)
				bcolor(COLOR_BG)
				write("Receiver: ")
				tcolor(colors.cyan)
				bcolor(colors.orange)
				cpos(12, 5)
				write(" " .. receiver .. " ")

				bcolor(colors.gray)
				for y=2, 19 do
					if (y == 19) then
						bcolor(colors.lightGray)
					end
					cpos(25, y)
					for x=25,51 do
						write(" ")
					end
				end

				for i=1,#messages do
					if (messages[i].time == nil) then
						break
					end

					cpos(25, 19 - i)
					tcolor(colors.lightGray)
					bcolor(colors.gray)
					write("" .. messages[i].time .. "")

					cpos(31, 19-i)
					write(messages[i].person .. ">")

					cpos(37, 19-i)
					write(messages[i].message)
				end

				tcolor(colors.gray)
				bcolor(colors.lightGray)
				cpos(25, 19)
				write(" > ")
			end
		end

		local function draw()
			drawTopBar()
			drawMain()
		end

		draw()
		
		local active = true

		while (active) do
			local event, btn, x, y, p1, p2 = os.pullEventRaw()
			if (event == "mouse_click") then
				if (x == 51 and y == 1) then
					--Close
					active = false
				elseif (x >= 12 and x <= 14 + #receiver and y == 5 and REDNET) then
					tcolor(colors.cyan)
					bcolor(colors.orange)
					cpos(12, 5)
					write("             ")
					cpos(12, 5)
					write(" ")
					local input = read()
					if (input == "all" or tonumber(input) ~= nil) then
						receiver = input
					end
				elseif (x >= 25 and y == 19 and REDNET) then
					cpos(28, 19)
					tcolor(colors.gray)
					bcolor(colors.lightGray)
					local input = read()

					if (input ~= "") then
						if (receiver == "all") then
							rednet.broadcast(input)
						else
							local r = tonumber(receiver)
							rednet.send(r, input)
						end

						local messages_copy = {}
						for i=1, #messages do
							messages_copy[i] = messages[i]
						end


						for i=1,#messages_copy do
							if (i == #messages_copy) then
								break
							end
							messages[i + 1] = messages_copy[i]
						end

						messages[1] = {
							["time"] = getTime(),
							["person"] = "Me!",
							["message"] = input
						}
						sleep(0.05)
					end
				end
			elseif (event == "rednet_message") then
				local sender, msg, dis = btn, x, y

				local messages_copy = {}
				for i=1, #messages do
					messages_copy[i] = messages[i]
				end
				
				for i=1,#messages_copy do
					if (i == #messages_copy) then
						break
					end
					messages[i + 1] = messages_copy[i]
				end


				messages[1] = {
					["time"] = getTime(),
					["person"] = tostring(sender),
					["message"] = msg
				}
			elseif (event == "key") then
				if (btn == 28) then
					cpos(28, 19)
					tcolor(colors.gray)
					bcolor(colors.lightGray)
					local input = read()

					if (input == "/clear") then
						messages = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
					elseif (input ~= "") then
						if (receiver == "all") then
							rednet.broadcast(input)
						else
							local r = tonumber(receiver)
							rednet.send(r, input)
						end

						local messages_copy = {}
						for i=1, #messages do
							messages_copy[i] = messages[i]
						end


						for i=1,#messages_copy do
							if (i == #messages_copy) then
								break
							end
							messages[i + 1] = messages_copy[i]
						end

						messages[1] = {
							["time"] = getTime(),
							["person"] = "Me!",
							["message"] = input
						}
						sleep(0.05)
					end
				end
			end
			draw()
		end

	end
	return true
end

local ok, err = pcall(start)
if not ok then
	local function draw()f = fs.open(".errimg","w") f.writeLine("000000000000000000000000010000000000000000000000000") local w,h = term.getSize()
	f.writeLine("000000000000000000000000111000000000000000000000000") f.writeLine("0000000000000000000000011f1100000000000000000000000")
	f.writeLine("0000000000000000000000111f1110000000000000000000000") f.writeLine("0000000000000000000001111f1111000000000000000000000")
	f.writeLine("000000000000000000001111111111100000000000000000000") f.writeLine("0000000000000000000111111f1111110000000000000000000")
	f.writeLine("000000000000000000111111111111111000000000000000000") f.close() term.setBackgroundColor(colors.white) term.setTextColor(colors.cyan)
	term.clear() img = paintutils.loadImage(".errimg") paintutils.drawImage(img,1,3) term.setBackgroundColor(colors.white) term.setCursorPos(1,1)
	write("SJNOS ERROR") term.setCursorPos(47,1) write(textutils.formatTime(os.time(),true)) term.setTextColor(colors.black) fs.delete(".errimg")
	term.setCursorPos((w-string.len("Oh No! Something went horribly wrong! :("))/2,12) write("Oh No! Something went horribly wrong :(")
	term.setTextColor(colors.red) local error = {err} if #err > 40 then error[1] = string.sub(err,0,39) error[2] = string.sub(err,40) term.setCursorPos(1,1)
	end for i=1,#error do term.setCursorPos((w-string.len(error[i]))/2,13+i) write(error[i]) end term.setBackgroundColor(colors.orange)
	term.setTextColor(colors.black) startcoos = 17 term.setCursorPos(startcoos,18) write("Reboot") term.setCursorPos(startcoos+7,18) write("Edit")
	term.setCursorPos(startcoos+12,18) write("Exit") end draw() local finished = false while not finished do local event, btn, x, y = os.pullEvent()
	if event=="mouse_click" and btn==1 and y==18 then if x>=startcoos and x<=startcoos+6 then finished = true os.reboot()
	elseif x>=startcoos+8 and x<=startcoos+11 then shell.run("edit",shell.getRunningProgram()) draw() elseif x>=startcoos+13 and x<=startcoos+16 then
	finished = true term.setBackgroundColor(colors.white) term.setTextColor(colors.cyan) term.clear() term.setCursorPos(1,1) shell.run("startup") end end end
end