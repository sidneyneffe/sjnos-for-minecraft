--SJNOS by MC403. peripherals.sys (46bGWX3t)

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
	if (not term.isColor()) then
		return true
	elseif (tArgs[1] == nil) then
		error("Invalid Parapeters.")
	end

	os.loadAPI("SJNOS/system/SJNOS/sjn")

	local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
	local width, height = term.getSize()

	local function showDialog(head, texts, buttons, delay, enterButton)
		return sjn.showDialog(head, texts, colors.orange, colors.gray,
			colors.gray, colors.orange, buttons, enterButton, delay)
	end

	local USERNAME = tArgs[1]
	local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

	local sides = {"left", "right", "top", "bottom", "front", "back"}
	local sides_display = {"Left","Right","Top","Bottom","Front","Back"}

	local P_DATA

	local PRINTER_DATA = {
		["printer"] = nil,
		["input"] = {"","","","","","","","","","","","","","","","","","",""}
	}

	local function refresh()
		P_DATA = {
			[1] = sjn.getPeripheralType(sides[1], "None", true),
			[2] = sjn.getPeripheralType(sides[2], "None", true),
			[3] = sjn.getPeripheralType(sides[3], "None", true),
			[4] = sjn.getPeripheralType(sides[4], "None", true),
			[5] = sjn.getPeripheralType(sides[5], "None", true),
			[6] = sjn.getPeripheralType(sides[6], "None", true),
		}
	end

	refresh()


	local function drawTopBar()
		bcolor(COLOR_BG)
		clear()
		cpos(1,1)
		bcolor(COLOR_HEAD_BG)
		tcolor(COLOR_HEAD_TEXT)
		term.clearLine()
		write(" Peripherals")
		cpos(45,1)
		write(getTime())
		cpos(51,1)
		tcolor(colors.black)
		bcolor(colors.red)
		write("X")
	end

	local selected = 1

	local function drawSideBar()
		for i=1,19 do
			if (i == selected) then
				tcolor(colors.white)
				bcolor(colors.orange)
			else
				tcolor(colors.cyan)
				bcolor(colors.lightGray)
			end
			cpos(1, 1+i)
			write("          ")
			if (i <= 6) then
				cpos(1, 1+i)
				write(" " .. P_DATA[i])
			end
		end
	end

	local function drawMain()
		tcolor(COLOR_TEXT)
		bcolor(COLOR_BG)
		local side = sides[selected]
		local p_type = sjn.getPeripheralType(side)
		local display = P_DATA[selected]

		local function advanced_write(text, x, y, condition)
			if (condition) then
				tcolor(colors.lime)
			else
				tcolor(colors.red)
			end
			cpos(x, y)
			write(text)
			tcolor(COLOR_TEXT)
		end

		local function button(text, x, y)
			cpos(x, y)
			tcolor(colors.cyan)
			bcolor(colors.orange)
			write(text)
			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
		end

		if (p_type ~= "printer") then
			local text = display .. " (" .. sides_display[selected] .. ")"
			cpos((width-10-#text) / 2 + 10 + 1, 3)
			write(text)
		end
		if (p_type == "computer" or p_type == "turtle") then
			cpos(12, 19)
			write("Input: ")
			advanced_write(tostring(redstone.getInput(side)), 19, 19, redstone.getInput(side))

			cpos(26, 19)
			write("Output: ")
			advanced_write(tostring(redstone.getOutput(side)), 34, 19, redstone.getOutput(side))

			button("Toggle", 40, 19)
		end

		if (p_type == "modem") then
			local data = {
				["online"] = rednet.isOpen(side)
			}

			local col1 = 15
			local col2 = 25
			local col3 = 40

			cpos(col1, 5)
			write("Online")
			advanced_write(tostring(data.online), col2, 5, data.online)
			button("Toggle", col3, 5)

			button("Rednet", 15, 7)
			button("Network", 22, 7)
		elseif (p_type == "drive") then
			local data = {
				["disk"] = disk.isPresent(side),
				["floppy"] = disk.hasData(side),
				["path"] = disk.getMountPath(side),
				["label"] = disk.getLabel(side),
				["label_display"] = disk.getLabel(side),
				["id"] = disk.getID(side),
				["audio"] = disk.hasAudio(side),
				["title"] = disk.getAudioTitle(side)
			}

			local disk_display = "None"
			if (data.floppy) then
				disk_display = "FloppyDisk"
			elseif (data.audio) then
				disk_display = "MusicDisc"
			end

			if (data.label_display == nil) then
				data.label_display = "None"
			end

			local col1 = 15
			local col2 = 30
			local col3 = 42

			cpos(col1, 5)
			write("In-Drive")
			advanced_write(disk_display, col2, 5, data.disk)
			
			if (data.floppy) then
				cpos(col1, 6)
				write("Label")
				advanced_write(string.sub(data.label_display, 1, col3 - col2 - 1), col2, 6, (data.label_display == data.label))
				button("Change", col3, 6)

				cpos(col1, 7)
				write("Path")
				advanced_write("C:/"..data.path, col2, 7, true)

				cpos(col1, 8)
				write("ID")
				advanced_write(data.id, col2, 8, true)

				local storage = 512
				local files = 0

		 		local function getFolderSize(folderPath)
			 		local list = fs.list(folderPath)
			 		for i=1, #list do
			 			local path = folderPath.."/"..list[i]
			 			if (fs.isDir(path)) then
			 				getFolderSize(path)
			 			else
			 				files = files + 1
			 				storage = storage + fs.getSize(path)
			 			end
			 		end
			 	end

			 	getFolderSize(data.path)

			 	cpos(col1, 9)
				write("Used Storage")
				advanced_write(storage, col2, 9, true)
				if (USERRANK == "a") then
					button("Clean", col3, 9)
				end

			 	cpos(col1, 10)
				write("Files")
				advanced_write(files, col2, 10, files > 0)
				if (USERRANK == "a") then
					button("FileMGR", col3, 10)
				end

				button("Eject", 15, 12)
			elseif (data.audio) then
				cpos(col1, 6)
				write("Title")
				advanced_write(data.title, col2, 6, true)

				button("Play", 15, 8)
				button("Stop", 20, 8)
				button("Eject", 25, 8)
			else
				cpos(col1, 7)
				write("You can put FloppyDisks and")
				cpos(col1, 8)
				write("MusicDiscs in your Disk-Drive.")
			end
		elseif (p_type == "printer") then
			local text = "(" .. sides_display[selected] .. ")"

			cpos((width-10-25-#display) / 2 + 10 + 1, 3)
			write(display)
			cpos((width-10-25-#text) / 2 + 10 + 1, 4)
			write(text)

			local printer = peripheral.wrap(side)
			local data = {
				["ink"] = printer.getInkLevel(),
				["paper"] = printer.getPaperLevel()
			}

			local col1 = 12
			local col2 = 20

			cpos(col1, 6)
			write("Ink")
			advanced_write(data.ink, col2, 6, data.ink ~= 0)
			
			cpos(col1, 7)
			write("Paper")
			advanced_write(data.paper, col2, 7, data.ink ~= 0)

			tcolor(colors.orange)
			bcolor(colors.gray)

			for y=2, 19 do
				cpos(27, y)
				write("                         ")
				cpos(27, y)
				write(PRINTER_DATA.input[y-1])
			end

			PRINTER_DATA.printer = printer

			button(" Print Page ", 13, 15)
			button("   Clear    ", 13, 17)
		elseif (p_type == "monitor") then
			
		elseif (p_type == "turtle" or p_type == "computer") then
			local computer = peripheral.wrap(side)

			local data = {
				["id"] = computer.getID()
			}

			if (data.id == nil) then
				data.id = "?"
			end

			local col1 = 15
			local col2 = 32
			
			cpos(col1, 5)
			write("Status")
			if (data.id ~= "?") then
				advanced_write("Online", col2, 5, true)
			else
				advanced_write("Offline", col2, 5, false)
			end

			cpos(col1, 6)
			write("ID")
			advanced_write(data.id, col2, 6, data.id ~= "?")
			
			button(" Toggle ", col1, 8)
		elseif (p_type == nil) then
			local data = {
				["rs_input"] = redstone.getInput(side),
				["rs_output"] = redstone.getOutput(side),
				["rs_bundled_input"] = redstone.getBundledInput(side),
				["rs_bundled_output"] = redstone.getBundledOutput(side)
			}

			local col1 = 15
			local col2 = 32
			local col3 = 40

			cpos(col1, 5)
			write("Redstone-Input")
			advanced_write(tostring(data.rs_input), col2, 5, data.rs_input)
			
			cpos(col1, 6)
			write("Redstone-Output")
			advanced_write(tostring(data.rs_output), col2, 6, data.rs_output)
			button("Toggle", col3, 6)
			
			cpos(col1, 7)
			write("Bundled-Input")
			advanced_write(tostring(data.rs_bundled_input), col2, 7, data.rs_bundled_input ~= 0)
			
			cpos(col1, 8)
			write("Bundled-Output")
			advanced_write(tostring(data.rs_bundled_output), col2, 8, data.rs_bundled_output ~= 0)



			local t_width = 3
			local t_height = 2
			local bundled_in = sjn.getBoolArrayFromColor(data.rs_bundled_input)

			cpos(11, height - t_height * 4)
			write("Bund. Input")
			for x=1, 4 do
				for y=1, 4 do
					local color = math.pow(2, (y-1) * 4 + (x-1))
					bcolor(color)

					for h=1, t_height do
						cpos(11 + (x-1)*t_width, height-t_height*4 + (y-1)*t_height + h)
						for w=1, t_width do
							write(" ")
						end
					end

					if (bundled_in[(y-1) * 4 + x]) then
						cpos(11 + (x-1)*t_width, height-t_height*4 + (y-1)*t_height + 1)
						tcolor(colors.white)
						if (color == colors.white or color == colors.yellow or color == colors.lightGray) then
							tcolor(colors.black)
						end
						write("On")
					end
				end
			end

			local bundled_out = sjn.getBoolArrayFromColor(data.rs_bundled_output)
			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
			cpos(width + 1 - t_width * 4, height - t_height * 4)
			write("Bund. Output")
			for x=1, 4 do
				for y=1, 4 do
					local color = math.pow(2, (y-1) * 4 + (x-1))
					bcolor(color)

					for h=1, t_height do
						cpos(width +1 -t_width*4 + (x-1)*t_width, height-t_height*4 + (y-1)*t_height + h)
						for w=1, t_width do
							write(" ")
						end
					end

					if (bundled_out[(y-1) * 4 + x]) then
						cpos(width + 1 - t_width*4 + (x-1)*t_width, height-t_height*4 + (y-1)*t_height + 1)
						tcolor(colors.white)
						if (color == colors.white or color == colors.yellow or color == colors.lightGray) then
							tcolor(colors.black)
						end
						write("On")
					end
				end
			end

			button(" Toggle  ", (width-9) / 2 + 5 + 1, 16)
			button(" All ON  ", (width-9) / 2 + 5 + 1, 17)
			button(" All OFF ", (width-9) / 2 + 5 + 1, 18)
		else
			cpos(15, 5)
			write("Sorry, the type ")
			tcolor(colors.orange)
			write(p_type)
			tcolor(COLOR_TEXT)
			write(" is not supported.")
		end
	end

	local function draw()
		refresh()
		drawTopBar()
		drawSideBar()
		drawMain()
	end

	draw()

	local run = true

	local timer = os.startTimer(1)

	while (run) do
		draw()
		local event, btn, x, y = os.pullEventRaw()
		if (event == "mouse_click") then
			if (x == 51 and y == 1) then
				run = false
			elseif (x <= 10) then
				if (y > 1 and y <= 7) then
					selected = y - 1
				end
			else
				local side = sides[selected]
				local p_type = sjn.getPeripheralType(side)

				if (p_type == "computer" or p_type == "turtle") then
					if (x >= 40 and x <= 46 and y == 19) then
						--Toggle RS OUTPUT
						redstone.setOutput(side, (not redstone.getOutput(side)))
					end
				end

				if (p_type == "modem") then
					if (y == 5 and x >= 40 and x <= 45) then
						--Toggle Modem online
						local open = rednet.isOpen(side)
						if (open) then
							rednet.close(side)
						else
							rednet.open(side)
						end
					elseif (y == 7 and x >= 15 and x <= 20) then
						--Rednet
						shell.run("SJNOS/system/SJNOS/rednet.sys", USERNAME)
					elseif (y == 7 and x >= 22 and x <= 28) then
						--Network
						shell.run("SJNOS/system/SJNOS/network.sys", USERNAME)
					end
				elseif (p_type == "drive") then
					if (disk.hasData(side)) then
						if (y == 6 and x >= 42 and x <= 47) then
							--Change Label
							local r, input = sjn.showInputDialog("Drive", {"Which Label should the Disk have?"}, colors.orange, colors.gray, colors.gray,
								colors.orange, colors.cyan, colors.lightGray, {{colors.lime, colors.gray, "Okay"},{colors.red, colors.gray, "Cancel"}})
							if (r == 1) then
								disk.setLabel(side, input)
							end
						elseif (y == 9 and x >= 42 and x <= 47 and USERRANK == "a") then
							--Clean (ADMIN)
							if (showDialog("Drive", {"Do you really want to clean", "your disk?", disk.label_display}, {{colors.lime, colors.gray, "Okay"},{colors.red, colors.gray, "Cancel"}}) == 1) then
								local r, input = sjn.showInputDialog("Drive", {"Please enter your password to","perform this action."}, colors.orange, colors.gray, colors.gray,
									colors.orange, colors.cyan, colors.lightGray, {{colors.lime, colors.gray, "Clean"},{colors.red, colors.gray, "Cancel"}}, nil, nil, nil, "*")
								if (r == 1) then
									if (input == sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d2) then
										local list = fs.list(disk.getMountPath(side))
										for i=1, #list do
											fs.delete(disk.getMountPath(side).."/"..list[i])
										end
										showDialog("Drive", {"Cleaned!"}, {{colors.lime, colors.gray, "Okay"}})
									else
										showDialog("Drive", {"Wrong password!"}, {{colors.lime, colors.gray, "Okay"}})
									end
								end
							end
						elseif (y == 10 and x >= 42 and x <= 49 and USERRANK == "a") then
							--FileMGR (ADMIN)
							shell.run("SJNOS/data/programs/filemgr.exe", USERNAME, disk.getMountPath(side))
						elseif (y == 12 and x >= 15 and x <= 20) then
							disk.eject(side)
						end
					elseif (disk.hasAudio(side)) then
						if (y == 8 and x >= 15 and x <= 19) then
							--Play
							disk.playAudio(side)
							showDialog("Drive", {"Playing now", disk.getAudioTitle(side)}, {{colors.lime, colors.gray, "Okay"}})
						elseif (y == 8 and x >= 20 and x <= 24) then
							--Stop
							disk.stopAudio(side)
						elseif (y == 8 and x >= 25 and x <= 30) then
							--Eject
							disk.eject(side)
						end
					else

					end
				elseif (p_type == "printer") then
					if (x >= 27 and y >= 2) then
						--Printer field
						cpos(27, y)
						bcolor(colors.lightGray)
						write("                         ")
						tcolor(colors.cyan)
						cpos(27, y)
						local input = read()

						PRINTER_DATA.input[y-1] = string.sub(input, 1, 25)
					elseif (x >= 13 and x <= 13+12 and y == 15) then
						--Print Page
						local function showDialog(head, texts, buttons, delay, enterButton)
							return sjn.showDialog(head, texts, colors.orange, colors.gray,
								colors.gray, colors.orange, buttons, enterButton, delay)
						end

						if (PRINTER_DATA.printer.getInkLevel() > 0) then
							if (PRINTER_DATA.printer.getPaperLevel() > 0) then
								local r, title = sjn.showInputDialog("Printer", {"Which Title should the Page have?"}, colors.orange, colors.gray, colors.gray,
									colors.orange, colors.cyan, colors.lightGray, {{colors.lime, colors.gray, "Okay"},{colors.red, colors.gray, "Cancel"}})
								if (r == 1) then
									local page = PRINTER_DATA.printer.newPage()
									local page_width, page_height = PRINTER_DATA.printer.getPageSize()
									if (page) then
										for i=1, #PRINTER_DATA.input do
											PRINTER_DATA.printer.setCursorPos(1, i)
											PRINTER_DATA.printer.write(string.sub(PRINTER_DATA.input[i], 1, page_width))
										end
										PRINTER_DATA.printer.setPageTitle(title)
										PRINTER_DATA.printer.endPage()
										showDialog("Printer", {"Printed!"}, {{colors.lime, colors.gray, "Okay"}})
									else
										showDialog("Printer", {"Unknown Error!!!","Check your Printer, maybe it's full."}, {{colors.red, colors.gray, "Close"}})
									end
								end
							else
								showDialog("Printer", {"You don't have paper in your printer!"}, {{colors.lime, colors.gray, "Okay"}})
							end
						else
							showDialog("Printer", {"You don't have ink in your printer!"}, {{colors.lime, colors.gray, "Okay"}})
						end
					elseif (x >= 13 and x <= 13+12 and y == 17) then
						--Clear
						for i=1, 18 do
							PRINTER_DATA.input[i] = ""
						end
					end
				elseif (p_type == "computer" or p_type == "turtle") then
					if (x >= 15 and x <= 15+8 and y == 8) then
						--Toggle (Turn ON / Turn OFF)
						local computer = peripheral.wrap(side)
						local id = computer.getID()
						if (id == nil) then
							computer.turnOn()
							os.startTimer(0.01)
						else
							computer.shutdown()
						end
					end
				elseif (p_type == nil) then
					if (x >= 40 and x <= 45 and y == 6) then
						--Toggle Redstone Output
						local old_output = redstone.getOutput(side)
						redstone.setOutput(side, (not old_output))
					elseif (x >= 40 and y >= 12) then
						--Toggle Bundled Output
						local t_x = math.floor((x-40) / 3) + 1
						local t_y = math.floor((y-12) / 2)
						local i = t_y * 4 + t_x

						local old_bundled_out = sjn.getBoolArrayFromColor(redstone.getBundledOutput(side))
						old_bundled_out[i] = (not old_bundled_out[i])

						local color = sjn.getColorFromBoolArray(old_bundled_out)
						redstone.setBundledOutput(side, color)
					elseif (x >= (width-9) / 2 + 5 and x <= (width-9) / 2 + 5 + 9 and y == 16) then
						--Toggle All
						local old_bundled_out = sjn.getBoolArrayFromColor(redstone.getBundledOutput(side))
						for i=1, 16 do
							old_bundled_out[i] = (not old_bundled_out[i])
						end

						local color = sjn.getColorFromBoolArray(old_bundled_out)
						redstone.setBundledOutput(side, color)
					elseif (x >= (width-9) / 2 + 5 and x <= (width-9) / 2 + 5 + 9 and y == 17) then
						--All ON
						redstone.setBundledOutput(side, math.pow(2, 16) - 1)
					elseif (x >= (width-9) / 2 + 5 and x <= (width-9) / 2 + 5 + 9 and y == 18) then
						--ALL OFF
						redstone.setBundledOutput(side, 0)
					end
				end
			end
		elseif (event == "timer") then
			if (btn == timer) then
				
			end
		end
		timer = os.startTimer(1)
	end

	tcolor(colors.white)
	bcolor(colors.black)
	clear()
	cpos(1, 1)

	return true
end

local ok, err = pcall(start)
if not ok then
	if (not sjn.drawErrorScreen(err, tArgs[1])) then
		shell.run("SJNOS/start.exe")
	end
end
os.unloadAPI("SJNOS/system/SJNOS/sjn")