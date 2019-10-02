--SJNOS by MC403. desktop.sys (qK1cVg8R)

local tArgs = {...} --standard.exe <USERNAME>

local function start()


if (not term.isColor()) then
	error('This program needs support for colors.')
elseif (tArgs[1] == nil or not fs.exists("SJNOS/users/"..tArgs[1].."/config/.config")) then
    error('Invalid parameters.')
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


local FIRSTRUN = false
if fs.exists("SJNOS/firstrun") then
	FIRSTRUN = true
	fs.delete("SJNOS/firstrun")
end

local isRednet = sjn.getRednet(true)

local help = {
	["desktop"] = {"Desktop"},
	["apps"] = {"In 'Apps' you can manage your own programmed applications or other awesome tools"},
	["files"] = {"In 'Files' you can manage your Files","with simple clicks! Copy or print","files or install them! There is much","to explore."},
	["plugins"] = {"Plug-Ins"},
	["settings"] = {"Settings"},
	["peripherals"] = {"Peripherals are useful to do","actions in the world around you."},
	["network"] = {"'Network' is very useful at talking","to other PC's or Turtles. Explore","the Internet (S-Web), GPS, Mails and","much more!"},
	["helpabout"] = {"Help&About"},
}


local dlg = "normal"

local function draw()
	isRednet = sjn.getRednet(true)

	bcolor(colors.white)
	clear()
	cpos(1, 1)
	bcolor(colors.cyan)
	tcolor(colors.orange)
	term.clearLine()
	write("SJNOS")
	cpos(47,1)
	write(getTime())
	cpos(45, 1)
	tcolor(colors.black)
	if isRednet then bcolor(colors.lime)
	else bcolor(colors.red) end
	write("R")
	tcolor(colors.cyan)
	bcolor(colors.white)

	local path = "SJNOS/data/icons/desktop/"
	local img = {"desktop.img","apps.img","files.img","plugins.img","settings.img","peripheral.img","network.img","help.img"}
	local text = {"Desktop","Applications","Files","Plug-Ins","Settings","Peripherals","Network","Help&About"}

	for y=1,2 do
		for x=1,4 do
			paintutils.drawImage(paintutils.loadImage(path..img[4*(y-1)+x]),(x-1)*12+4,(y-1)*9+3)
			bcolor(colors.white)
			tcolor(colors.cyan)
			cpos((x-1)*12+8-(string.len(text[4*(y-1)+x])/2),y*9+1)
			write(text[4*(y-1)+x])
		end
	end

	if (dlg == 'menu') then
		cpos(1, 1)
		tcolor(colors.orange)
		bcolor(colors.gray)
		write("SJNOS ")

		cpos(1, 2)

		local menu = {'Profile', 'Terminal', 'Log-Out', 'About'}

		if USERRANK == "a" then
			table.insert(menu, 'Admin Tools')
		end
		for i=1, #menu do
			cpos(1, i+1)
			write(' ' .. menu[i])
			if (#menu[i] < 12) then
				write(string.rep(' ', 11 - #menu[i] + 1))
			end
		end
	end
end


local function devPrev(text)
	sjn.showInfoDialogDESIGN(text, {"Sorry, this part of SJNOS is", "not programmed yet."}, DESIGN_BLUE)
	dlg = "normal"
	draw()
end

local function itemClick(btn, x, y, path, name, help)
	if (btn == 1) then
		shell.run(path, USERNAME)
	elseif (btn == 2) then
		local options = {
			" Run          ",
			" Help         ",
			" Show Path    "
		}

		local xx = x
		local yy = y
		if (xx>37) then xx = 37 end
		if (yy>19-#options-1) then yy = 19-#options-1 end

		bcolor(colors.gray)
		tcolor(colors.orange)

		for i=1,#options do
			cpos(xx+1,y+i)
			write(options[i])
		end

		local runn = true
		while runn do
			local event, btn, x, y = os.pullEventRaw()
			if (event=="mouse_click" and btn==1) then
				if (x > xx+1 and x < xx+15) then
					if (y == yy+1) then
						--Run
						shell.run(path,USERNAME)
					elseif (y == yy+2) then
						--Help
						sjn.showDialog("Help for "..name, help, colors.orange, colors.gray,
							colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
					elseif (y == yy+3) then
						--Show Path
						sjn.showDialog(name, {"C:/"..path}, colors.orange, colors.gray,
							colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
					end
					draw()
					runn = false
				else
					runn = false
					draw()
				end
			end
		end
	end
	draw()
end

local timer = os.startTimer(1)
while true do
	draw()
	local event, btn, x, y = os.pullEventRaw()
	if dlg == "normal" then
		if event=="mouse_click" then
			if y==1 then
				--TITLE BAR
				if x <= 6 then
					--SJNOS
					dlg = "menu"
				elseif x==45 then
					--Rednet
					itemClick(btn, x, y,"SJNOS/system/SJNOS/rednet.sys","Rednet", help.rednet)
				elseif x>=47 then
					--Clock
					devPrev("Clock")
				end
			elseif x>=4 and x<=11 and y>=3 and y<=9 then
				--Desktop
				devPrev("Desktop")
			elseif x>=16 and x<=23 and y>=3 and y<=9 then
				--Applications
				itemClick(btn, x, y, "SJNOS/system/SJNOS/applications.sys", "Apps", help.apps)
			elseif x>=28 and x<=35 and y>=3 and y<=9 then
				--Files
				itemClick(btn, x, y, "SJNOS/data/programs/filemgr.exe","FileManager", help.files)
			elseif x>=40 and x<=47 and y>=3 and y<=9 then
				--Plug-Ins
				devPrev("PlugIns")
			elseif x>=4 and x<=11 and y>=12 and y<=18 then
				--Settings
				devPrev("Settings")
			elseif x>=16 and x<=23 and y>=12 and y<=18 then
				--Peripherals
				itemClick(btn, x, y, "SJNOS/system/SJNOS/peripherals.sys","Peripherals", help.peripherals)
			elseif x>=28 and x<=35 and y>=12 and y<=18 then
				--Network
				itemClick(btn,x,y,"SJNOS/system/SJNOS/network.sys","Network", help.network)
			elseif x>=40 and x<=47 and y>=12 and y<=18 then
				--Help&About
				devPrev("Help&About")
			end
		end
	elseif dlg=="menu" then
		if (event == 'mouse_click') then
			dlg = "normal"
			draw()

			if x <= 13 and btn==1 then
				if y==2 then
					--Profile
					devPrev("Profile")
				elseif y==3 then
					--Terminal
					shell.run("SJNOS/data/programs/terminal.exe", USERNAME)
				elseif y==4 then
					--Logout

					if (sjn.showConfirmDialogDESIGN("Logout", {"Do you really want to log out?"}, DESIGN_DARK, 2) == 1) then
						break --Leaves this Program and returns to "start.exe" und damit "login.sys"
					end
				elseif y==5 then
					--About
					devPrev("About")
				elseif y==6 and USERRANK=="a" then
					--AdminTools
					local admin_tool = sjn.showDialog("Admin Tools", {"Your Rank: ADMINISTRATOR", string.rep(" ", 49)}, colors.orange, colors.gray, colors.gray, colors.orange, {
						{colors.lime, colors.gray, "CraftOS"},
						{colors.lime, colors.gray, "UserManager"},
						{colors.lime, colors.gray, "Config"},
						{colors.lime, colors.gray, "Deinstallation"},
						{colors.red, colors.gray, "Close"},
					}, 5)

					if (admin_tool == 1) then
						if (sjn.showConfirmDialogDESIGN('Admin Tools', {'Are you sure to enter CraftOS?', 'Restart SJNOS with this command:', 'SJNOS/start.exe'}, DESIGN_DARK, 2) == 1) then
							local f = fs.open("SJNOS/system/temp/.temp", 'w')
							f.writeLine("leave=leave")
							f.close()
							break
						end
					elseif (admin_tool == 2) then
						devPrev("UserManager")
					elseif (admin_tool == 3) then
						devPrev("Config")
					elseif (admin_tool == 4) then
						if(sjn.showConfirmDialogDESIGN('Deinstallation', {"Are you sure to DEINSTALL SJNOS???", "(C:/SJNOS/)"}, DESIGN_DARK, 2) == 1) then
							draw()
							if(sjn.showConfirmDialogDESIGN('Deinstallation', {"Are you really sure doing this?","(It will delete SJNOS...)"}, DESIGN_DARK, 2) == 1) then
								draw()

								local btn, input = sjn.showInputDialog("Deinstallation", {"Enter your Password!", "(Last chance to cancel!)"},
									colors.orange, colors.gray, colors.gray, colors.orange, colors.orange, colors.lightGray, {{colors.lime, colors.gray, "Deinstall"},{colors.red, colors.gray, "Cancel"}}, 2, nil, true, "*")

								draw()

								if (btn == 1) then
									--Okay
									local data = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config")

									if (input == data.pass) then
										if (not shell.run("SJNOS/system/SJNOS/deinstall.sys","wk234iajFAA234kse995oasdif","laof9234kasdjferr4kaw","asdfLLLLkk###123asdf")) then
											sjn.showDialog("Deinstallation", {"Sorry, this has not worked...", "Please try again!"},
												colors.orange, colors.gray, colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
										end
									elseif (data.pass and data.pass ~= '') then
										sjn.showConfirmDialogDESIGN('Deinstallation', {"Wrong password!"}, DESIGN_DARK, 2)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	timer = os.startTimer(1)
end



return true
end

if (os.loadAPI("SJNOS/system/SJNOS/sjn")) then
	sjn.program(start)
	os.unloadAPI("SJNOS/system/SJNOS/sjn")
else
	error('Bummer, we could not find and load needed software (SJNOS/system/SJNOS/sjn)!')
end
