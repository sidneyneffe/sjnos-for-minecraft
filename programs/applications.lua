--SJNOS by MC403. applications.sys (gNEADRX9)

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

	local USERNAME = tArgs[1]
	local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

	local function showDialog(head, texts, buttons, enterButton, delay)
		return sjn.showDialog(head, texts, colors.orange, colors.gray,
			colors.gray, colors.orange, buttons, enterButton, delay)
	end

	local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
		return sjn.showInputDialog(head, texts, colors.orange, colors.gray,
			colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
	end

	local function button(text, x, y)
		cpos(x, y)
		tcolor(colors.cyan)
		bcolor(colors.orange)
		write(text)
		tcolor(COLOR_TEXT)
		bcolor(COLOR_BG)
	end

	local apps = {}
	local selected = 1
	local VIEW_IMAGE, VIEW_LIST = 1, 2
	local view = VIEW_IMAGE

	local function refresh()
		local list = fs.list("SJNOS/users/"..USERNAME.."/home/apps")
		apps = {}
		for i=1,#list do
			local data = sjn.getApp("SJNOS/users/"..USERNAME.."/home/apps".."/"..list[i])
			if (data ~= nil) then
				data.root = "SJNOS/users/"..USERNAME.."/home/apps/appdata/"..data.header.name.."/"
				apps[#apps+1] = data
			end
		end

		if (selected > #apps) then
			selected = 1
		end
	end

	refresh()

	local DLG_STANDARD, DLG_MENU, DLG_APP_INFO = 0, 1, 2
	local dlg = DLG_STANDARD

	local function drawTopBar()
		bcolor(COLOR_BG)
		clear()
		cpos(1, 1)
		bcolor(COLOR_HEAD_BG)
		tcolor(COLOR_HEAD_TEXT)
		term.clearLine()
		write("Apps")
		cpos(47, 1)
		write(getTime())
	end

	local function drawMain()
		tcolor(COLOR_TEXT)
		bcolor(COLOR_BG)

		if (#apps > 0) then
			local app = apps[selected]
			cpos(1, 5)
			
			local imagetype = app.header.imagetype
			local imagedata = app.header.imagedata
			local name = app.header.name

			local image = {{}}

			local function getPath(file)
				return app.root .. file
			end

			if (imagetype ~= nil and imagedata ~= nil) then
				if (imagetype == "data") then
					image = sjn.getPaintableFromData(imagedata, 12, 8)
				elseif (imagetype == "source") then
					if (fs.exists(getPath(imagedata))) then
						image = paintutils.loadImage(getPath(imagedata))
					end
				elseif (imagetype == "pastebin") then
					local temp = "SJNOS/users/"..USERNAME.."/config/.temp"
					fs.delete(temp)
					shell.run("pastebin", "get", imagedata, temp)
					image = paintutils.loadImage(temp)
					fs.delete(temp)
				end
			end

			local x = math.floor((width-12) / 2 + 1)
			local y = 6
			bcolor(colors.lightGray)
			for i=1,8 do
				cpos(x, y-1+i)
				write("            ")
			end

			for i=1, #image do
				if (i > 8) then
					image[i] = {}
				end
				for j=1, #image[i] do
					if (j > 12) then
						image[i][j] = 0
					end
				end
			end

			paintutils.drawImage(image, x, y)

			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
			cpos((width - #name) / 2 + 1, 15)
			write(name)

			button("+", 1, 19)

			local text = selected .. "/" .. #apps
			cpos(52-#text, 19)
			write(text)

			cpos(17, y+4)
			write("<")

			cpos(34, y+4)
			write(">")
		else
			local text = "No Apps installed."
			cpos((width - #text) / 2 + 1, 7)
			write(text)
		end
	end

	local function draw()
		refresh()
		drawTopBar()
		drawMain()

		if (dlg == DLG_MENU) then
			cpos(1, 1)
			bcolor(colors.gray)
			tcolor(colors.orange)
			write("Apps ")

			local menu = {
				" List View   ",
				" Search      ",
				" Install     ",
				" Deinstall   ",
				" Help        ",
				" Quit        "
			}

			for i=1,#menu do
				cpos(1, i + 1)
				write(menu[i])
			end
		elseif (dlg == DLG_APP_INFO) then
			for y=2,19 do
				cpos(1, y)
				term.clearLine()
			end

			local app = apps[selected]

			local files, storage = 1, fs.getSize(app.path)

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

		 	getFolderSize(app.root)

			local function advanced_write(para1, para2, line)
				para1 = tostring(para1)
				para2 = tostring(para2)
				cpos(17 - #para1/2, line)
				write(para1)
				cpos(34 - #para2/2, line)
				tcolor(colors.orange)
				write(para2)
				tcolor(COLOR_TEXT)
			end

			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)

			advanced_write("Name", app.header.name, 6)
			advanced_write("Author", app.header.author, 7)
			advanced_write("Lines", app.program.lines, 8)
			advanced_write("Files", files, 9)
			advanced_write("Storage", storage, 10)

			button("CLOSE", 24, 4)
		end
	end

	local function change(up)
		if (up) then
			selected = selected + 1
			if (selected > #apps) then
				selected = 1
			end
		else
			selected = selected - 1
			if (selected < 1) then
				selected = #apps
			end
		end
	end

	local running = true
	local timer = os.startTimer(1)

	while running do
		draw()
		local apps_installed = #apps > 0
		local event, btn, x, y = os.pullEvent()
		if (dlg == DLG_STANDARD) then
			if (event == "mouse_click") then
				if (y == 1 and x <= 5) then
					--Menu
					dlg = DLG_MENU
				elseif (x == 17 and y == 10 and apps_installed) then
					--Left Arrow
					change(false)
				elseif (x == 34 and y == 10 and apps_installed) then
					--Right Arrow
					change(true)
				elseif (x == 1 and y == 19 and apps_installed) then
					--More Infos
					dlg = DLG_APP_INFO
				elseif (x >= 20 and x <= 32 and y >= 6 and y <= 17 and apps_installed) then
					--Click on the App
					local app = apps[selected]
					if (btn == 1) then
						--Run
						local temp = "SJNOS/users/"..USERNAME.."/config/.temp"
						local f = fs.open(temp, "w")

						for i=1, #app.program.code do
							f.writeLine(app.program.code[i])
						end
						f.close()

						tcolor(colors.white)
						bcolor(colors.black)
						cpos(1, 1)
						clear()
						shell.run(temp)

						tcolor(colors.orange)
						bcolor(colors.gray)
						cpos(1, 19)
						term.clearLine()
						write("[SJNOS: Press any key to exit the application.]")
						local event = os.pullEvent()
						while (event ~= "key" and event ~= "mouse_click") do
							event = os.pullEvent()
						end
						
						local f = fs.open(temp, "w")
						f.close()
					elseif (btn == 2) then
						local action = showDialog(app.header.name, {"Action?","                                               "}, {{colors.lime, colors.gray, "Deinstall"},{colors.lime, colors.gray, "Path"},{colors.red, colors.gray, "Close"}}, 3)
						draw()
						if (action == 1) then
							--Deinstall
							if (showDialog(app.header.name, {"Do you really want to deinstall","'"..app.header.name.."'?"}, {{colors.lime, colors.gray, "Deinstall"},{colors.red, colors.gray, "Close"}}, 2)==1) then
								sjn.deinstallApp(app.path)
							end
						elseif (action == 2) then
							--Get Path
							showDialog(app.header.name, {"C:/"..app.path}, {{colors.lime, colors.gray, "Okay"}})
						end
					end
				end
			elseif (event == "key") then
				if (btn == 203) then
					change(false)
				elseif (btn == 205) then
					change(true)
				end
			end
		elseif (dlg == DLG_MENU) then
			if (event == "mouse_click") then
				if (x <= 13 and y > 1 and y <= 7) then
					if (y == 2) then
						--List View
						showDialog("List View", {"Sorry, this part of SJNOS is", "not programmed yet."}, {{colors.lime, colors.gray, "Okay"}})
					elseif (y == 3) then
						--Search
						showDialog("Search", {"Sorry, this part of SJNOS is", "not programmed yet."}, {{colors.lime, colors.gray, "Okay"}})
					elseif (y == 4) then
						--Install
						local result, path = sjn.getUserFile(USERNAME, "Select a file to be installed.")
						if (result) then
							local result, e = sjn.installApp(path, USERNAME)
							if (result) then
								showDialog("Installing", {"Installed!"}, {{colors.lime, colors.gray, "Okay"}})
							else
								showDialog("Installing", {"Error!", e}, {{colors.lime, colors.gray, "Okay"}})
							end
						end
					elseif (y == 5) then
						--Deinstall
						showDialog("Deinstall", {"Sorry, this part of SJNOS is", "not programmed yet."}, {{colors.lime, colors.gray, "Okay"}})
					elseif (y == 6) then
						--Help
						showDialog("Help", {"Sorry, this part of SJNOS is", "not programmed yet."}, {{colors.lime, colors.gray, "Okay"}})
					elseif (y == 7) then
						--Quit
						running = false
					end
				end
				dlg = DLG_STANDARD
			end
		elseif (dlg == DLG_APP_INFO) then
			if (event == "mouse_click") then
				if (x >= 24 and x <= 28 and y == 4) then
					--Close
					dlg = DLG_STANDARD
				end
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